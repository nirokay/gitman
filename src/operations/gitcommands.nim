## Git commands module
## ===================
##
## This module contains external git commands, that are passed to git through
## the shell.

import std/[os, osproc, strutils, strformat]

const git_executable: string =
    when defined(windows): "git.exe"
    else: "git"

type GitCommand* = enum
    GIT_CLONE = "clone",
    GIT_PULL = "pull",
    GIT_CHECK_UPDATES = "fetch --dry-run"

proc execute*(command: GitCommand, args: string = ""): (int, string) =
    ## Runs `git [command] ?[args]` in shell.
    ##
    ## Returns the status code and command output.
    let fullCommand = strip(&"{git_executable} {$command} {args}")
    let (output, exit) = fullCommand.execCmdEx()
    return (exit, output)

proc executeOld*(command: GitCommand, args: string = ""): int {.deprecated.} =
    let (status, _) = command.execute(args)
    return status
