# Shell and macOS applications.
alias sz='source ~/.zshrc'
alias finder='open .'
alias textedit='open -a TextEdit'
alias chrome='open -a "Google Chrome"'
alias code='codium'
alias calc='open -a Calculator'
alias notes='open -a Notes'
alias activity='open -a "Activity Monitor"'

# Modern file and directory listings; eza is installed by Brewfile.
alias ls='eza --group-directories-first'
alias ll='eza -lah --git --group-directories-first'
alias la='eza -a --group-directories-first'
alias tree='eza --tree'
alias ..='cd ..'
alias ...='cd ../..'
alias c='clear'

# Short Git status, working-tree diff, and compact recent history.
alias gs='git status --short --branch'
alias gd='git diff'
alias gl='git log --oneline --graph --decorate -20'
alias gp='git pull --ff-only'

# Short names for frequently used infrastructure CLIs.
alias kubectl='kubecolor'
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get services'
alias kctx='kubectl config current-context'
alias tf='terraform'
alias tff='terraform fmt -recursive'
alias tfv='terraform validate'
alias tfp='terraform plan'
alias dps='docker ps'
alias di='docker images'
