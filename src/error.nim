import strformat, terminal

const
    help_io_text: string = "\nPlease check if you have needed permissions."
    see_help_text: string = "\nSee `help` for a list of valid args."

type ErrorType* = enum
    IO_FAILURE = "Failed to read/write from/to disk." & help_io_text,
    READ_ERROR = "Failed to read from disk." & help_io_text,
    WRITE_ERROR = "Failed to write to disk." & help_io_text,

    OPERATION_NONE = "No arguments provided." & see_help_text,
    OPERATION_UNKNOWN = "Invalid argument." & see_help_text,

    INVALID_ARGUMENTS_AMOUNT = "Invalid amounts of arguments."


proc handle*(error: ErrorType, msg: string = "(none provided)") =
    ## Panics at runtime with an error message.
    styledEcho fgRed, "An error occured during runtime!", fgDefault
    echo &"{$error}\n" &
        &"Details: {msg}"
    quit(1)

