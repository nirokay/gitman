import os, osproc, terminal, strutils
import operations, exitCodes, utils

proc helpCommand*(list: seq[Operation]) =
    echo "List of valid operations:\n"
    for id, op in list:
        styledEcho fgYellow, op.name, "\n", fgDefault,
            "\t", op.description, "\n",
            "\talso: ", concatSeq(op.aliases, ", "), "\n"

        if op.usage != "":
            styledEcho "\tUsage: ", op.usage
        echo ""

proc listRepositoriesCommand*(dirs: seq[string]) =
    var dirsCleaned: seq[string]
    for dir in dirs:
        var str: string = dir.removeParents()
        dirsCleaned.add(str)

    var text: string = dirsCleaned.concatSeq("   ")
    styledEcho "List of git directories visible to this program:\n", fgYellow, text, fgDefault

proc removeRepositoryCommand*(args: seq[string], gitDir: string) =
    var toRemoveDirRaw: string
    try:
        toRemoveDirRaw = args[2]
    except Defect:
        echo "You have to provide a repository name as argument."
        quit(1)

    var toRemoveDir: string = gitDir & toRemoveDirRaw
    if not toRemoveDir.dirExists():
        styledEcho fgRed, "Cannot find repository '", fgYellow, toRemoveDir, fgRed, "' to remove!", fgDefault
        quit(1)

    # Remove directory:
    case promptUserInput("Are you sure you want to permanently remove '" & toRemoveDir & "'? [y/n]").strip.toLower():
    of "y", "yes":
        # Attempt removing directory:
        echo "Removing directory..."
        try:
            toRemoveDir.removeDir()
            echo "Successfully removed directory!"
            quit(0)
        except OSError:
            echo "Could not remove directory '" & toRemoveDir & "'!"
            quit(1)

    else:
        echo "Aborting."
        quit(1)

proc cloneCommand*(options: seq[string], gitDirectory: string) =
    var url: string
    var pwd: string = getCurrentDir()
    try:
        url = options[2]
    except Exception:
        echo "You have to specify a valid url as an argument."
        quit(1)
    
    setCurrentDir(gitDirectory)
    let exitCode: int = execCmd("git clone " & url)
    setCurrentDir(pwd)
    quit(exitCode)

proc pullCommand*(dirs: seq[string]) =
    var
        pwd: string = getCurrentDir()
        exitCodes: seq[ExitCode]

    for dir in dirs:
        setCurrentDir(dir)
        styledEcho fgYellow, "\n🠗 Pulling git directory at '", dir, "'!", fgDefault

        # Exit Code stuff:
        var
            code: int = execCmd("git pull")
            col: ForegroundColor
            status: string
        
        if code == 0:
            col = fgGreen
            status = "✓"
        else:
            col = fgRed
            status = "×"

        styledEcho col, status, " Finished pulling '", dir, "' with exit code ", $code, "!\n", fgDefault
        exitCodes.add(ExitCode(
            origin: dir,
            code: code
        ))

    setCurrentDir(pwd)

    # Print out exit information:
    var
        succ: seq[ExitCode] = exitCodes.filterOnly(0)
        fail: seq[ExitCode] = exitCodes.filterOut(0)

    styledEcho "This process ended with a total of ",
        fgGreen, $succ.len, " successful action(s)", fgDefault, " and ",
        fgred, $fail.len, " failed action(s)", fgDefault, "!"

    if fail.len > 0:
        echo "Failues with these repositories:"
        fail.concat()
