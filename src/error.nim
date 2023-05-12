import std/[strutils, strformat, terminal]

const
    help_io_text: string = "\nPlease check if you have needed permissions."
    see_help_text: string = "\nSee `help` for a list of valid args."

type
    ErrorType* = enum
        IO_FAILURE = "Failed to read/write from/to disk." & help_io_text,
        READ_ERROR = "Failed to read from disk." & help_io_text,
        WRITE_ERROR = "Failed to write to disk." & help_io_text,

        OPERATION_NONE = "No arguments provided." & see_help_text,
        OPERATION_UNKNOWN = "Invalid argument." & see_help_text,

        INVALID_ARGUMENTS_AMOUNT = "Invalid amounts of arguments."
    ErrorStatus* = object
        successes*: int
        failures*: seq[string]


proc handle*(error: ErrorType, msg: string = "(none provided)") =
    ## Panics at runtime with an error message.
    styledEcho fgRed, "An error occured during runtime!", fgDefault
    echo &"{$error}\n" &
        &"Details: {msg}"
    quit(1)


proc print(error: ErrorStatus, success_message, error_message: string) =
    styledEcho fgGreen, &"Successful {success_message}: {error.successes}", fgDefault
    if error.failures.len() != 0:
        styledEcho fgRed, &"Failed {error_message}:", fgDefault
        echo "\t" & error.failures.join("\n\t")

proc print_after_clone*(error: ErrorStatus) =
    error.print("clones", &"to clone from following {error.failures.len()} repositories")

proc print_after_pull*(error: ErrorStatus) =
    error.print("pulls", &"to pull changes from following {error.failures.len()} repositories")

proc print_after_remove*(error: ErrorStatus) =
    error.print("removes", &"to remove following {error.failures.len()} repositories")


