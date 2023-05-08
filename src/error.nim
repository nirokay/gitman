import strutils, strformat, terminal

const
    help_io_text: string = "\nPlease check if you have needed permissions."

type ErrorType* = enum
    IO_FAILURE = "Failed to read/write from/to disk." & help_io_text,
    READ_ERROR = "Failed to read from disk." & help_io_text,
    WRITE_ERROR = "Failed to write to disk." & help_io_text


proc handle*(error: ErrorType, msg: string = "(none provided)") =
    styledEcho fgRed, "An error occured during runtime!", fgDefault
    echo &"{$error}\n" &
        &"Details: {msg}"
    quit(1)

