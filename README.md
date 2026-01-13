# opt

A personal collection of essential development tools and configurations managed via Makefile and TOML config.

## Overview

This repository aggregates various development tools, libraries, and configuration files using a declarative `repo.toml` configuration. Repositories are cloned with a single `make repos` command.

## Quick Start

```bash
# Clone this repository
git clone https://github.com/Jamie-Cui/opt.git opt
cd opt

# Clone all defined repositories
make repos
```

## Available Commands

```bash
make repos    # Clone all repositories defined in repo.toml
make clean    # Remove all cloned repositories
make help     # Show available commands
```

## Configuration

Repositories are defined in `repo.toml`:

```toml
[repo.example]
url = "https://github.com/user/repo.git"
dir = "vendor/repo"

# Optional fields:
branch = "main"     # Clone specific branch
tag = "v1.0.0"      # Checkout specific tag
depth = 1           # Shallow clone (1 = latest commit only)
commit = "abc123"   # Pin to specific commit hash
```

### Field Reference

| Field | Required | Description |
|-------|----------|-------------|
| `url` | Yes | Git repository URL (https:// or git@) |
| `dir` | Yes | Target directory for cloning |
| `branch` | No | Clone specific branch |
| `tag` | No | Checkout specific tag after clone |
| `depth` | No | Shallow clone depth (1 = latest only) |
| `commit` | No | Pin to specific commit hash |

## Current Repositories

### Development Tools
- **wondershaper** - Network traffic shaping tool
- **ctags** - Universal ctags for source code indexing
- **microprofile** - Real-time CPU/GPU profiler

### Libraries
- **libboundscheck** - C bounds checking library

### Configuration
- **dotfiles** - Personal shell, editor, and system configs
- **emacs.d** - Emacs configuration
- **emacs** - Emacs source (for custom builds)
- **org-root** - Org-mode configuration

## Adding New Repositories

Edit `repo.toml` to add new repositories:

```toml
[repo.my_tool]
url = "https://github.com/user/tool.git"
dir = "tools/my_tool"
branch = "develop"
depth = 1
```

Then run `make repos` to clone.

## License

Each repository is licensed under its own terms. Please check LICENSE files in respective directories.
