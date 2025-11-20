# opt

A personal collection of essential development tools and configurations as git submodules.

## Overview

This repository aggregates various development tools, libraries, and configuration files that I frequently use in my workflow. Everything is organized as git submodules for easy version management and updates.

## Submodules

### Development Tools
- **[wondershaper](wondershaper/)** - Network traffic shaping tool for limiting bandwidth
- **[universal-ctags](ctags/)** - Maintained ctags implementation for source code indexing
- **[microprofile](microprofile/)** - Real-time CPU/GPU profiler for performance analysis

### Libraries
- **[libboundscheck](libboundscheck/)** - C bounds checking library for memory safety

### Configuration Files
- **[dotfiles](dotfiles/)** - Personal dotfiles including shell, editor, and system configurations
- **[emacs.d](emacs.d/)** - Personal Emacs configuration and init files
- **[emacs](emacs/)** - Emacs editor source code (for custom builds)

## Setup

### Clone with Submodules
```bash
git clone --recurse-submodules https://github.com/Jamie-Cui/eztools.git
```

### Initialize Submodules (if already cloned)
```bash
git submodule update --init --recursive
```

### Update All Submodules
```bash
git submodule update --remote --merge
```

## Usage

Each tool can be used independently by navigating to its respective directory:

```bash
# Use wondershaper for network limiting
cd wondershaper
sudo ./wondershaper wlan0 1000 500

# Generate ctags for your project
cd ctags
make && sudo make install
ctags -R .

# Profile your application
cd microprofile
# Follow the setup instructions in their README
```

## Configuration

### Dotfiles
To use the dotfiles, you can create symlinks to your home directory:

```bash
# Example for vimrc
ln -s $(pwd)/dotfiles/.vimrc ~/.vimrc

# Example for clang-format
ln -s $(pwd)/dotfiles/.clang-format ~/.clang-format
```

### Emacs
The Emacs configuration is split across two submodules:
- `emacs/` - The Emacs source code (for building from source)
- `emacs.d/` - The configuration files and packages

## Repository Structure

```
eztools/
├── README.md           # This file
├── .gitmodules         # Git submodule configuration
├── .gitignore          # Git ignore rules
├── LICENSE             # License information
├── wondershaper/       # Network traffic shaping tool
├── libboundscheck/     # C bounds checking library
├── microprofile/       # Performance profiler
├── ctags/              # Universal ctags
├── dotfiles/           # Configuration files
├── emacs/              # Emacs source
└── emacs.d/            # Emacs configuration
```

## Contributing

This is a personal collection of tools. If you find issues with specific submodules, please report them to their respective upstream repositories.

## License

Each submodule is licensed under its own terms. Please check the LICENSE files in each respective directory for specific licensing information.

## Links

- [wondershaper](https://github.com/magnific0/wondershaper)
- [universal-ctags](https://github.com/universal-ctags/ctags)
- [microprofile](https://github.com/jonasmr/microprofile)
- [libboundscheck](https://github.com/openeuler-mirror/libboundscheck)
- [emacs-mirror](https://github.com/emacs-mirror/emacs)
