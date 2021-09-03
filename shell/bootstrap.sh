path_prepend "$HOME/.local/bin"
path_prepend "$HOME/.dotfiles/bin"

# detect WSL
if [ $(uname -a | grep -c "Microsoft") -eq 1 ]; then
  export ISWSL=1 # WSL 1
elif [ $(uname -a | grep -c "microsoft") -eq 1 ]; then
  export ISWSL=2 # WSL 2
else
  export ISWSL=0
fi
