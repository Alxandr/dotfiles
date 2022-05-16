Function Add-Path {
  [CmdletBinding(PositionalBinding = $false)]
  param (
    [Parameter()]
    [switch]$Prepend,

    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Dir
  )

  [string]$Resolved = Resolve-Path $Dir

  if ($Prepend) {
    $env:Path = "$Resolved;$env:Path"
  }
  else {
    $env:Path = "$env:Path;$Resolved"
  }
}

Function Test-CommandExists {

  Param ([Parameter()][string]$command)

  $oldPreference = $ErrorActionPreference

  $ErrorActionPreference = ‘stop’

  try { if (Get-Command $command) { Return $true } }

  Catch { Return $false }

  Finally { $ErrorActionPreference = $oldPreference }
}
