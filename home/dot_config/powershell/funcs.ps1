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

Function Start-VisualStudio {
  [System.Management.Automation.PathInfo]$pwd = Get-Location
  $candidates = Get-ChildItem -Path $pwd -Filter *.sln -Recurse -File
  [string]$solution

  If ($candidates.Count -eq 0) {
    Write-Error "No solution files found in $pwd"
    Return
  }
  ElseIf ($candidates.Count -eq 1) {
    $solution = [System.IO.Path]::GetRelativePath($pwd.Path, $candidates[0].FullName) | Out-String
  }
  Else {
    [string]$candidateList = $candidates | ForEach-Object { [System.IO.Path]::GetRelativePath($pwd.Path, $_.FullName) } | Out-String
    $solution = $candidateList | fzf.exe --header "Select a solution file" --height "20%"
  }

  [string]$fullPath = Join-Path $pwd $solution
  Write-Debug "Starting: $fullPath"

  Start-Process $fullPath
}
