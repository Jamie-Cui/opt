# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

Personal development monorepo that aggregates external tools/libraries via declarative TOML config and includes dotfiles for Linux/macOS system configuration. Evolved from git submodules to Makefile-based repository management.

## Commands

### Root level — manage everything

```bash
make repo                 # Clone all repositories defined in config.toml
make repo-clean           # Remove all cloned repositories
make font                 # Replace {dotfont} placeholders in dotfiles with font_size from config.toml
make font FONT_SIZE=12    # One-off override of font size
make font-clean           # Revert font sizes back to {dotfont} placeholders
make help                 # Show available targets
```

To change the font size permanently, edit `[dotfiles] font_size` in `config.toml`.

### emacs.d/ — Emacs configuration (cloned via `make repo`)

```bash
cd emacs.d
make init       # Install templates/init.el to ~/.emacs.d
make download   # Batch download/update ELPA packages
make run        # Run Emacs
make debug      # Run Emacs with --debug-init
make clean      # Remove .elc, .eln, .tar.gz files
```

## Architecture

### Configuration (`config.toml`)

Single TOML file for all project configuration:

- `[dotfiles]` — dotfiles settings (`font_size`)
- `[repo.*]` — external git repositories to clone; each entry declares `url`, `dir`, and optional `branch`, `tag`, `depth`, `commit`

### Repository management (`Makefile` + `config.toml`)

The root Makefile parses `config.toml` to clone external git repositories. The Makefile generates a temporary shell script at runtime that processes each `[repo.*]` entry, supporting shallow clones and commit pinning. Cloned directories are auto-appended to `.gitignore`.

### Dotfiles font system (`dotfiles/`)

The root Makefile reads `font_size` from `config.toml [dotfiles]` at parse time. The `{dotfont}` token in config files (`.conf`, `.ini`, `.yaml`, `config`) gets replaced with the configured font size on `make font` and reverted on `make font-clean` for clean version control.

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
