# Makefile for managing the Marp presentation project

# Detect the operating system for clean command
# Windows uses 'rmdir' while Unix-like systems use 'rm -rf'

help:
	@echo   make clean    Remove the distribution directory
	@echo   make install  Install Marp dependencies
	@echo   make build    Build the Marp presentation
	@echo   make format   Format the presentation source
	@echo   make serve    Start the Marp development server

clean:
ifeq ($(OS),Windows_NT)
	@if exist dist rmdir /S /Q dist
else
	rm -rf dist
endif

install:
	corepack pnpm@12 install --frozen-lockfile

build:
	corepack pnpm@12 build

format:
	corepack pnpm@12 format

serve:
	corepack pnpm@12 dev
