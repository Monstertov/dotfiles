local path_color='%F{cyan}'
local reset='%f'

PROMPT="%F{white}%n${path_color}@%F{white}%m${reset} ${path_color}%~${reset} %F{white}>%f "

# right side: git branch if in a repo
RPROMPT='$(git_prompt_info)'

ZSH_THEME_GIT_PROMPT_PREFIX="%F{242}("
ZSH_THEME_GIT_PROMPT_SUFFIX=")%f"
ZSH_THEME_GIT_PROMPT_DIRTY="*"
ZSH_THEME_GIT_PROMPT_CLEAN=""
