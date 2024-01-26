# ~/.local/share/chezmoi/run_after_link-external.ps1
# ============================================================================
# Runs after `chezmoi apply` to relocate configuration files as symlink and junction to their .config relatives.
#
# Requires the ability to create symlinks on the local system. By default in windows, this requires administrator,
# however, if you enable developer mode symlinks can be created without administrator access. To enable developer
# mode, run `start ms-settings:developers`.
#

. "$PSScriptRoot\management-functions.ps1"

#------------------------------------------------------------------------------
#                       Link Folders/Files Outside of ~ folder
#------------------------------------------------------------------------------

<#
	.SYNOPSIS
		Script to link files/folders outside of ~/.config/* with their respective target.
	.DESCRIPTION
		Script to link files/folders outside of ~/.config/* with their respective target.
	.NOTES
		Leonardo Calbi
	.LINK
		https://github.com/LeoCalbi/dotfiles
#>

[string] $PersonalDir = [Environment]::GetFolderPath([System.Environment+SpecialFolder]::Personal)

# $windows_terminal = [PSCustomObject]@{
#   Name      = "Windows Terminal"
#   Src       = Join-Path -Path $Env:USERPROFILE -ChildPath "\.config\windows_terminal\"
#   Dst       = Join-Path -Path $Env:LOCALAPPDATA -ChildPath "\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\"
#   Recursive = $true
# }

# $powershell = [PSCustomObject]@{
#   Name      = "System Powershell"
#   Src       = Join-Path -Path $Env:USERPROFILE -ChildPath "\.config\powershell"
#   Dst       = Join-Path -Path $Env:USERPROFILE -ChildPath "\Documents\WindowsPowershell\"
#   Recursive = $true
# }

$powershell_core = [PSCustomObject]@{
  Name      = "Powershell Core"
  Src       = Join-Path -Path $Env:USERPROFILE -ChildPath "\.config\powershell\"
  Dst       = "$HOME\Documents\PowerShell\"
  Recursive = $true
}

# $chocolatey_tools = [PSCustomObject]@{
#   Name      = "Chocolatey Tools"
#   Src       = Join-Path -Path $Env:USERPROFILE -ChildPath "\.config\chocolatey-tools\"
#   Dst       = Join-Path -Path $Env:ChocolateyToolsLocation -ChildPath "\BCURRAN3\"
#   Recursive = $true
# }

# $curl_settings = [PSCustomObject]@{
#   Name      = "Curl Settings"
#   Src       = Join-Path -Path $Env:USERPROFILE -ChildPath ".curlrc"
#   Dst       = Join-Path -Path $Env:USERPROFILE -ChildPath "_curlrc"
#   Recursive = $false
# }

# $myUtilities = [PSCustomObject]@{
#   Name      = "MyUtilities"
#   Src       = Join-Path -Path $Env:USERPROFILE -ChildPath ".config\custom-psmodules\MyUtilities\MyUtilities"
#   Dst       = Join-Path -Path $Env:USERPROFILE -ChildPath ".config\powershell\Modules\MyUtilities"
#   Recursive = $false
# }

# $gitStatusCachePoshClient = [PSCustomObject]@{
#   Name      = "GitStatusCachePoshClient"
#   Src       = Join-Path -Path $Env:USERPROFILE -ChildPath ".config\custom-psmodules\GitStatusCachePoshClient\GitStatusCachePoshClient"
#   Dst       = Join-Path -Path $Env:USERPROFILE -ChildPath ".config\powershell\Modules\GitStatusCachePoshClient"
#   Recursive = $false
# }

# $screenFetch = [PSCustomObject]@{
#   Name      = "ScreenFetch"
#   Src       = Join-Path -Path $Env:USERPROFILE -ChildPath ".config\custom-psmodules\ScreenFetch\ScreenFetch"
#   Dst       = Join-Path -Path $Env:USERPROFILE -ChildPath ".config\powershell\Modules\ScreenFetch"
#   Recursive = $false
# }

# Ensure powershell config folder exists
if ( -not (Test-Path $powershell_core.Dst)) {
  New-Item -Path $powershell_core.Dst -ItemType Directory -Force
}

$dst = @($powershell_core)

foreach ($d in $dst) {
  if ( -not (Test-Path $d.Src)) {
    Write-Error -Message "$($d.Name) source folder not found. Check for errors. Skipping $($d.Name) configuration.";
  }
  else {
    if ( -not (Test-Path $d.Dst)) {
      Write-Warning "$($d.Name) target folder ($($d.Dst)) not found. Check for errors. Skipping $($d.Name) configuration.";
    }
    else {
      Write-Output "Starting $($d.Name) configuration..."
      if ($d.Recursive) {
        $content = Get-ChildItem -Path $d.Src
        foreach ($c in $content) {
          # Write-Output "Source: $($c.FullName)"
          $target = (Join-Path -Path $d.Dst -ChildPath $c.Name)
          #Write-Output "Target: $target "
          Set-SymLink -SrcPath $c -DstPath $target
        }
      }
      else {
        $c = Get-Item -Path $d.Src
        Set-SymLink -SrcPath $c -DstPath $d.Dst
      }

      Write-Output "...$($d.Name) configuration completed."
    }
  }
}
