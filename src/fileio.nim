import os, strformat
import error

# -----------------------------------------------------------------------------
# Git repo location:
# -----------------------------------------------------------------------------

const environment_variable: string = "GITMAN_REPOS_LOCATION"
let default_git_repo_path: string = getHomeDir() & "Git/"

let git_repo_path*: string =
    if existsEnv(environment_variable): getEnv(environment_variable)
    else:
        putEnv(environment_variable, default_git_repo_path)
        default_git_repo_path & "/"



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

proc remove_git_dirs*(dirs: seq[string]): tuple[successes: int, failures: seq[string]] =
    ## Removes all directories and returns amount of successes and a sequence of failed directories
    for dir in dirs:
        try:
            removeDir(git_repo_path & dir)
            result.successes += 1
        except OSError:
            result.failures.add(dir)
