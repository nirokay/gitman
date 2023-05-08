import strutils, strformat, options
import ../globals, types


proc helpCommand*() =
    var text: seq[seq[string]]
    for op in operations:
        var temp: seq[string] = @[
            &"{op.name}:",
            repeat('-', op.name.len() + 1),
            &"\t{op.desc}"
        ]
        if op.alias.isSome():
            temp.add("""\tAlso:\n\t {op.alias.get().join("\t")}""")
        text.add(temp)

    echo @[
        &"{PROJECT_NAME} v{PROJECT_VERSION}",
        PROJECT_DESCRIPTION,
        &"""by {PROJECT_AUTHORS.join(", ")}""",
        &"Source: {PROJECT_WEBSITE}"
    ].join("\n")
    echo "\nArguments:"
    echo text.join("\n\n")






