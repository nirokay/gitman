
proc promptUserInput*(question: string): string =
    stdout.write(question & " ")
    return stdin.readLine()
