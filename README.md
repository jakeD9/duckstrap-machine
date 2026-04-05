# duckstrap-machine

`duckstrap-machine` contains a collection of my personal machine bootstrap scripts for setting up a development environment on a new machine. It is package manager agnostic, but is geared towards macOS and linux operatign systems.

Its purpose is to keep machine setup repeatable, versioned, consistent, and easy to rerun. Instead of manually installing tools and rewriting config on every new machine, this repo groups the setup into focused scripts for shell, development tooling, VS Code, and Git/SSH.

Note: my vscode settings are not sync'd in this repo.

This is a living repository that will likely be updated on a consistent basis as my developer tastes change and evolve. 

## What It Contains

- `bootstrap.sh`
  Top-level entrypoint that installs base prerequisites and then runs the module setup scripts in order.
- `utils.sh`
  Shared helper functions for package-manager detection, package installation, logging, and file linking.
- `shell/setup.sh`
  Sets up Zsh, Oh My Zsh, Powerlevel10k, Kitty, and copies shell config files from the repo onto the machine.
- `shell/update_shell.sh`
  Sync helper for importing shell config from the current machine into the repo, or exporting the repo versions back to the machine.
- `dev/setup.sh`
  Installs common developer tools like `gh`, `jq`, `ripgrep`, `fzf`, `neovim`, Kubernetes tools, and optional Docker setup.
- `vscode/setup.sh`
  Installs VS Code, verifies the `code` CLI is available, and installs extensions from `vscode/extensions.txt`.
- `git/setup.sh`
  Configures Git defaults, sets aliases, and helps with SSH key generation and GitHub SSH testing.


## Supported Package Managers

The shared installer currently detects and uses:

- Homebrew on macOS
- `apt` on Debian/Ubuntu-style Linux
- `pacman` on Arch-style Linux

Some scripts include extra package-manager-specific logic beyond the shared installer, such as VS Code and Docker Desktop.

## Recommended Usage

Run the full machine bootstrap:

```bash
./bootstrap.sh
```

This will:

1. Install base tools needed by the rest of the scripts.
2. Run shell setup.
3. Run developer tooling setup.
4. Run VS Code setup.
5. Run Git and SSH setup.

## Script Commands

Run only the shell setup:

```bash
./shell/setup.sh
```

This script:

- installs `zsh`
- installs Oh My Zsh if missing
- offers to copy `.zshrc` from the repo to `~/.zshrc`
- installs Powerlevel10k if missing
- offers to copy `.p10k.zsh` from the repo to `~/.p10k.zsh`
- installs Kitty through the detected package manager
- offers to copy `kitty.conf` to `~/.config/kitty/kitty.conf`

Run only the developer tools setup:

```bash
./dev/setup.sh
```

This script installs:

- `gh`
- `wget`
- `unzip`
- `jq`
- `ripgrep`
- `fzf`
- `neovim`
- Kubernetes tools: `kubectl`, `helm`, `k9s`
- utilities: `htop`, `tree`

It also prompts for Docker setup:

- `desktop` to install Docker Desktop on Homebrew-based systems
- `cli` to install `docker` and `docker-compose`
- `skip` to leave Docker alone

Run only the VS Code setup:

```bash
./vscode/setup.sh
```

This script:

- installs VS Code if needed
- checks that the `code` CLI is available
- installs extensions listed in `vscode/extensions.txt`

Run only the Git and SSH setup:

```bash
./git/setup.sh
```

This script:

- prompts for `git config --global user.name` if missing
- prompts for `git config --global user.email` if missing
- sets `init.defaultBranch` to `main`
- sets `core.editor` to `code --wait`
- installs a few Git aliases
- checks for an SSH key
- offers to generate an `ed25519` SSH key
- prints the public key so it can be added to GitHub
- offers to test the GitHub SSH connection

Sync shell config from machine to repo:

```bash
./shell/update_shell.sh --import
```

Sync shell config from repo to machine:

```bash
./shell/update_shell.sh --export
```

If no argument is given, the script exits with a message asking for `--import` or `--export`.

## Tracked Shell Config

The shell config files stored in this repo are:

- `shell/zsh/.zshrc`
- `shell/p10k/.p10k.zsh`
- `shell/kitty/kitty.conf`

These are the files copied by both `shell/setup.sh` and `shell/update_shell.sh`.

## Notes

- Most scripts are interactive and may prompt before copying files or generating credentials.
- Some installs use `sudo` depending on the detected package manager.
- VS Code setup expects the `code` CLI to be available after installation.
- Git setup assumes GitHub SSH usage and tests against `git@github.com`.
