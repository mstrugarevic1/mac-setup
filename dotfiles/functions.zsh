# Create one directory path and enter it. Refuse missing or extra arguments.
mkcd() {
    [[ $# -eq 1 ]] || { echo "usage: mkcd <directory>" >&2; return 2; }
    mkdir -p -- "$1" && cd -- "$1"
}

# Remind once when entering a different Git repository.
git_folder_reminder() {
    local root
    root="$(git rev-parse --show-toplevel 2>/dev/null)" || root=

    if [[ -n "$root" && "$root" != "$LAST_GIT_ROOT" ]]; then
        LAST_GIT_ROOT="$root"
        printf "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n🔀  Git repository detected\n↻   Don't forget to run: git pull\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n"
    elif [[ -z "$root" ]]; then
        unset LAST_GIT_ROOT
    fi
}
