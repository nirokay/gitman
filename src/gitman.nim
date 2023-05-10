import std/[strutils, options]
import globals, operations_import, error

from fileio import confirm_repo_dir

when isMainModule:
    # Argument parsing:
    if args.len() == 0: OPERATION_NONE.handle()
    let request: Option[Operation] = args[0].toLower().operation_from_string()
    if request.isNone(): OPERATION_UNKNOWN.handle(args[0])

    # Operation calling:
    let
        operation: Operation = request.get()
        operation_args: seq[string] = args[1..^1]

    operation.check_valid_range(operation_args)
    confirm_repo_dir()
    operation.call(operation_args)


