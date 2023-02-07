# shellcheck shell=bash

path_prepend "$HOME/.local/bin"
path_prepend "$HOME/.cargo/bin"

export PNPM_HOME="$HOME/.local/share/pnpm"
path_prepend "$PNPM_HOME"

export N_PREFIX="$HOME/.local/share/node"
path_prepend "$N_PREFIX/bin"

# detect WSL
if [ "$(uname -a | grep -c "Microsoft")" -eq 1 ]; then
  export ISWSL=1 # WSL 1
  source ~/.config/shell/wsl.sh
elif [ "$(uname -a | grep -c "microsoft")" -eq 1 ]; then
  export ISWSL=2 # WSL 2
  source ~/.config/shell/wsl.sh
else
  export ISWSL=0
fi

# Set docker buildkit env
export DOCKER_BUILDKIT=1
