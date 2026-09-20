source /etc/static/zshrc
eval "$(/opt/homebrew/bin/brew shellenv)"
eval "$(zoxide init zsh)"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/toast/.lmstudio/bin"
# End of LM Studio CLI section

. "$HOME/.local/bin/env"
