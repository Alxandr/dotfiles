# github.com/Alxandr/dotfiles

Alxandr's dotfiles, managed with [`chezmoi`](https://github.com/twpayne/chezmoi).

Install them with:

    chezmoi init Alxandr

Secrets are stored in [1Password](https://1password.com/), and you'll need
the [1Password
CLI](https://support.1password.com/command-line-getting-started/) installed.
Login to 1Password for the first time with:

    eval $(op signin <subdomain>.1password.com <email>)

Then, to login afterwards, run:

    eval $(op signin)
