# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

Personal development monorepo that aggregates external tools/libraries via declarative TOML config and includes dotfiles for Linux/macOS system configuration. Evolved from git submodules to Makefile-based repository management.

## Commands

### Root level — manage external repositories

```bash
make repos    # Clone all repositories defined in repo.toml
make clean    # Remove all cloned repositories
make help     # Show available targets
```

### dotfiles/ — font templating

```bash
make font                  # Generate dotfiles from .in templates (default font_size=10)
make font FONT_SIZE=12     # Generate with custom font size
make font-clean            # Remove generated dotfiles (restore to template-only state)
```

### emacs.d/ — Emacs configuration (cloned via `make repos`)

```bash
cd emacs.d
make init       # Install templates/init.el to ~/.emacs.d
make download   # Batch download/update ELPA packages
make run        # Run Emacs
make debug      # Run Emacs with --debug-init
make clean      # Remove .elc, .eln, .tar.gz files
```

## Architecture

### Repository management (`Makefile` + `repo.toml`)

The root Makefile parses `repo.toml` to clone external git repositories. Each `[repo.name]` section declares `url`, `dir`, and optional `branch`, `tag`, `depth`, `commit` fields. The Makefile generates a temporary shell script at runtime that processes each entry, supporting shallow clones and commit pinning. Cloned directories are auto-appended to `.gitignore`.

### Dotfiles configure system (`dotfiles/`)

Uses an autoconf-style `.in` template pattern: files like `kitty.conf.in` contain `@FONT_SIZE@` placeholders and are tracked in git. Running `make font` generates the actual config files (e.g. `kitty.conf`) by substituting the placeholder with the value from `config.toml`. Generated files are gitignored; `make font-clean` removes them.

### Dotfiles contents

- **i3/**: i3 window manager config, rofi launcher, wallpapers (Linux)
- **i3blocks/**: Status bar blocks for CPU, memory, volume with standalone scripts
- **aerospace/**: Tiling window manager config (macOS)
- **sketchybar/**: Status bar with shell-script plugins (macOS)
- **kitty/**: Terminal emulator config
- **rime/**: RIME input method configs (ibus on Linux, Squirrel on macOS)
- **scripts/**: `jc-d.sh` (Docker container manager), `jc-t.sh` (remote benchmark runner)
- C/C++ tooling: `.clang-format`, `.clang-tidy`, `.clangd`, `.cmake-format.yaml`

### Emacs configuration (`emacs.d/`)

Has its own CLAUDE.md with detailed module documentation. Key points: two-level deferred loading architecture, `templates/init.el` as user-facing entry point, leader-key keybindings via general.el, and gptel LLM integration.

## Conventions

- Commit messages follow conventional commits: `feat:`, `fix:`, `chore:`, `docs:`, with optional scope like `feat(makefile):`
- Some repos use SSH URLs (`git@github.com:`) — these require SSH key access
- The `dotfiles/` directory is tracked directly in this repo; other tool directories are cloned externally and gitignored
