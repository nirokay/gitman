import terminal

type ExitCode* = object
    code*: int
    origin*: string

proc getFromString*(exitCodes: seq[ExitCode], str: string): ExitCode =
    for exitCode in exitCodes:
        if exitCode.origin == str:
            return exitCode
    return ExitCode()

proc filterOut*(exitCodes: seq[ExitCode], code: int): seq[ExitCode] =
    for exitCode in exitCodes:
        if exitCode.code != code: result.add(exitCode)
    return result

proc filterOnly*(exitCodes: seq[ExitCode], code: int): seq[ExitCode] =
    for exitCode in exitCodes:
        if exitCode.code == code: result.add(exitCode)
    return result

proc concat*(exitCodes: seq[ExitCode]) =
    for id, exitCode in exitCodes:
        styledEcho fgDefault, "\t", $(id+1), ". ", fgYellow, "exit code ", $exitCode.code, " on '", exitCode.origin, fgDefault, "'!"
