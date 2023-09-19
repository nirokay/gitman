import std/options
import types, procs

proc add(op: Operation) =
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
    desc: "Pulls changes for every git repo.",
    alias: some @["update"],
    args_range: some [0.Natural, 9999.Natural],
    call: pullCommand
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
    call: installCommand
)

add Operation(
    name: "edit-install",
    desc: "Lets you quickly edit the install json file.",
    alias: some @["edit"],
    call: editInstallCommand
)
