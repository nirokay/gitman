import std/[strformat, options]
import ../error

type Operation* = object
    name*, desc*: string
    alias*: Option[seq[string]]
    args_range*: Option[array[2, Natural]]
    call*: proc(op_args: seq[string])

var operations*: seq[Operation]

proc operation_from_string*(str: string): Option[Operation] =
    for op in operations:
        # Direct call:
        if op.name == str: return some op

        # Alias call:
        if op.alias.isNone(): continue
        for alias in op.alias.get():
            if alias != str: continue
            return some op

    return none Operation

proc check_valid_range*(op: Operation, operation_args: seq[string]) =
    # No-Arg operations handler:
    if op.args_range.isNone():
        if operation_args.len() == 0: return
        else: INVALID_ARGUMENTS_AMOUNT.handle(&"No arguments expected, got {operation_args.len()} instead.")

    # Set-Arg operations handler:
    let r: array[2, Natural] = op.args_range.get()
    if operation_args.len() notin r[0]..r[1]:
        INVALID_ARGUMENTS_AMOUNT.handle(&"Expected between {r[0]} and {r[1]} arguments, got {operation_args.len()} instead.")



