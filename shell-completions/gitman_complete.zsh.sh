#compdef gitman
# autogenerated via Nim script
compdef _gitman gitman
[ -z "$GITMAN_REPOS_LOCATION" ] && GITMAN_REPOS_LOCATION=~/Git

_gitman() {
    local -a commands
    commands=(
        'async-pull:Asynchronously pulls changes for every git repo.'
        'clone:Clones new git repository to repo directory.'
        'edit-install:Lets you quickly edit the install json file.'
        'help:Displays help message.'
        'install:Executes a specified install script for the repository.'
        'list:Displays names of all clones git repositories.'
        'pull:Synchronously pulls changes for every git repo.'
        'remove:Removes git repository from repo directory.'
        'version:Displays program version.'
    )

    if (( CURRENT == 2 )); then
        _describe -t commands 'commands' commands
    elif (( CURRENT >= 3 )); then
        _path_files -/ -W "$GITMAN_REPOS_LOCATION"
    fi
    return 0
}
