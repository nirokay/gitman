import os

var filePath: string

type ConfigFile* = object
    fileName*: string
    defaultData*: string


# Procedures for interacting with files:
proc writeData*(file: ConfigFile, data: string): bool =
    var filepath: string = file.fileName
    try:
        filepath.writeFile(data)
        return true
    except IOError:
        return false

proc readData*(file: ConfigFile): string =
    var filepath = file.fileName
    return filepath.readFile()


#! Set before creating new files:
proc setConfigFilePath*(path: string) =
    filePath = path


# New file:
proc newConfigFile*(fileName, defaultData: string): ConfigFile =
    if not filePath.dirExists():
        filePath.createDir()

    let file: ConfigFile = ConfigFile(
        fileName: filePath & fileName,
        defaultData: defaultData
    )

    # Write to file, if non-existant yet:
    if not fileExists(file.fileName):
        if not file.writeData(file.defaultData):
            echo "Could not write to file '" & file.fileName & "'!"
    return file

