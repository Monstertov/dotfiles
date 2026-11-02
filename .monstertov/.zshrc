export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="sharp"

plugins=(
  git
  fzf-tab
  zsh-autosuggestions
  zsh-syntax-highlighting
  sudo
  history
  gh
  zoxide
  command-not-found
  tmux
  history-substring-search
  you-should-use
)

source $ZSH/oh-my-zsh.sh

# zoxide (z) is set up by its plugin above. Down arrow is bound under KEYS.
bindkey '^[[A' history-substring-search-up

# ── FZF-TAB ───────────────────────────────────────────────────────────
# Tab completion opens an fzf picker. Folders get an eza preview when eza exists.
zstyle ':completion:*' menu no
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':fzf-tab:*' switch-group '<' '>'
if command -v eza >/dev/null 2>&1; then
  zstyle ':fzf-tab:complete:(cd|z|__zoxide_z):*' fzf-preview 'eza -1 --color=always --icons=auto $realpath'
fi

# ── PATH ──────────────────────────────────────────────────────────────
export PATH="$HOME/.npm-global/bin:$HOME/.local/bin:$PATH"

# ── ALIASES ───────────────────────────────────────────────────────────
if command -v eza >/dev/null 2>&1; then
  alias ls='eza --icons=auto --group-directories-first'
  alias ll='eza -alh --icons=auto --group-directories-first --git'
  alias la='eza -a --icons=auto --group-directories-first'
  alias l='eza --icons=auto --group-directories-first'
  alias lt='eza --tree --level=2 --icons=auto'
else
  alias ls='ls --color=auto'
  alias ll='ls -alF'
  alias la='ls -A'
  alias l='ls -CF'
fi
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias claudeskip="claude --dangerously-skip-permissions"
alias sudoclaudeskip="sudo claude --dangerously-skip-permissions"
alias sudo='sudo '
alias sudocode='sudo code --user-data-dir="$HOME/.vscode-root" --no-sandbox'
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
alias tmuxa='tmux attach-session -t'
# in kitty, use kitten ssh so remote terminfo works (fixes garbled line editing)
[[ -n "$KITTY_WINDOW_ID" ]] && alias ssh='kitten ssh'


# load ~/.bash_aliases if it exists
[[ -f ~/.bash_aliases ]] && source ~/.bash_aliases

# ── AUTOSUGGESTIONS ───────────────────────────────────────────────────
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#8f8f8f"

# subtle syntax highlighting: no loud green/red
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
ZSH_HIGHLIGHT_STYLES[comment]='fg=#9a9a9a'
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

# ── FZF: Ctrl+R fuzzy history, Ctrl+T fuzzy file, Alt+C fuzzy cd, **<Tab> fuzzy completion ──
if command -v fzf >/dev/null; then
  if fzf --zsh >/dev/null 2>&1; then
    source <(fzf --zsh)
  else
    # fzf older than 0.48 (Debian 12, Ubuntu 24.04) has no --zsh, its packages ship the scripts instead
    for f in /usr/share/doc/fzf/examples/{key-bindings,completion}.zsh; do [[ -r $f ]] && source $f; done
  fi
fi
# sharp theme colours: white text, cyan matches and accents, grey for the quiet parts
export FZF_DEFAULT_OPTS="--color=fg:white,bg:-1,hl:117,fg+:white:bold,bg+:24,hl+:117:bold,info:252,prompt:75,pointer:75,marker:75,spinner:75,header:252,border:245,gutter:-1"

# ── KEYS ──────────────────────────────────────────────────────────────
# Ctrl+Backspace deletes the previous word (Windows Terminal sends ^H), same as ~/.inputrc for bash
bindkey '^H' backward-kill-word

# Tab always completes against what is on disk. Right arrow takes the grey history suggestion.

# Down arrow opens a list of earlier commands matching what is typed (fzf, arrows to pick, Enter puts
# it on the prompt). While stepping back through matches with Up, Down still steps forward again.
history-down-or-list() {
  if [[ -n $BUFFER && $BUFFER == ${_history_substring_search_result:-} ]] \
     && (( ${_history_substring_search_match_index:-0} >= 1 )) \
     || (( ! ${+widgets[fzf-history-widget]} )); then
    zle history-substring-search-down
  else
    zle fzf-history-widget
  fi
}
zle -N history-down-or-list
ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(history-down-or-list)
bindkey '^[[B' history-down-or-list
[[ -n ${terminfo[kcud1]} ]] && bindkey "${terminfo[kcud1]}" history-down-or-list
# the list opens under the prompt and grows downward, so Down moves down it
export FZF_CTRL_R_OPTS="--layout=reverse"
