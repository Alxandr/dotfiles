# dircolors
if [[ "$(tput colors)" == "256" ]]; then
  eval "$(dircolors ~/.config/shell/plugins/dircolors-solarized/dircolors.256dark)"
fi

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

# zoxide
if [ -x "$(command -v zoxide)" ]; then
  eval "$(zoxide init bash)"
  alias zz="z -"
fi
