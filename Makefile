# Makefile for gitman:
BIN_DIR="/usr/local/bin/"
BUILD_FLAGS="-d:release"

gitman: src/gitman.nim
	nimble build $(BUILD_FLAGS)

build: gitman

install: gitman
	sudo mv gitman $(BIN_DIR)

