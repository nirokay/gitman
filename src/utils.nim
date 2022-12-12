import os

proc promptUserInput*(question: string = "User input"): string =
    stdout.write(question & " ")
    return stdin.readLine()

proc concatSeq*[T](s: seq[T], sep: string): string =
    for i, v in s:
        if i != 0: result.add(sep)
        result.add($v)
    return result

proc removeParents*(str: string): string =
    var s: string = str
    while true:
        result = s
        s = s.tailDir()
        if s == "": break
    return result

