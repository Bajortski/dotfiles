source /etc/static/zshrc
eval "$(/opt/homebrew/bin/brew shellenv)"
eval "$(zoxide init zsh)"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/toast/.lmstudio/bin"
# End of LM Studio CLI section


. "$HOME/.local/bin/env"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/toast/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/toast/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/toast/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/toast/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<