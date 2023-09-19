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

* `install`: Executes installation commands specified in the installation json file (defualt: `$GITMAN_REPOS_LOCATION/.gitman-install.json`).

  **Example:** `gitman install` (executes install instructions on every repository)

Some commands may also have aliases, see `help` for more information.

## Installation

You will need to have [Nim](https://nim-lang.org) installed, as well as its package-manager nimble.

**Note:**

If you are using `nimble install`, make sure the nimble/bin directory is in your path (default: `~/.nimble/bin/`)!

### nimble

`nimble install gitman`

### Compiling manually from source

Clone the repository and run `nimble build -d:release` to compile or `nimble install` to compile and install it to the nimble/bin directory.

You can also set some compile-time flags to customise your the program to your liking.

**List of compile-time flags:**

* `environment_variable` (default: `GITMAN_REPOS_LOCATION`)

  This sets the environment variable the program uses.

* `gitman_install_file` (default: `.gitman-install.json`)

  Changes the installation json-file name.

**Usage:**

When compiling add the `-d:` flag. For example:

* `nimble build -d:environment_variable:NEW_ENV_VARIABLE`
* `nimble build -d:gitman_install_file:new_file_name.json`
* `nimble build -d:environment_variable:NEW_ENV_VARIABLE -d:gitman_install_file:new_file_name.json`

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

## Supported Operating Systems

Any operating system that is supported by the [nim programming language](https://nim-lang.org) should be supported.

This program was tested on GNU/Linux (Manjaro) and Windows 10 (64 bit).

## Dependancies

* [git](https://git-scm.com/)

* [Nim](https://nim-lang.org) (not required to run the binary, only for compiling and installing through nimble)
