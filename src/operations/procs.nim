import strutils, strformat, options
import ../globals, ../fileio, types

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
            temp.add(&"   Also:\n     {op.alias.get().join(\"   \")}")
        text.add(temp.join("\n"))

    echo @[
        &"{PROJECT_NAME} v{PROJECT_VERSION}",
        PROJECT_DESCRIPTION,
        &"""by {PROJECT_AUTHORS.join(", ")}""",
        &"Source: {PROJECT_WEBSITE}"
    ].join("\n")
    echo "\nArguments:"
    echo text.join("\n\n")


proc listCommand*(_) =
    echo get_valid_git_dirs_names().join("   ")




