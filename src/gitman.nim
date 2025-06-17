## gitman -Main executable file
## ============================
##
## This module is the main executable entry point.

import std/[strutils, options]
import globals, operations_import, error

from fileio import confirmRepoDir

when isMainModule:
    # Argument parsing:
    if args.len() == 0: OPERATION_NONE.handleUsage()
    let request: Option[Operation] = args[0].toLower().operationFromString()
    if request.isNone(): OPERATION_UNKNOWN.handleUsage(args[0])

    # Operation calling:
    let
        operation: Operation = request.get()
        operationArgs: seq[string] = args[1..^1]

    operation.checkValidRange(operationArgs)
    confirmRepoDir()
    operation.call(operationArgs)
