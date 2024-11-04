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

## Bootstrapping Windows

1. enable developer mode on the computer
2. install prerequisites chezmoi, git, and pwsh
  `winget install git.git twpayne.chezmoi microsoft.powershell`
3. initialize chezmoi (not as admin)
  `chezmoi init Alxandr`
4. restart terminal
5. apply chezmoi (not as admin)
  `chezmoi apply`
6. restart terminal
7. run bootstrapper (as admin)
  `Invoke-BootstrapWindows`
