# Changes

## 2.3.1

* Fixes to grammar and other text stuff
* Added version command
* Added more aliases for certain commands
* Build script strips debug information from executable for smaller binaries


## 2.3.0

Printout of git error message upon failure of git operation.

## 2.2.1

`list` command printout reworked and some small bugfixes.

## 2.2.0

Added new command `async-pull`, a multithreaded `pull`.

## 2.1.0

Added support for installation scripts on a repo-to-repo basis.

## 2.0.1

Streamlined feedback after clones, pulls and removed.

## 2.0.0

Entire codebase rewritten to be more manageable and cleaner.

Behaviour:

* commands like `pull`, `clone` and `remove` can now accept multiple arguments (invalid args will be filtered in certain scenarios)

## 1.0.1

Behaviour:

* added Makefile (linux install only)
* more, much more, EVEN MORE coloured output
* changed default unix config directory to respect custom configs set via path variable

Commands:

* improved help command
* added list command
* added remove command

## 1.0.0

* initial commit
