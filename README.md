# gitman - Git Repository Manager

Have you been cloning git repositories left and right? Do you wish to keep them automatically up-to date?

gitman is a cross-platform manager for git repositories, that are located inside a single directory.

## Usage

Arguments:

* `clone [url: string]`: Clones one or more git repositories to the git repository directory. (urls seperated by spaces)
  **Example:** `gitman clone https://github.com/nirokay/gitman https://github.com/nirokay/nirokay`

* `pull`: Pulls every repository's changes, or only the ones which names are provided.
  **Examples:** `gitman pull` (pulls all repos), `gitman pull gitman nirokay` (only pulls gitman and nirokay repo)

* `help`: Displays a help message.

* `remove [dir: string]`: Removes the specified directory inside the git-repo directory. Can accept mutliple directories to remove.
  **Example:** `gitman remove nirokay gitman`

* `list`: Lists all git repositories.

Some commands may also have aliases, see `help` for more information.

## Configuration

There are no configuration files for this program (anymore). You can set a custom git directory by changing the `GITMAN_REPOS_LOCATION` environment variable.

**Example (Linux):**

```bash
export GITMAN_REPOS_LOCATION="$HOME/Git"
```

**Note:**

This will only be available for the current session. Consider putting the string above into your profile/shell rc file.

## Changes

See [Changes](CHANGES.md) document.

## Installation

You will need to have [Nim](https://nim-lang.org) installed, as well as its package-manager nimble.

### nimble installation

You can run `nimble install gitman` to automatically install this program. (SOON!)

### Compiling from source

You can build this program with `nimble build` and move the executable in your path. The latter will be done automatically, if you execute `nimble install` (Verify that the nimble binary directory is in your path!).

## Supported Operating Systems

Any operating system that is supported by the [nim programming language](https://nim-lang.org) should be supported.

This program was tested on GNU/Linux (Manjaro) and Windows 10 (64 bit).

## Dependancies

* [git](https://git-scm.com/)

* [Nim](https://nim-lang.org) (not required to run the binary, only for compiling and installing through nimble)
