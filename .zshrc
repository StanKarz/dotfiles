# ---------- Oh My Zsh ----------
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"

# Plugins (note: zsh-autosuggestions and zsh-syntax-highlighting must be
# cloned into ~/.oh-my-zsh/custom/plugins/ — see README)
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
)

# Source Oh My Zsh (also runs compinit)
source $ZSH/oh-my-zsh.sh

# ---------- Completion ----------
unsetopt flowcontrol
setopt auto_menu          # show completion menu on successive tab press
setopt complete_in_word
setopt always_to_end

zstyle ':completion:*' menu select
zstyle ':completion:*' file-patterns '%p:globbed-files' '*(-/):directories' '*:all-files'

# Shift+Tab cycles backwards through the completion menu
bindkey '^[[Z' menu-complete

# ---------- zsh-autosuggestions ----------
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
ZSH_AUTOSUGGEST_USE_ASYNC=true
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=cyan"

# Right arrow / End accept the suggestion by default; Ctrl+F as alternative
bindkey '^F' autosuggest-accept

# ---------- History ----------
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS

# ---------- Prompt ----------
eval "$(starship init zsh)"

# ---------- Tools ----------
# Broot
[ -f "$HOME/.config/broot/launcher/bash/br" ] && source "$HOME/.config/broot/launcher/bash/br"

# Local bin
[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"

# envman
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# uv shell completion
if command -v uv &> /dev/null; then
    eval "$(uv generate-shell-completion zsh)"
fi

# zoxide
eval "$(zoxide init zsh)"

# fzf (Ctrl+R: fuzzy history, Ctrl+T: fuzzy file picker, Alt+C: fuzzy cd)
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# ---------- Aliases ----------
alias lt='eza -T --icons'
alias ciaclean='git branch --merged origin/main | grep -vE "^\* |^[[:space:]]+(main|develop)$" | xargs -n 1 git branch -d'
