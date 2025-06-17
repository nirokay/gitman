## Error module
## ============
##
## This module handles errors (by panicing) and removes repetitive
## printing of error messages.

import std/[strutils, strformat, terminal]

const
    helpIoText: string = "\nPlease check if you have the required permissions."
    seeHelpText: string = "\nSee `help` subcommand for a list of valid args."

type
    ErrorType* = enum
        IO_FAILURE = "Failed to read/write from/to disk." & helpIoText,
        READ_ERROR = "Failed to read from disk." & helpIoText,
        WRITE_ERROR = "Failed to write to disk." & helpIoText,

        EDITOR_NOT_EXISTS = "The provided editor does not exist or is not in path.",

        OPERATION_NONE = "No arguments provided." & seeHelpText,
        OPERATION_UNKNOWN = "Invalid argument." & seeHelpText,

        INVALID_ARGUMENTS_AMOUNT = "Invalid amounts of arguments."
    ErrorStatus* = object
        successes*: int
        failures*: seq[array[2, string]]


proc handleException*(error: ErrorType, msg: string = "", code: int = 1) =
    ## Panics at runtime with an error message.
    var complaint: string = case code:
        of 1: "An error occurred during runtime!"
        of 2: "Incorrect usage."
        else: ""
    if complaint != "": styledEcho fgRed, complaint, fgDefault
    echo $error
    if msg != "": echo &"Details: {msg}"
    quit(code)

proc handleUsage*(error: ErrorType, msg: string = "", code: int = 2) =
    ## Panics at runtime with an error message.
    error.handleException(msg, code)

proc print(error: ErrorStatus, successMessage, errorMessage: string) =
    styledEcho fgGreen, &"Successful {successMessage}: {error.successes}", fgDefault
    if error.failures.len() != 0:
        styledEcho fgRed, &"Failed {errorMessage}:", fgDefault
        for info in error.failures:
            let
                repository: string = info[0]
                reason: string = info[1]
            styledEcho fgYellow, &" * Repository '{repository}', reason being:", fgDefault
            styledEcho reason.strip().indent(5), "\n"

proc printAfterClone*(error: ErrorStatus) =
    error.print("clones", &"to clone from following {error.failures.len()} repositories")

proc printAfterPull*(error: ErrorStatus) =
    error.print("pulls", &"to pull changes from following {error.failures.len()} repositories")

proc printAfterRemove*(error: ErrorStatus) =
    error.print("removes", &"to remove following {error.failures.len()} repositories")

proc printAfterInstall*(error: ErrorStatus) =
    error.print("installs", &"to install following {error.failures.len()} repositories")
