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
    environmentVariable {.strdefine.}: string = "GITMAN_REPOS_LOCATION"
    gitmanInstallFile {.strdefine.}: string = ".gitman-install.json"

let defaultGitRepoPath: string = getHomeDir() & "Git/"

let gitRepoPath*: string =
    if existsEnv(environmentVariable): getEnv(environmentVariable)
    else:
        putEnv(environmentVariable, defaultGitRepoPath)
        defaultGitRepoPath & "/"

let installJsonFile*: string = gitRepoPath & gitmanInstallFile



# -----------------------------------------------------------------------------
# Dir procs:
# -----------------------------------------------------------------------------

proc confirmRepoDir*() =
    try:
        if not gitRepoPath.dirExists():
            gitRepoPath.createDir()
    except OSError:
        WRITE_ERROR.handle(gitRepoPath)


proc getValidGitDirsPaths*(): seq[string] =
    confirmRepoDir()
    for dir in gitRepoPath.walkDir(false):
        if dir.kind != pcDir and dir.kind != pcLinkToDir: continue
        if dirExists(&"{$dir.path}/.git/"): result.add(dir.path)
    return result

proc getValidGitDirsNames*(): seq[string] =
    for dir in getValidGitDirsPaths():
        result.add(dir.splitPath().tail)
    return result

proc removeGitDirs*(dirs: seq[string]): ErrorStatus =
    ## Removes all directories and returns amount of successes and a sequence of failed directories
    for dir in dirs:
        try:
            removeDir(gitRepoPath & dir)
            result.successes += 1
        except OSError:
            result.failures.add([dir, "OSError"])

proc initInstallJson() =
    ## Makes sure the file for gitman installations is present.
    if installJsonFile.fileExists(): return
    installJsonFile.writeFile("{}")

proc readInstallConfigFile*(): Table[string, string] =
    initInstallJson()
    var jsonInstall: JsonNode
    try:
        let raw_json: string = installJsonFile.readFile()
        jsonInstall = raw_json.parseJson()
    except JsonParsingError:
        styledEcho fgRed, &"Failed to parse '{installJsonFile}' json file. Is it valid json?", fgDefault
        quit(1)

    # Add only strings to JsonNode:
    for repo, command in jsonInstall:
        if command.kind != JString: continue
        result[$repo] = command.str
