## Operation procs module
## ======================
##
## This module contains the logic of the operations commands.

import std/[os, strutils, strformat, options, terminal, tables, segfaults]
import taskpools
import ../globals, ../fileio, ../error, types, gitcommands

using
    op_args: seq[string]
    _: seq[string]


proc helpCommand*(_) =
    ## Help command - prints basic program information and all commands.
    var text: seq[string]
    for op in operations:
        var temp: seq[string] = @[
            &"{op.name}:",
            repeat('-', op.name.len() + 1),
            &"   {op.desc}"
        ]
        if op.alias.isSome():
            temp.add(&"   Also:\n   ↳ " & op.alias.get().join(", "))  # weird mish-mash of syntax because my highlighter was weird
        text.add(temp.join("\n"))

    echo @[
        &"{PROJECT_NAME} v{PROJECT_VERSION}  -  by " & PROJECT_AUTHORS.join(", "),  # same here
        PROJECT_DESCRIPTION,
        &"Source: {PROJECT_WEBSITE}"
    ].join("\n")
    echo "\nArguments:"
    echo text.join("\n\n")


proc listCommand*(_) =
    ## List command - lists all git repositories in the repo-directory.
    echo get_valid_git_dirs_names().join("   ")


proc cloneCommand*(op_args) =
    ## Clone command - clones a repository into the repo-directory.
    var status: ErrorStatus

    git_repo_path.setCurrentDir()
    for repo in op_args:
        let succ: int = GIT_CLONE.execute(repo)
        # Save successes and failures:
        if succ == 0: status.successes += 1
        else: status.failures.add(repo)

    stdout.write "\n"
    status.print_after_clone()


proc removeCommand*(op_args) =
    ## Remove command - removes a repository from the repo-directory.
    let valid_dirs: seq[string] = get_valid_git_dirs_names()
    var dirs_to_delete: seq[string]
    for dir in op_args:
        if dir in valid_dirs: dirs_to_delete.add(dir)

    if dirs_to_delete.len() == 0:
        echo "No directories found with matching names."
        quit(1)

    # Ask for confirmation:
    styledEcho fgRed, &"You are about to remove these {dirs_to_delete.len()} repositories:", fgDefault
    echo dirs_to_delete.join(", ")
    stdout.styledWrite fgRed, &"This cannot be undone. Are you sure you want to proceed?", fgDefault, " [y/N] "
    let confirm: char = getch()
    stdout.write("\n")
    if confirm.toLowerAscii() != 'y':
        echo "Aborting."
        quit(1)

    # Remove dirs:
    let status: ErrorStatus = remove_git_dirs(dirs_to_delete)
    stdout.write("\n")
    status.print_after_remove()


proc pick_valid_dirs_or_all(op_args): seq[string] =
    ## Picks valid dirs from arguments or returns all valid git dirs if none given.
    let valid_dirs: seq[string] = get_valid_git_dirs_names()
    result =
        if op_args.len() == 0:
            # Pull from all:
            valid_dirs
        else:
            # Pull only specified:
            var additions: seq[string]
            for dir in op_args:
                if dir in valid_dirs: result.add(dir)
            additions

    return result

proc checkUpdate(repo, tempDir: string): bool =
    ## Checks if a repository is updatable with git dry run.
    # TODO: Implement and make it actually work...
    var tempFile: string = tempDir & "gitmanupdatecheck.temp"
    let status: int = GIT_CHECK_UPDATES.execute(&"&> {tempFile}")

    # stderr.writeLine "\nFile: " & readFile(tempFile) & "\n"
    # stderr.flushFile()

    if status != 0:
        stderr.writeLine(&"Errors with dryrun (exit code {status}):\n{tempFile.readFile()}")
    else:
        # Check length of git output (shitty implementation but it works i guess):
        if tempFile.readFile().len() > 2: result = true

    try:
        tempFile.removeFile()
    except OSError:
        stderr.writeLine(&"Failed to remove file '{tempFile}'! Continuing anyways.")


proc getUpdatableRepos(op_args): seq[string] =
    ## Gets all repositories, that can be updated using git dry runs.
    let
        dirs: seq[string] = op_args
        tempDir: string = getTempDir()
    if not tempDir.dirExists():
        TEMP_DIR_UNAVAILABLE.handle(&"Could not get '{tempDir}'...")

    var currentDir: int
    for repo in dirs:
        if repo.checkUpdate(tempDir): result.add(repo)

        # Little progress meter:
        currentDir.inc()
        stdout.write("\rChecking for updates... " & $(currentDir / dirs.len() * 100).formatFloat(precision = 4) & "%")
        stdout.flushFile()
    stdout.write "\n"
    stdout.flushFile()


proc pullCommandSync*(op_args) =
    ## Pull command - pulls changes from origin.
    let dirs: seq[string] = op_args.pick_valid_dirs_or_all() # .getUpdatableRepos()

    # Quit if no valid dirs:
    if dirs.len() == 0:
        echo "Nothing to do."
        quit(0)

    # cd into directories and pull changes:
    var status: ErrorStatus
    for dir in dirs:
        try:
            styledEcho fgYellow, &"Pulling {dir}...", fgDefault
            setCurrentDir(git_repo_path & dir)
            if GIT_PULL.execute() == 0: status.successes += 1
            else: status.failures.add(dir)
        except OSError:
            status.failures.add(dir)

    stdout.write("\n")
    status.print_after_pull()

proc pullCommandAsync*(op_args) =
    ## Pull command - pulls changes from origin.
    let dirs: seq[string] = op_args.pick_valid_dirs_or_all() # .getUpdatableRepos()

    # Quit if no valid dirs:
    if dirs.len() == 0:
        echo "Nothing to do."
        quit(0)

    # cd into directories and pull changes:
    proc pullDir(git_repo_path, dir: string): ErrorStatus {.gcsafe.} =
        proc printSuccess(success: bool) =
            case success:
            of true: stdout.styledWrite fgGreen, "-", fgDefault
            of false: stdout.styledWrite fgRed, "X", fgDefault
        try:
            #styledEcho fgYellow, &"Pulling {dir}...", fgDefault
            setCurrentDir(git_repo_path & dir)
            if GIT_PULL.execute("&> /dev/null") == 0:
                result.successes += 1
                printSuccess(true)
            else:
                result.failures.add(dir)
                printSuccess(false)
        except OSError:
            result.failures.add(dir)
            printSuccess(false)
        finally:
            stdout.flushFile()

    proc thread_watcher(tasks: Taskpool, git_repo_path: string, dirs: seq[string]): ErrorStatus =
        var tempResults: seq[Flowvar[ErrorStatus]] = newSeq[Flowvar[ErrorStatus]](dirs.len())
        stdout.write "Repositories: [" & ".".repeat(dirs.len()) & "]\r"
        stdout.write "Repositories: ["
        stdout.flushFile()
        for i, dir in dirs:
            tempResults[i] = tasks.spawn pullDir(git_repo_path, dir)
        for i, _ in tempResults:
            let newResult: ErrorStatus = sync tempResults[i]
            result.successes += newResult.successes
            result.failures &= newResult.failures

    var tasks: Taskpool = new Taskpool
    var status: ErrorStatus = tasks.thread_watcher(git_repo_path, dirs)
    syncAll tasks
    shutdown tasks

    stdout.write("\n")
    status.print_after_pull()

proc installCommand*(op_args) =
    ## Install command - executes install script from installation json-file.
    let
        install_instructions: Table[string, string] = read_install_config_file()
        dirs: seq[string] = op_args.pick_valid_dirs_or_all()

    if dirs.len() == 0:
        echo &"Nothing to do. No valid install commands found in '{install_json_file}'..."
        quit(1)

    var status: ErrorStatus
    for dir, command in install_instructions:
        let full_dir: string = "$1/$2" % [git_repo_path, dir]
        try:
            full_dir.setCurrentDir()
        except OSError as e:
            echo "Could not set current directory to '$1'. Reason: ($2)" % [full_dir, e.msg]
            continue

        let exit_code: int = command.execShellCmd()
        status.add(dir, exit_code)
    status.print_after_install()

proc editInstallCommand*(_) =
    ## Edit install command - edits the install json-file.
    var editor: string
    if existsEnv("EDITOR"): editor =
        getEnv("EDITOR")
    else:
        stderr.write("No 'EDITOR' environment variable found.\nWith what editor do you want to open the config file? ")
        editor = stdin.readLine()

    if editor == "":
        EDITOR_NOT_EXISTS.handle("Please type a correct executable name or set your 'EDITOR' environment variable!" &
            (when not(defined windows) or not(defined mingw):
                "\nYou can do this by adding 'export EDITOR=editor_name' in your profile file (default: ~/.profile)!\n" &
                "For example: 'export EDITOR=vim', 'export EDITOR=nano'"
            else: ""
            )
        )

    let exitCode: int = execShellCmd("$1 $2" % [editor, install_json_file])
    echo (
        if exitCode == 0: "Successfully applied changes."
        else: "Errors encountered. Please double-check if changes were written to disk!"
    )

