#!/usr/bin/env bash

ARCH=""

if arch &> /dev/null; then
    ARCH=$(arch)
fi
[ -z "$ARCH" ] && ARCH="unknown"

ARCH="_$ARCH"
nimble build -d:release && mv gitman "gitman_${OSTYPE}${ARCH}"

nimble build -d:mingw -d:windows -d:release && mv gitman.exe "gitman_windows_${ARCH}.exe"
