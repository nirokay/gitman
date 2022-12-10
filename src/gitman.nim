import os, strutils
import configfile, operations

const applicationIdentity*: string = "gitman-manager"

# Path to config directory:
var configDirectory*: string
if defined linux:
    configDirectory = getHomeDir() & ".config/" & applicationIdentity & "/"
elif defined windows:
    configDirectory = getHomeDir() & "AppData/Local/" & applicationIdentity & "/"
else:
    configDirectory = getHomeDir() & applicationIdentity & "/"


# Config Files:
setConfigFilePath(configDirectory)
let ConfigFiles: array[1, ConfigFile] = [
    newConfigFile("gitRepositoryDirectory", getHomeDir() & "git")
]

# Validate Files:
for id, file in ConfigFiles:
    if fileExists(file.fileName): continue

    # File non-existant:
    if not file.writeData(file.defaultData):
        echo "Could not write to file '" & file.fileName & "'!"

# Read Config Files:
let gitDir: string = ConfigFiles[0].readData().strip()


# Read Git Directory:
proc getDirectoryDirectories(dir: string): seq[string] = 
    var dirs: seq[string]
    for kind, path in walkDir(dir):
        case kind:
        of pcDir, pcLinkToDir:
            dirs.add(path)
        else:
            discard
    return dirs

proc filterGitDirectories(dirs: seq[string]): seq[string] =
    var gitDirs: seq[string]
    for dir in dirs:
        if dirExists(dir & "/.git/"):
            gitDirs.add(dir)
    return gitDirs

# List of all valid git directories in the git-repo directory:
var validGitDirectories: seq[string] = getDirectoryDirectories(gitDir).filterGitDirectories()

echo validGitDirectories
