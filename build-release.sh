#!/usr/bin/env bash

ARCH=""
TIME=$(date --iso-8601)

if arch &> /dev/null; then
    ARCH=$(arch)
fi
[ -z "$ARCH" ] && ARCH="unknown"

ARCH="_$ARCH"

function compile() {
    nimble build -d:release -d:strip -d:PROJECT_COMPILE_TIME:$TIME $*
}

compile && mv gitman "gitman_${OSTYPE}${ARCH}"
compile -d:mingw -d:windows && mv gitman.exe "gitman_windows${ARCH}.exe"
