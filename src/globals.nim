## Globals
## =======
##
## This module includes a couple of global variables.
##
## Most of them are just package information.

# Project information:
const
    PROJECT_NAME*: string = "gitman"
    PROJECT_VERSION*: string = "2.3.1"
    PROJECT_WEBSITE*: string = "https://github.com/nirokay/gitman/"
    PROJECT_DESCRIPTION*: string = "A git-repo manager that lets you easily update multiple git repositories in a specified directory."
    PROJECT_AUTHORS*: seq[string] = @["nirokay"]

# Compilation information:
const
    PROJECT_COMPILE_TIME* {.strdefine.}: string = "unspecified time"
    PROJECT_COMPILE_NIM_VERSION*: string = NimVersion

# Arguments:
from std/os import commandLineParams
let args*: seq[string] = commandLineParams() ## Runtime arguments
