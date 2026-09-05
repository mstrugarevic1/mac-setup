# Create one directory path and enter it. Refuse missing or extra arguments.
mkcd() {
    [[ $# -eq 1 ]] || { echo "usage: mkcd <directory>" >&2; return 2; }
    mkdir -p -- "$1" && cd -- "$1"
}
