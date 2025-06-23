#!/usr/bin/env bash

# Build binaries:

ARCH=""
TIME=$(date --iso-8601)

if arch &> /dev/null; then
    ARCH=$(arch)
fi
[ -z "$ARCH" ] && ARCH="unknown"

ARCH="_$ARCH"

function compile() {
    echo -e "Compiling..."
    nimble build -d:release -d:strip -d:PROJECT_COMPILE_TIME:$TIME $*
}

compile && mv gitman "gitman_${OSTYPE}${ARCH}"
compile -d:mingw -d:windows && mv gitman.exe "gitman_windows${ARCH}.exe"
# compile --os:android && mv gitman "gitman_android" # why? amazing!

# Shell completions:
{
    echo -e "Building completions..." && nim r --hints:off scripts/completions.nim
} || {
    echo -e "Failed to make shell completions."
    exit 1
}
