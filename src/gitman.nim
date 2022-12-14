import os, strutils, terminal
import configfile, operations

const applicationIdentity*: string = "gitman-manager"

# Get terminal arguments:
var args: seq[string]
for i in 0..paramCount():
    args.add(paramStr(i))


# Path to config directory:
var configDirectory*: string
if defined macosx:
    configDirectory = getHomeDir() & "Library/Preferences/" & applicationIdentity & "/"

elif defined(linux) or defined(posix):
    configDirectory = getConfigDir() & applicationIdentity & "/"

elif defined windows:
    configDirectory = getHomeDir() & "AppData/Local/" & applicationIdentity & "/"

else:
    configDirectory = getHomeDir() & applicationIdentity & "-config/"


# Config Files:
setConfigFilePath(configDirectory)
let ConfigFiles: array[1, ConfigFile] = [
    newConfigFile("gitRepositoryDirectory", getHomeDir() & "git/")
]

# Validate Files:
for id, file in ConfigFiles:
    if fileExists(file.fileName): continue

    # File non-existant:
    echo "Creating config file at '" & file.fileName & "'!"
    if not file.writeData(file.defaultData):
        echo "Could not write to file '" & file.fileName & "'!"

# Read Config Files:
let gitDir: string = ConfigFiles[0].readData().strip()
if not gitDir.dirExists():
    styledEcho fgYellow, "!! Config directory created at '", gitDir, "'!", fgDefault
    gitDir.createDir()

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


# Create valid operations:
import procedures
var ListOfOperatons: seq[Operation]

ListOfOperatons.add(Operation(
    name: "clone",
    aliases: @["install", "get", "add"],
    description: "Clones a git repository and creates a local copy.",
    usage: "[url: string]",
    procedure: proc() = cloneCommand(args, gitDir)
))

ListOfOperatons.add(Operation(
    name: "pull",
    aliases: @["update"],
    description: "Pulls any changes from the repository.",
    procedure: proc() = pullCommand(validGitDirectories)
))

ListOfOperatons.add(Operation(
    name: "help",
    aliases: @["info", "commands"],
    description: "Displays this help message.",
    procedure: proc() = helpCommand(ListOfOperatons)
))

ListOfOperatons.add(Operation(
    name: "list",
    aliases: @["ls", "listall"],
    description: "Lists all git repos the program can see.",
    procedure: proc() = listRepositoriesCommand(validGitDirectories)
))

ListOfOperatons.add(Operation(
    name: "remove",
    aliases: @["delete", "rm", "del"],
    description: "Deletes a repository from the disk.",
    procedure: proc() = removeRepositoryCommand(args, gitDir),
    usage: "[directory: string]"
))

proc findOperationByString(str: string): Operation =
    for op in ListOfOperatons:
        if op.name == str: return op
        for alias in op.aliases:
            if alias == str: return op
    
    # Return empty/generic operation:
    return Operation(
        name: "Unknown operation",
        description: "This operation is called when none has been found. See help for further information!",
        procedure: proc() =
            echo "No such valid operation found. ('" & str & ")"
            quit(1)
    )

proc callOperationByString(str: string): bool =
    var op: Operation = findOperationByString(str.strip)
    op.call()


# MAIN:

case args.len:
# Call help, if no arguments have been passed:
of 1:
    discard callOperationByString("help")

# Call other procedures:
else:
    discard callOperationByString(args[1])
