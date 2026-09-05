# Modern file and directory listings; eza is installed by Brewfile.
alias ls='eza --group-directories-first'
alias ll='eza -lah --git --group-directories-first'
alias la='eza -a --group-directories-first'
alias tree='eza --tree'

# Short Git status, working-tree diff, and compact recent history.
alias gs='git status --short --branch'
alias gd='git diff'
alias gl='git log --oneline --graph --decorate -20'

# Short names for frequently used infrastructure CLIs.
alias k='kubecolor'
alias tf='terraform'
