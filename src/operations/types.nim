## Operation types module
## ======================
##
## Contains typedefs and global variables.

import std/[strformat, options]
import ../error

type Operation* = object
    name*, desc*: string
    alias*: Option[seq[string]]
    argsRange*: Option[array[2, Natural]]
    call*: proc(opArgs: seq[string])

var operations*: seq[Operation]

proc operationFromString*(str: string): Option[Operation] =
    ## Parses command-line arg string to Operation, or not...
    for op in operations:
        # Direct call:
        if op.name == str: return some op

        # Alias call:
        if op.alias.isNone(): continue
        for alias in op.alias.get():
            if alias != str: continue
            return some op

    return none Operation

proc checkValidRange*(op: Operation, operationArgs: seq[string]) =
    ## Checks if the provided args for a command are in the valid range.
    # No-Arg operations handler:
    if op.argsRange.isNone():
        if operationArgs.len() == 0: return
        else: INVALID_ARGUMENTS_AMOUNT.handleUsage(&"No arguments expected, got {operationArgs.len()} instead.")

    # Set-Arg operations handler:
    let r: array[2, Natural] = op.argsRange.get()
    if operationArgs.len() notin r[0]..r[1]:
        INVALID_ARGUMENTS_AMOUNT.handleUsage(&"Expected between {r[0]} and {r[1]} arguments, got {operationArgs.len()} instead.")
