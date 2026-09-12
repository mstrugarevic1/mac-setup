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
        printf "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n🔀  Git repository detected\n↻   Update safely with: git pull --ff-only\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n"
    elif [[ -z "$root" ]]; then
        unset LAST_GIT_ROOT
    fi
}

# Select an AWS profile with fzf and refresh the SSO session when it expired.
# Pass a name to skip the picker, for example `aws-switch staging`.
# This stays a function because it exports AWS_PROFILE into the current shell.
aws-switch() {
    local profile
    if [[ -n "$1" ]]; then
        profile="$1"
    else
        profile="$(aws configure list-profiles | sort \
            | fzf --prompt='AWS profile > ' --height=40% --reverse \
                  --header="current: ${AWS_PROFILE:-none}")" || return
    fi
    [[ -n "$profile" ]] || return

    export AWS_PROFILE="$profile"
    echo "AWS_PROFILE=$AWS_PROFILE"

    aws sts get-caller-identity >/dev/null 2>&1 || aws sso login
}
