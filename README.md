# duckstrap-machine

`duckstrap-machine` contains a collection of my personal bootstrap scripts for setting up either a development environment, a baseline Ubuntu homelab box, or a k3s cluster/node. It is package manager agnostic in the dev path, but the homelab paths are intentionally targeted at Ubuntu-style systems.

Its purpose is to keep machine setup repeatable, versioned, consistent, and easy to rerun. Instead of manually installing tools and rewriting config on every new machine, this repo groups the setup into focused scripts for shell, development tooling, VS Code, Git/SSH, baseline server setup, and k3s nodes.

Note: my vscode settings are not sync'd in this repo.

This is a living repository that will likely be updated on a consistent basis as my developer tastes change and evolve. 

## What It Contains

- `bootstrap.sh`
  Top-level entrypoint that installs base prerequisites and then runs either the developer or server bootstrap flow.
- `bootstrap_server.sh`
  Convenience entrypoint for the baseline server bootstrap flow.
- `bootstrap_k8s.sh`
  Convenience entrypoint for the k3s node bootstrap flow.
- `utils.sh`
  Shared helper functions for package-manager detection, package installation, logging, and config-file copying.
- `server/bootstrap.sh`
  Bootstraps an Ubuntu homelab box with your preferred shell, editor, terminal utilities, and GitHub CLI.
- `k8s/bootstrap.sh`
  Turns an Ubuntu VM into a k3s server or agent and can optionally bootstrap Flux from a server node.
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

Run the developer workstation bootstrap:

```bash
./bootstrap.sh
```

This will:

1. Install base tools needed by the rest of the scripts.
2. Run shell setup.
3. Run developer tooling setup.
4. Run VS Code setup.
5. Run Git and SSH setup.

Run the baseline homelab box bootstrap:

```bash
./bootstrap.sh --servermode
```

or:

```bash
./bootstrap_server.sh
```

This flow is intended for an Ubuntu host or VM that should feel like one of your machines. It will:

1. Install baseline CLI tooling for SSH-first administration.
2. Install Zsh, Oh My Zsh, and Powerlevel10k using the config tracked in this repo.
3. Install and optionally authenticate GitHub CLI.
4. Install guest-friendly utilities such as `qemu-guest-agent`.

Run the k3s node bootstrap:

```bash
./bootstrap.sh --k8smode
```

or:

```bash
./bootstrap_k8s.sh
```

This flow is intended for a Linux box or VM that should become part of a k8s cluster. It will:

1. Prompt for `server` or `agent`.
2. Install k3s in the selected role.
3. Install the Flux CLI on server nodes.
4. Optionally run `flux bootstrap github` from a server node.


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
- The server bootstrap assumes Ubuntu or another `apt`-based Linux distribution.
- The k3s bootstrap also assumes Ubuntu or another `apt`-based Linux distribution.
- The tracked `.zshrc` is now portable across machines and no longer hardcodes a user-specific home path.

