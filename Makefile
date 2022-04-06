SHELL := /usr/bin/env bash

EMACS ?= emacs
EASK ?= eask

.PHONY: clean install startup speed compile

clean:
	@echo "Cleaning..."
	$(EASK) clean-all

install:
	@echo "Installing dependenices..."
	$(EASK) install-deps

startup:
	@echo "Startup testing..."
	$(EMACS) -q --batch -l "~/.emacs.d/test/startup/test-startup.el"

speed:
	@echo "Speed testing..."
	$(EMACS) -q --batch -l "~/.emacs.d/test/test-speed.el"

compile:
	@echo "Compiling..."
	$(EASK) concat
	$(EASK) load ./test/test-compile.el
