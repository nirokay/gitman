## Operation defs module
## =====================
##
## This module contains all `Operation` definitions. Operations are called
## by the user by passing arguments like `clone`, `pull`, `install`, ...

import std/options
import types, procs

proc add(op: Operation) =
    ## Shortcut for adding operations to the `operations` sequence.
    operations.add(op)



# -----------------------------------------------------------------------------
# Definitions:
# -----------------------------------------------------------------------------

add Operation(
    name: "help",
    desc: "Displays this help message.",
    alias: none seq[string],
    call: helpCommand
)

add Operation(
    name: "clone",
    desc: "Clones new git repository to repo directory.",
    alias: some @["add", "download", "get"],
    args_range: some [1.Natural, 9999.Natural],
    call: cloneCommand
)

add Operation(
    name: "pull",
    desc: "Pulls changes for every git repo synchronously.",
    alias: some @["update"],
    args_range: some [0.Natural, 9999.Natural],
    call: pullCommandSync
)

add Operation(
    name: "async-pull",
    desc: "Pulls changes for every git repo asynchronously.",
    alias: some @["async-update"],
    args_range: some [0.Natural, 9999.Natural],
    call: pullCommandAsync
)

add Operation(
    name: "remove",
    desc: "Removes git repository from repo directory.",
    alias: some @["delete", "rm", "del"],
    args_range: some [1.Natural, 9999.Natural],
    call: removeCommand
)

add Operation(
    name: "list",
    desc: "Displays names of all clones git repositories.",
    alias: none seq[string],
    call: listCommand
)

add Operation(
    name: "install",
    desc: "Executes a specified install script for the repository.",
    alias: none seq[string],
    args_range: some [0.Natural, 9999.Natural],
    call: installCommand
)

add Operation(
    name: "edit-install",
    desc: "Lets you quickly edit the install json file.",
    alias: some @["edit"],
    call: editInstallCommand
)
