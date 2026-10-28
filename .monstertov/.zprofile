# Login shells: pick up ~/.profile (PATH for ~/.local/bin and ~/bin), like bash does
[[ -r ~/.profile ]] && emulate sh -c '. ~/.profile'
