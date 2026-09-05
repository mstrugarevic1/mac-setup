<p align="center">
  <img src="assets/mac-setup-logo.png" alt="mac-setup logo" width="320">
</p>

# mac-setup — Personal macOS workstation configuration

One-time setup for my development and DevOps environment using Homebrew, dotfiles, and macOS defaults.

## New Apple Silicon Mac

Finish macOS Setup Assistant, install system updates, and complete company enrollment first if this is a work Mac.

Install Xcode Command Line Tools:

```bash
xcode-select --install
```

Wait for the installer to finish, then run:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"

brew install gh
gh auth login

gh repo clone mstrugarevic1/mac-setup ~/.mac-setup
cd ~/.mac-setup
./setup.sh
```

Run the setup as your normal user, not with `sudo`. Start a new login shell when it finishes.

## What the script does

- installs formulae, applications, and selected VSCodium extensions;
- offers selected Chrome Web Store extensions for approval on the next Chrome launch;
- installs a pinned revision of the `ai-cli-wrapper` safety functions;
- links the tracked Zsh, Git, SSH, Vim, Helix, tmux, and Kitty configuration;
- creates machine-local override files only when they do not exist;
- asks for missing Git identity values;
- applies the settings in `macos/defaults.sh`.

Existing config files are backed up before they are replaced with symlinks. The script is safe to rerun. Command output and password prompts remain visible; any failed Brewfile dependency stops the run so the cause can be fixed before rerunning.

On a fresh Mac, Homebrew installs the currently available versions. Reruns preserve installed versions because setup does not upgrade existing dependencies. This Brewfile is not a version-locked snapshot.

## Machine-local configuration

Use the `.local` files created under `~` for settings that apply only to this Mac. The setup creates missing local files once and never overwrites them.

Credentials do not belong in this repository. Keep SSH private keys, AWS credentials, kubeconfigs, tokens, certificates, VPN configuration, passwords, and `.env` files local. Application sign-ins and company access remain manual.
