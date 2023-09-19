## FileIO module
## =============
##
## This module contains basic file io procs, such as creating
## directories and getting directory names etc.

import std/[os, strformat, json, tables, terminal]
import error

# -----------------------------------------------------------------------------
# Git repo location:
# -----------------------------------------------------------------------------

const
    environment_variable {.strdefine.}: string = "GITMAN_REPOS_LOCATION"
    gitman_install_file {.strdefine.}: string = ".gitman-install.json"

let default_git_repo_path: string = getHomeDir() & "Git/"

let git_repo_path*: string =
    if existsEnv(environment_variable): getEnv(environment_variable)
    else:
        putEnv(environment_variable, default_git_repo_path)
        default_git_repo_path & "/"

let install_json_file*: string = git_repo_path & gitman_install_file



# -----------------------------------------------------------------------------
# Dir procs:
# -----------------------------------------------------------------------------

proc confirm_repo_dir*() =
    try:
        if not git_repo_path.dirExists():
            git_repo_path.createDir()
    except OSError:
        WRITE_ERROR.handle(git_repo_path)


proc get_valid_git_dirs_paths*(): seq[string] =
    confirm_repo_dir()
    for dir in git_repo_path.walkDir(false):
        if dir.kind != pcDir and dir.kind != pcLinkToDir: continue
        if dirExists(&"{$dir.path}/.git/"): result.add(dir.path)
    return result

proc get_valid_git_dirs_names*(): seq[string] =
    for dir in get_valid_git_dirs_paths():
        result.add(dir.splitPath().tail)
    return result

proc remove_git_dirs*(dirs: seq[string]): ErrorStatus =
    ## Removes all directories and returns amount of successes and a sequence of failed directories
    for dir in dirs:
        try:
            removeDir(git_repo_path & dir)
            result.successes += 1
        except OSError:
            result.failures.add(dir)

proc init_install_json() =
    ## Makes sure the file for gitman installations is present.
    if install_json_file.fileExists(): return
    install_json_file.writeFile("{}")

proc read_install_config_file*(): Table[string, string] =
    init_install_json()
    var json_install: JsonNode
    try:
        let raw_json: string = install_json_file.readFile()
        json_install = raw_json.parseJson()
    except JsonParsingError:
        styledEcho fgRed, &"Failed to parse '{install_json_file}' json file. Is it valid json?", fgDefault
        quit(1)

    # Add only strings to JsonNode:
    for repo, command in json_install:
        if command.kind != JString: continue
        result[$repo] = command.str


