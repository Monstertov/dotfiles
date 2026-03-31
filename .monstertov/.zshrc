export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="sharp"

plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  sudo
  history
  gh
  zoxide
  command-not-found
  tmux
  history-substring-search
)

source $ZSH/oh-my-zsh.sh

eval "$(zoxide init zsh)"

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# ── PATH ──────────────────────────────────────────────────────────────
export PATH="$HOME/.npm-global/bin:$HOME/.local/bin:$PATH"

# ── ENV ───────────────────────────────────────────────────────────────
export CLAUDE_PLUGIN_ROOT="$HOME/.claude/plugins/cache/everything-claude-code/everything-claude-code/1.9.0"

# ── ALIASES ───────────────────────────────────────────────────────────
alias ls='ls --color=auto'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias claudeskip="claude --dangerously-skip-permissions"
alias sudoclaudeskip="sudo claude --dangerously-skip-permissions"
alias sudo='sudo '
alias code='code --user-data-dir="$HOME/.vscode-root" --no-sandbox'
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
alias tmuxa='tmux attach-session -t'


# load ~/.bash_aliases if it exists
[[ -f ~/.bash_aliases ]] && source ~/.bash_aliases

# ── AUTOSUGGESTIONS ───────────────────────────────────────────────────
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#555555"

# subtle syntax highlighting — no loud green/red
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[command]='fg=cyan'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=cyan'
ZSH_HIGHLIGHT_STYLES[alias]='fg=cyan'
ZSH_HIGHLIGHT_STYLES[function]='fg=cyan'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#e06c75'      # soft red, not screaming
ZSH_HIGHLIGHT_STYLES[path]='fg=white'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#e5c07b'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#e5c07b'
ZSH_HIGHLIGHT_STYLES[option]='fg=white'
ZSH_HIGHLIGHT_STYLES[comment]='fg=#555555'
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
bindkey '→' autosuggest-accept
bindkey '^[[C' autosuggest-accept   # right arrow fallback

# ── DIRCOLORS (bright blue folders) ───────────────────────────────────
[[ -f ~/.dircolors ]] && eval "$(dircolors -b ~/.dircolors)"

# ── HISTORY ───────────────────────────────────────────────────────────
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
