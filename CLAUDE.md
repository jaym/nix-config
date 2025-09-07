# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Architecture Overview

This is a nix-darwin configuration repository that manages macOS system configuration and user environments using Nix flakes. The setup includes:

- **Flake-based configuration**: Main configuration in `flake.nix` with inputs for nixpkgs, nix-darwin, and home-manager
- **Darwin module** (`modules/darwin/default.nix`): System-level macOS configuration including Homebrew packages, system defaults, fonts, and security settings
- **Home-manager module** (`modules/home-manager/default.nix`): User-level configuration including shell setup, development tools, and application dotfiles
- **Dotfiles**: Application configurations stored in `dotfiles/` and symlinked via home-manager

## System Management Commands

### Darwin (macOS) Hosts
```bash
# Apply system configuration changes
darwin-rebuild switch --flake ~/nix-config/.#

# Update flake inputs and rebuild (available as shell alias 'nixup')
pushd ~/nix-config; nix flake update; darwin-rebuild switch --flake ~/nix-config/.#; popd
```

### Linux Hosts (standalone home-manager)
```bash
# Apply home-manager configuration changes
home-manager switch --flake ~/nix-config/.#robotarms

# Update flake inputs and rebuild
pushd ~/nix-config; nix flake update; home-manager switch --flake ~/nix-config/.#robotarms; popd
```

### General Commands
```bash
# Check flake syntax and evaluate
nix flake check

# Format Nix files
nixfmt-rfc-style **/*.nix
```

## Target Hosts

- **Darwin hosts**: `momcorp` and `flexo` (both aarch64-darwin) - managed via nix-darwin
- **Linux hosts**: `robotarms` (x86_64-linux) - managed via standalone home-manager

## Key Configuration Areas

- **System packages**: Managed through `environment.systemPackages` in darwin module
- **Homebrew packages**: Casks and brews defined in darwin module homebrew section  
- **User packages**: Defined in home-manager module `home.packages`
- **Shell configuration**: Zsh with starship prompt, custom aliases in home-manager
- **Application dotfiles**: AeroSpace (window manager), Ghostty (terminal), Karabiner (key remapping), VSCode keybindings

## Important Aliases

- `nixswitch`: darwin-rebuild switch --flake ~/nix-config/.#
- `nixup`: Update flake and rebuild system
- `vim`: nvim

## Development Tools Included

- direnv with nix-direnv for project environments
- Git configuration with user details
- VSCode with Nix, Go, and direnv extensions
- Development utilities: ripgrep, fd, htop, curl, rclone