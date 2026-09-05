#!/bin/bash

# Apple ships Bash 3.2, so keep this script compatible with it.
set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_SUFFIX="$(date +%Y%m%d-%H%M%S).$$"
AI_CLI_WRAPPER_COMMIT="75212b90ff3db5fe55003e4af6fc3c6df11545a0"
AI_CLI_WRAPPER_SHA256="27048ab978bf9f8a4ee80ace1732678f4611a700fa98dd4bc0641fcf1e7008a3"

# Leave correct links alone and back up anything else before linking it.
link_file() {
    local source=$1 destination=$2 backup counter=1
    [[ -e "$source" ]] || { printf 'Missing repository file: %s\n' "$source" >&2; return 1; }
    mkdir -p "$(dirname "$destination")"

    if [[ -L "$destination" && "$(readlink "$destination")" == "$source" ]]; then
        return 0
    fi

    if [[ -e "$destination" || -L "$destination" ]]; then
        backup="${destination}.backup.${BACKUP_SUFFIX}"
        while [[ -e "$backup" || -L "$backup" ]]; do
            backup="${destination}.backup.${BACKUP_SUFFIX}.${counter}"
            counter=$((counter + 1))
        done
        mv -n "$destination" "$backup"
        [[ ! -e "$destination" && ! -L "$destination" ]] || {
            printf 'Could not safely back up %s\n' "$destination" >&2
            return 1
        }
    fi

    ln -s "$source" "$destination"
}

# Machine-local files are created once and never overwritten.
create_local_file() {
    local source=$1 destination=$2
    if [[ ! -e "$destination" && ! -L "$destination" ]]; then
        mkdir -p "$(dirname "$destination")"
        install -m 600 "$source" "$destination"
    fi
}

if (($#)); then
    echo 'Usage: ./setup.sh' >&2
    exit 2
fi

[[ "$(uname -s)" == Darwin ]] || { echo 'This setup supports macOS only.' >&2; exit 1; }
[[ $EUID -ne 0 ]] || { echo 'Run setup.sh as your normal user, never with sudo.' >&2; exit 1; }

printf '\n################################################################\n'
printf '### mac-setup — Personal macOS workstation setup\n'
printf '################################################################\n\n'
printf 'Installs Brewfile dependencies, links dotfiles, and applies macOS preferences.\n'
printf 'Estimated time: 10–30 minutes on a fresh Mac.\n\n'
printf 'Continue? [y/N] '
read -r reply
case "$reply" in
    y | Y | yes | YES | d | D | da | DA) ;;
    *) echo 'Setup cancelled.'; exit 0 ;;
esac

printf '\n→ Xcode Command Line Tools\n'
xcode-select -p >/dev/null 2>&1 || { echo 'Install Xcode Command Line Tools first: xcode-select --install' >&2; exit 1; }
printf '✓ Xcode Command Line Tools\n'

printf '→ Homebrew\n'
if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
elif ! command -v brew >/dev/null 2>&1; then
    echo 'Install Homebrew first: https://brew.sh' >&2
    exit 1
fi
printf '✓ Homebrew\n'

printf '→ Dotfiles\n'
link_file "$REPO_DIR/dotfiles/aliases.zsh" "$HOME/.aliases.zsh"
link_file "$REPO_DIR/dotfiles/functions.zsh" "$HOME/.functions.zsh"
link_file "$REPO_DIR/dotfiles/gitignore_global" "$HOME/.gitignore_global"
link_file "$REPO_DIR/dotfiles/vimrc" "$HOME/.vimrc"
link_file "$REPO_DIR/dotfiles/vim/colors/workstation.vim" "$HOME/.vim/colors/workstation.vim"
link_file "$REPO_DIR/dotfiles/helix/config.toml" "$HOME/.config/helix/config.toml"
link_file "$REPO_DIR/dotfiles/tmux.conf" "$HOME/.tmux.conf"
link_file "$REPO_DIR/dotfiles/kitty.conf" "$HOME/.config/kitty/kitty.conf"
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
link_file "$REPO_DIR/dotfiles/ssh_config" "$HOME/.ssh/config"

create_local_file "$REPO_DIR/local/zshrc.local.example" "$HOME/.zshrc.local"
create_local_file "$REPO_DIR/local/ssh_config.local.example" "$HOME/.ssh/config.local"
create_local_file "$REPO_DIR/local/vimrc.local.example" "$HOME/.vimrc.local"
create_local_file "$REPO_DIR/local/tmux.conf.local.example" "$HOME/.tmux.conf.local"
create_local_file "$REPO_DIR/local/kitty.local.conf.example" "$HOME/.config/kitty/local.conf"
printf '✓ Dotfiles\n'

printf '→ Git\n'
if [[ ! -e "$HOME/.gitconfig.local" && ! -L "$HOME/.gitconfig.local" ]]; then
    read -r -p 'Git name and surname: ' git_name
    read -r -p 'Git email: ' git_email
    [[ -n "$git_name" ]] || { echo 'Git name cannot be empty.' >&2; exit 1; }
    [[ "$git_email" == *@*.* ]] || { echo 'Enter a valid Git email address.' >&2; exit 1; }

    temp_file="$(mktemp "$HOME/.gitconfig.local.tmp.XXXXXX")"
    if ! install -m 600 "$REPO_DIR/local/gitconfig.local.example" "$temp_file" \
        || ! git config --file "$temp_file" user.name "$git_name" \
        || ! git config --file "$temp_file" user.email "$git_email"; then
        rm -f "$temp_file"
        exit 1
    fi
    mv -n "$temp_file" "$HOME/.gitconfig.local"
    if [[ -e "$temp_file" ]]; then
        rm -f "$temp_file"
        echo "$HOME/.gitconfig.local appeared during setup and was not overwritten." >&2
        exit 1
    fi
fi
link_file "$REPO_DIR/dotfiles/gitconfig" "$HOME/.gitconfig"
printf '✓ Git\n'

link_file "$REPO_DIR/dotfiles/zprofile" "$HOME/.zprofile"
link_file "$REPO_DIR/dotfiles/zshrc" "$HOME/.zshrc"

printf '→ macOS preferences\n'
/bin/bash "$REPO_DIR/macos/defaults.sh"
printf '✓ macOS preferences\n'

printf '→ Homebrew packages and applications\n'
brew bundle --no-upgrade --file "$REPO_DIR/Brewfile"
printf '✓ Homebrew packages and applications\n'

# Offer these Chrome Web Store extensions on the next Google Chrome launch.
# Chrome asks the user to enable them, and respects later removal through its UI.
printf '→ Chrome extensions\n'
chrome_extensions_dir="$HOME/Library/Application Support/Google/Chrome/External Extensions"
mkdir -p "$chrome_extensions_dir"
# Malwarebytes Browser Guard, uBlock Origin Lite, Dark Reader, and Chrome Capture.
for chrome_extension in \
    ihcjicgdanjaechkgeegckofjjedodee \
    ddkjiahejlhfcafbddmgiahcphecmpfh \
    eimadpbcbfnmbkopoojfekhnkhdbieeh \
    ggaabchcecdbomdcnbahdfddfikjmphe; do
    chrome_extension_file="$chrome_extensions_dir/$chrome_extension.json"
    if [[ ! -e "$chrome_extension_file" && ! -L "$chrome_extension_file" ]]; then
        printf '%s\n' '{"external_update_url":"https://clients2.google.com/service/update2/crx"}' > "$chrome_extension_file"
    fi
done
unset chrome_extension chrome_extension_file chrome_extensions_dir
printf '✓ Chrome extensions\n'

printf '→ AI CLI wrapper\n'
ai_wrapper_dir="$HOME/.config/ai-cli-wrapper/scripts"
ai_wrapper_file="$ai_wrapper_dir/ai-safe.sh"
if [[ ! -e "$ai_wrapper_file" && ! -L "$ai_wrapper_file" ]]; then
    mkdir -p "$ai_wrapper_dir"
    ai_wrapper_temp="$(mktemp "$ai_wrapper_dir/ai-safe.sh.tmp.XXXXXX")"
    if ! /usr/bin/curl --fail --location --silent --show-error \
        "https://raw.githubusercontent.com/mstrugarevic1/ai-cli-wrapper/$AI_CLI_WRAPPER_COMMIT/scripts/ai-safe.sh" \
        --output "$ai_wrapper_temp"; then
        rm -f "$ai_wrapper_temp"
        exit 1
    fi
    ai_wrapper_hash="$(/usr/bin/shasum -a 256 "$ai_wrapper_temp")"
    ai_wrapper_hash="${ai_wrapper_hash%% *}"
    if [[ "$ai_wrapper_hash" != "$AI_CLI_WRAPPER_SHA256" ]]; then
        rm -f "$ai_wrapper_temp"
        echo 'AI CLI wrapper checksum verification failed.' >&2
        exit 1
    fi
    mv -n "$ai_wrapper_temp" "$ai_wrapper_file"
    if [[ -e "$ai_wrapper_temp" ]]; then
        rm -f "$ai_wrapper_temp"
        echo "$ai_wrapper_file appeared during setup and was not overwritten." >&2
        exit 1
    fi
fi
[[ -f "$ai_wrapper_file" ]] || { echo "Invalid AI CLI wrapper path: $ai_wrapper_file" >&2; exit 1; }
unset ai_wrapper_dir ai_wrapper_file ai_wrapper_temp ai_wrapper_hash
printf '✓ AI CLI wrapper\n'

printf '→ VSCodium extensions\n'
for extension in \
    mhutchie.git-graph \
    hashicorp.terraform \
    redhat.vscode-yaml \
    ms-python.python \
    timonwong.shellcheck \
    qwtel.sqlite-viewer \
    shd101wyy.markdown-preview-enhanced \
    GitHub.vscode-github-actions; do
    codium --install-extension "$extension"
done
printf '✓ VSCodium extensions\n'

printf '\n✓ Setup complete\n'
printf 'Complete account, SSH, cloud, VPN, and application sign-ins as needed.\n'
