SHELL := /usr/bin/env bash

.PHONY: help check build test clean

help:
	@printf '%s\n' \
	  'EmotionalOS Arch targets:' \
	  '  make check       Validate scripts and profile inputs' \
	  '  sudo make build  Build the ArchISO image' \
	  '  make test        Boot the newest ISO in QEMU' \
	  '  make clean       Remove generated build output'

check:
	bash scripts/check.sh

build: check
	bash scripts/build-iso.sh

test:
	bash scripts/test-qemu.sh

clean:
	rm -rf build
