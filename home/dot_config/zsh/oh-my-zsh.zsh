# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Disable omz auto-update (handled by chezmoi)
DISABLE_AUTO_UPDATE="true"

# Which plugins would you like to load? (plugins can be found in $ZSH/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh
