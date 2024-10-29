. "$PSScriptRoot\management-functions.ps1"

Add-Path -Prepend "$HOME/.local/dsc"

Install-PSResource Microsoft.Winget.DSC -Prerelease
Install-PSResource LanguageDsc
