## Git commands module
## ===================
##
## This module contains external git commands, that are passed to git through
## the shell.

import std/[os, strutils, strformat]

const git_executable: string =
    when defined(windows): "git.exe"
    else: "git"

type GitCommand* = enum
    GIT_CLONE = "clone",
    GIT_PULL = "pull",
    GIT_CHECK_UPDATES = "fetch --dry-run"

proc execute*(command: GitCommand, args: string = ""): int =
    ## Runs `git [command] ?[args]` in shell.
    let full_command = strip(&"{git_executable} {$command} {args}")
    return full_command.execShellCmd()

