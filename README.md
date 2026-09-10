<p align="center">
  <img src="assets/mac-setup-logo.png" alt="mac-setup logo" width="320">
</p>

# mac-setup

My personal macOS bootstrap script for setting up an Apple Silicon development workstation.

## What it does

- Installs command-line tools and applications from `Brewfile`.
- Installs Oh My Zsh, links tracked dotfiles, backs up existing targets, and sets zsh as the login shell.
- Applies macOS preferences.
- Enables Touch ID authentication for `sudo` when supported.
- Configures Chrome bookmarks and offers extensions on the next launch; they can be declined or removed in Chrome.
- Downloads `ai-safe.sh` from a pinned commit and verifies its SHA-256 checksum.
- Installs VSCodium extensions.

## Requirements

This project targets macOS 26 (Tahoe) on Apple Silicon. The Touch ID step is skipped automatically on older macOS versions that do not provide the required PAM template.

The script is safe to rerun. Run it as your normal user; it requests the sudo password only while configuring Touch ID authentication.

## Usage

Requires Xcode Command Line Tools and Homebrew. Review and customize `Brewfile`, `setup.sh`, and `macos/defaults.sh` before running.

Install Xcode Command Line Tools:

```bash
xcode-select --install
```

After the installation finishes, install Homebrew:

```bash
/bin/bash -c "$(curl -fsSL \
  https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Then clone the repository and run the setup script:

```bash
git clone https://github.com/mstrugarevic1/mac-setup.git ~/.mac-setup
cd ~/.mac-setup
./setup.sh
```

Run the script as your normal user, not with `sudo`.
