## Globals
## =======
##
## This module includes a couple of global variables.
##
## Most of them are just package information.

from std/os import commandLineParams

const
    PROJECT_NAME*: string = "gitman"
    PROJECT_VERSION*: string = "2.1.2"
    PROJECT_WEBSITE*: string = "https://github.com/nirokay/gitman/"
    PROJECT_DESCRIPTION*: string = "A git-repo manager that lets you easily update multiple git repositories in a specified directory."
    PROJECT_AUTHORS*: seq[string] = @["nirokay"]

let
    args*: seq[string] = commandLineParams()

