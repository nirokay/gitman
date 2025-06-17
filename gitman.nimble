# Package

version       = "2.3.1"
author        = "nirokay"
description   = "A git-repo manager that lets you easily update multiple git repositories in a specified directory."
license       = "GPL-3.0-only"
srcDir        = "src"
bin           = @["gitman"]


# Dependencies

requires "nim >= 2.0.0"
requires "taskpools"
