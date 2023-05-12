import std/[os, strutils, strformat, options, terminal]
import ../globals, ../fileio, ../error, types, gitcommands

using
    op_args: seq[string]
    _: seq[string]


proc helpCommand*(_) =
    var text: seq[string]
    for op in operations:
        var temp: seq[string] = @[
            &"{op.name}:",
            repeat('-', op.name.len() + 1),
            &"   {op.desc}"
        ]
        if op.alias.isSome():
            temp.add(&"   Also:\n   ↳ " & op.alias.get().join(", "))  # weird mish-mash of syntax because my highliter was weird
        text.add(temp.join("\n"))

    echo @[
        &"{PROJECT_NAME} v{PROJECT_VERSION}  -  by " & PROJECT_AUTHORS.join(", "),  # same here
        PROJECT_DESCRIPTION,
        &"Source: {PROJECT_WEBSITE}"
    ].join("\n")
    echo "\nArguments:"
    echo text.join("\n\n")


proc listCommand*(_) =
    echo get_valid_git_dirs_names().join("   ")


proc cloneCommand*(op_args) =
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


proc pullCommand*(op_args) =
    let valid_dirs: seq[string] = get_valid_git_dirs_names()
    let dirs: seq[string] =
        if op_args.len() == 0:
            # Pull from all:
            valid_dirs
        else:
            # Pull only specified:
            var additions: seq[string]
            for dir in op_args:
                if dir in valid_dirs: additions.add(dir)
            additions

    # Quit if no valid dirs:
    if dirs.len() == 0:
        echo "No valid repository directories found."
        quit(1)
    
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


