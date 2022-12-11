import os, osproc, terminal
import operations, exitCodes

proc helpCommand*(list: seq[Operation]) =
    echo "Here is a list of all operations:"
    for id, op in list:
        var text: seq[string] = @[
            op.name,
            "  (also: " & $op.aliases & ")",
            "  " & op.description,
            "\n  Usage:" & $op.usage & "\n"
        ]
        for line in text: echo line

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
