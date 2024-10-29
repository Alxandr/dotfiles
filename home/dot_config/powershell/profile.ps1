# ~/.config/powershell/profile.ps1
# ============================================================================
# Powershell profile settings.
#
# On Windows, this file will be linked over to
# `$Env:USERPROFILE\Documents\WindowsPowershell\profile.ps1` and
# `$Env:USERPROFILE\Documents\Powershell\profile.ps1`
# after `chezmoi apply` by the script `../run_after_link-external.ps1.tmpl`.

<#
	.SYNOPSIS
		Profile File
	.DESCRIPTION
		Profile File
	.NOTES
		Leonardo Calbi
	.LINK
		https://github.com/LeoCalbi/dotfiles
#>


# -----------------------------------------------------------------------------
#                              User Profile
# -----------------------------------------------------------------------------

#                              Notes
# -----------------------------------------------------------------------------

# Move to Home directory if in System32
if ($PWD -eq "C:\Windows\System32") {
  Set-Location $HOME
}

[string] $PowerShellConfigDir = "$HOME/.config/powershell"

# functions
. (Join-Path $PowerShellConfigDir "funcs.ps1")

# autocomplete
. (Join-Path $PowerShellConfigDir "autocomplete.ps1")

# local
If (Test-Path (Join-Path $PowerShellConfigDir "profile-local.ps1")) {
  # Write-Host "Loading local profile..."
  . (Join-Path $PowerShellConfigDir "profile-local.ps1")
}
# Else {
#   Write-Host "Local profile, $(Join-Path $PowerShellConfigDir "profile-local.ps1"), not found."
# }

Add-Path -Prepend "$HOME/.local/bin"
Add-Path -Prepend "$HOME/.local/dsc"

Set-Alias vs Start-VisualStudio

# prompt
If (Test-CommandExists starship) {
  $Env:STARSHIP_CONFIG = (Join-Path $PSScriptRoot "starship.toml")
  Invoke-Expression (&starship init powershell)
}

# zoxide (if it exists)
If (Test-CommandExists zoxide) {
  Function __Z_BACK {
    z -
  }

  Invoke-Expression (& {
      $hook = if ($PSVersionTable.PSVersion.Major -lt 6) { 'prompt' } else { 'pwd' }
      (zoxide init --hook $hook powershell | Out-String)
    }
  )

  Set-Alias zz __Z_BACK
}

# bat (if it exists)
If (Test-CommandExists bat) {
  Function BatDefault {
    bat --style=plain --paging=never $args
  }

  Function BatMore {
    bat --style=plain --paging=always $args
  }

  Set-Alias cat BatDefault
  Set-Alias catmore BatMore
}
Else {
  Set-Alias cat Get-Content
  Set-Alias catmore Get-Content
}
