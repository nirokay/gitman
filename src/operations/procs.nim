## Operation procs module
## ======================
##
## This module contains the logic of the operations commands.

import std/[os, osproc, strutils, strformat, options, terminal, tables, algorithm]
import taskpools
import ../globals, ../fileio, ../error, types, gitcommands

using
    opArgs: seq[string]
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
            temp.add(&"   Command aliases:\n   ↳ " & op.alias.get().join(", "))  # weird mish-mash of syntax because my highlighter was weird
        text.add(temp.join("\n"))

    echo @[
        &"{PROJECT_NAME} v{PROJECT_VERSION}  -  by " & PROJECT_AUTHORS.join(", "),  # same here
        PROJECT_DESCRIPTION,
        &"Source: {PROJECT_WEBSITE}"
    ].join("\n")
    echo "\nArguments:"
    echo text.join("\n\n").indent(4)


proc versionCommand*(_) =
    echo &"{PROJECT_NAME} v{PROJECT_VERSION}"
    echo &"Compiled with Nim v{PROJECT_COMPILE_NIM_VERSION} at {PROJECT_COMPILE_TIME}"


proc toList(itemsUnsorted: seq[string]): string =
    let
        width: int = terminalWidth()
        smallestWidth: int = 50
        items: seq[string] = itemsUnsorted.sorted()
    if width < smallestWidth:
        stderr.writeLine(&"Terminal windows is smaller than {smallestWidth}, no fancy printout will be done!")
        return items.join("\n")
    let
        itemsPerRow: int = 5
        oneThSpace: int = 5
        spacerWidth: int = width div oneThSpace div itemsPerRow
        itemLength: int = width div itemsPerRow - spacerWidth

    proc cut(item: string): string =
        if item.len() > itemLength:
            result = item[0 .. itemLength - 1 - 3] & "..."
        elif item.len() < itemLength:
            result = item & repeat(" ", itemLength - item.len())
        else:
            result = item

    for i, item in items:
        stdout.write(item.cut())
        if i != 0 and i mod itemsPerRow == itemsPerRow - 1:
            stdout.write("\n")
        else:
            stdout.write(repeat(" ", spacerWidth))

proc listCommand*(_) =
    ## List command - lists all git repositories in the repo-directory.
    echo getValidGitDirsNames().toList()


proc cloneCommand*(opArgs) =
    ## Clone command - clones a repository into the repo-directory.
    var status: ErrorStatus

    gitRepoPath.setCurrentDir()
    for repo in opArgs:
        let (succ, output) = GIT_CLONE.execute(repo)
        # Save successes and failures:
        if succ == 0: status.successes += 1
        else: status.failures.add([repo, output])

    stdout.write "\n"
    status.printAfterClone()


proc removeCommand*(opArgs) =
    ## Remove command - removes a repository from the repo-directory.
    let validDirs: seq[string] = getValidGitDirsNames()
    var dirsToDelete: seq[string]
    for dir in opArgs:
        if dir in validDirs: dirsToDelete.add(dir)

    if dirsToDelete.len() == 0:
        echo "No directories found with matching names."
        quit(1)

    # Ask for confirmation:
    styledEcho fgRed, &"You are about to remove these {dirsToDelete.len()} repositories:", fgDefault
    echo dirsToDelete.join(", ")
    stdout.styledWrite fgRed, &"This cannot be undone. Are you sure you want to proceed?", fgDefault, " [y/N] "
    let confirm: char = getch()
    stdout.write("\n")
    if confirm.toLowerAscii() != 'y':
        echo "Aborting."
        quit(1)

    # Remove dirs:
    let status: ErrorStatus = removeGitDirs(dirsToDelete)
    stdout.write("\n")
    status.printAfterRemove()


proc pickValidDirsOrAll(opArgs): seq[string] =
    ## Picks valid dirs from arguments or returns all valid git dirs if none given.
    let validDirs: seq[string] = getValidGitDirsNames()

    if opArgs.len() == 0:
        # Pull from all:
        result = validDirs
    else:
        # Pull only specified:
        for dir in opArgs:
            if dir in validDirs: result.add(dir)
    return result


proc pullCommandSync*(opArgs) =
    ## Pull command - pulls changes from origin synchronously.
    let dirs: seq[string] = opArgs.pickValidDirsOrAll() # .getUpdatableRepos()

    # Quit if no valid dirs:
    if dirs.len() == 0:
        echo "Nothing to do."
        quit(0)

    # cd into directories and pull changes:
    var status: ErrorStatus
    for dir in dirs:
        try:
            styledEcho fgYellow, &"Pulling {dir}...", fgDefault
            setCurrentDir(gitRepoPath & dir)
            let (succ, output) = GIT_PULL.execute()
            if succ == 0: status.successes += 1
            else: status.failures.add([dir, output])
        except OSError:
            status.failures.add([dir, "OSError"])

    stdout.write("\n")
    status.printAfterPull()


proc pullCommandAsync*(opArgs) =
    ## Pull command - pulls changes from origin asynchronously.
    let dirs: seq[string] = opArgs.pickValidDirsOrAll() # .getUpdatableRepos()

    # Quit if no valid dirs:
    if dirs.len() == 0:
        echo "Nothing to do."
        quit(0)

    # cd into directories and pull changes:
    proc pullDir(gitRepoPath, dir: string): ErrorStatus {.gcsafe.} =
        proc printSuccess(success: bool) =
            # This is a race condition, but i cant use locks... :(
            # TODO: find a fix for this
            case success:
            of true: stdout.styledWrite fgGreen, "-", fgDefault
            of false: stdout.styledWrite fgRed, "X", fgDefault
        try:
            #styledEcho fgYellow, &"Pulling {dir}...", fgDefault
            setCurrentDir(gitRepoPath & dir)
            let (status, output) = GIT_PULL.execute()
            if status == 0:
                result.successes += 1
                printSuccess(true)
            else:
                result.failures.add([dir, output])
                printSuccess(false)
        except OSError:
            result.failures.add([dir, "OSError"])
            printSuccess(false)
        finally:
            stdout.flushFile()

    proc threadWatcher(tasks: Taskpool, gitRepoPath: string, dirs: seq[string]): ErrorStatus =
        var tempResults: seq[Flowvar[ErrorStatus]] = newSeq[Flowvar[ErrorStatus]](dirs.len())
        stdout.write "Repositories: [" & ".".repeat(dirs.len()) & "]\r"
        stdout.write "Repositories: ["
        stdout.flushFile()
        for i, dir in dirs:
            tempResults[i] = tasks.spawn pullDir(gitRepoPath, dir)
        for i, _ in tempResults:
            let newResult: ErrorStatus = sync tempResults[i]
            result.successes += newResult.successes
            result.failures &= newResult.failures

    var tasks: Taskpool = new Taskpool
    var status: ErrorStatus = tasks.threadWatcher(gitRepoPath, dirs)
    syncAll tasks
    shutdown tasks

    stdout.write("\n")
    status.printAfterPull()


proc installCommand*(opArgs) =
    ## Install command - executes install script from installation json-file.
    let
        installInstructions: Table[string, string] = readInstallConfigFile()
        dirs: seq[string] = opArgs.pickValidDirsOrAll()

    if dirs.len() == 0:
        echo &"Nothing to do. No valid install commands found in '{installJsonFile}'..."
        quit(1)

    var status: ErrorStatus
    for dir, command in installInstructions:
        let fullDir: string = gitRepoPath / dir
        try:
            fullDir.setCurrentDir()
        except OSError as e:
            echo &"Could not set current directory to '{fullDir}'. Reason: ({e.msg})"
            continue

        let (output, succ) = command.execCmdEx()
        if succ == 0: status.successes += 1
        else: status.failures.add([dir, output])
    status.printAfterInstall()


proc editInstallCommand*(_) =
    ## Edit install command - edits the install json-file.
    var editor: string
    if existsEnv("EDITOR"):
        editor = getEnv("EDITOR")
    else:
        stderr.write("No 'EDITOR' environment variable found.\nType the wished editor program name: ")
        editor = stdin.readLine()

    if editor == "":
        EDITOR_NOT_EXISTS.handleUsage("Editor variable 'EDITOR' not set or invalid!" &
            (when not(defined windows) and not(defined mingw):
                "\nYou can set it by adding 'export EDITOR=editor_name' in your profile file (for example: ~/.profile)!\n" &
                "For example: 'export EDITOR=vim', 'export EDITOR=micro', 'export EDITOR=nano'"
            else: ""
            )
        )
        quit(1)

    if not installJsonFile.fileExists():
        installJsonFile.writeFile("{}")

    let
        editorCommand: string = &"{editor} {installJsonFile}"
        exitCode: int = execShellCmd(editorCommand)
    echo (
        if exitCode == 0: "Successfully applied changes."
        else: &"Errors encountered ('{editorCommand}', exit code {exitCode}).\nPlease double-check if changes were written to disk!"
    )
