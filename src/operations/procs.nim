import os, strutils, strformat, options
import ../globals, ../fileio, types, gitcommands

using
    op_args: seq[string]
    _: seq[string]


proc helpCommand*(_) =
    var text: seq[string]
    for op in operations:
        var temp: seq[string] = @[
            &"{op.name}:",
            repeat('-', op.name.len() + 1),
            &"   {op.desc}"
        ]
        if op.alias.isSome():
            temp.add(&"   Also:\n   ↳ " & op.alias.get().join(", "))  # weird mish-mash of syntax because my highliter was weird
        text.add(temp.join("\n"))

    echo @[
        &"{PROJECT_NAME} v{PROJECT_VERSION}  -  by " & PROJECT_AUTHORS.join(", "),  # same here
        PROJECT_DESCRIPTION,
        &"Source: {PROJECT_WEBSITE}"
    ].join("\n")
    echo "\nArguments:"
    echo text.join("\n\n")


proc listCommand*(_) =
    echo get_valid_git_dirs_names().join("   ")


proc cloneCommand*(op_args) =
    var
        successes: seq[string]
        failures: seq[string]

    git_repo_path.setCurrentDir()
    for repo in op_args:
        let succ: int = GIT_CLONE.execute(repo)
        # Save successes and failures:
        if succ == 0: successes.add(repo)
        else: failures.add(repo)

    echo ""
    if successes.len() != 0:
        echo &"Successful clones: {successes.len()}"
    if failures.len() != 0:
        echo &"Failed clones: {failures.len()}"
        echo "\t" & failures.join("\n\t")


