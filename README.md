# gitman - Git Repository Manager

Have you been cloning git repositories left and right? Do you wish to keep them automatically up-to date?

gitman is a manager for git repositories, that are located inside a single directory.

## Usage

There are several commands currently supported.

* `clone [url: string]`: Clones a git repository to the git repository directory.

* `pull`: Pulls every repository's changes.

* `help`: Displays a help message.

* `remove [dir: string]`: Removes the specified directory inside the git-repo directory.

* `list`: Lists all git repositories.

Some commands may also have aliases, see `help` for more information.

## Changes

See [Changes](CHANGES.md) document.

## Supported Operating Systems

Any operating system that is supported by the [nim programming language](https://nim-lang.org) should be supported.

This program was tested on GNU/Linux (Manjaro) and Windows 10 (64 bit).

## Compiling from source

You will need to have [nim](https://nim-lang.org) installed, as well as its package-manager nimble. You can easily build this program by executing `nimble build` or use the Makefile `make build`.

If you are running a Linux system, you can install the program with `sudo make install` to `/usr/local/bin/`.

## Dependancies

* git (installed and in your environment path *cough cough windows... cough cough*)

* nim (not required to run the binary, only for compiling)
