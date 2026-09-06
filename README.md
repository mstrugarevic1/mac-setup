<p align="center">
  <img src="assets/mac-setup-logo.png" alt="mac-setup logo" width="320">
</p>

# mac-setup

My personal macOS bootstrap script for setting up an Apple Silicon development workstation.

## What it does

- Installs command-line tools and applications from `Brewfile`.
- Links tracked dotfiles and backs up existing targets.
- Applies macOS preferences.
- Configures Chrome bookmarks and extensions, and installs VSCodium extensions.

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

Run the script as your normal user, not with `sudo`. It is intended for Apple Silicon Macs.
