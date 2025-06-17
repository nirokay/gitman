## Operation defs module
## =====================
##
## This module contains all `Operation` definitions. Operations are called
## by the user by passing arguments like `clone`, `pull`, `install`, ...

import std/options
import types, procs

const
    argsZero: Natural = 0
    argsOne: Natural = 1
    argsMax: Natural = 9999

proc add(op: Operation) =
    ## Shortcut for adding operations to the `operations` sequence.
    operations.add(op)


# -----------------------------------------------------------------------------
# Definitions:
# -----------------------------------------------------------------------------

add Operation(
    name: "help",
    desc: "Displays this help message.",
    alias: some @["h", "--help", "-h", "?", "-?"],
    call: helpCommand
)

add Operation(
    name: "version",
    desc: "Displays program version.",
    alias: some @["v", "--version", "-v"],
    call: versionCommand
)

add Operation(
    name: "clone",
    desc: "Clones new git repository to repo directory.",
    alias: some @["add", "download", "get"],
    args_range: some [argsOne, argsMax],
    call: cloneCommand
)

add Operation(
    name: "pull",
    desc: "Synchronously Pulls changes for every git repo.",
    alias: some @["update"],
    args_range: some [argsZero, argsMax],
    call: pullCommandSync
)

add Operation(
    name: "async-pull",
    desc: "Asynchronously pulls changes for every git repo.",
    alias: some @["async-update"],
    args_range: some [argsZero, argsMax],
    call: pullCommandAsync
)

add Operation(
    name: "remove",
    desc: "Removes git repository from repo directory.",
    alias: some @["delete", "rm", "del"],
    args_range: some [argsZero, argsMax],
    call: removeCommand
)

add Operation(
    name: "list",
    desc: "Displays names of all clones git repositories.",
    alias: some @["ls"],
    call: listCommand
)

add Operation(
    name: "install",
    desc: "Executes a specified install script for the repository.",
    alias: none seq[string],
    args_range: some [argsZero, argsMax],
    call: installCommand
)

add Operation(
    name: "edit-install",
    desc: "Lets you quickly edit the install json file.",
    alias: some @["edit"],
    call: editInstallCommand
)
