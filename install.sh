if [ ! -d "/root/.oh-my-zsh" ]; then
  curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh | bash -s -- --unattended
fi

curl -fsSL https://starship.rs/install.sh | bash -s -- -y

rm -f ~/.zshrc
ln -s ./.zshrc ~/zshrc
