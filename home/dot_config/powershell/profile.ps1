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

# functions
. (Join-Path $PSScriptRoot "funcs.ps1")

# autocomplete
. (Join-Path $PSScriptRoot "autocomplete.ps1")

Add-Path -Prepend "$HOME/.local/bin"

# prompt
$Env:STARSHIP_CONFIG = (Join-Path $PSScriptRoot "starship.toml")
Invoke-Expression (&starship init powershell)

Function __Z_BACK {
  z -
}

# zoxide (if it exists)
If (Test-CommandExists zoxide) {
  Invoke-Expression (& {
      $hook = if ($PSVersionTable.PSVersion.Major -lt 6) { 'prompt' } else { 'pwd' }
      (zoxide init --hook $hook powershell | Out-String)
    }
  )

  Set-Alias zz __Z_BACK
}
