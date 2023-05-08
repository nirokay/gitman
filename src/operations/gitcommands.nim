import os, strutils, strformat

const git_executable: string =
    when defined(windows): "git.exe"
    else: "git"

type GitCommand* = enum
    GIT_CLONE = "clone",
    GIT_PULL = "pull"

proc execute*(command: GitCommand, args: string = ""): int =
    ## Runs `git [command] ?[args]` in shell.
    let full_command = strip(&"{git_executable} {$command} {args}")
    return full_command.execShellCmd()

