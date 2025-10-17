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

  Param ([Parameter()][string]$filter = "")

  [System.Management.Automation.PathInfo]$pwd = Get-Location
  $candidates = Get-ChildItem -Path $pwd -Filter *.sln? -Recurse -File
  [string]$solution

  [string]$candidateList = $candidates | ForEach-Object { [System.IO.Path]::GetRelativePath($pwd.Path, $_.FullName) } | Out-String
  $solution = $candidateList | fzf.exe --header "Select a solution file" --height "20%" --select-1 --exit-0 --query="$filter"

  If ([string]::IsNullOrEmpty($solution)) {
    Write-Error "No solution file selected."
    Return
  }

  [string]$fullPath = Join-Path $pwd $solution
  Write-Debug "Starting: $fullPath"

  Start-Process $fullPath

  Write-Host "Solution: $solution"
}

Function Set-Owner {
  param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string[]]$Path,

    [Parameter(Mandatory = $false)]
    [switch]$Recurse,

    [Parameter(Mandatory = $false)]
    [switch]$Force
  )

  $Items = Get-ChildItem -Path $Path -Recurse:$Recurse -Force:$Force
  [System.Security.Principal.WindowsIdentity]$Identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
  [System.Security.Principal.NTAccount]$UserRef = New-Object System.Security.Principal.NTAccount($Identity.Name)
  Write-Host "Setting owner to $($Identity.Name)"

  foreach ($Item in $Items) {
    $Acl = Get-Acl -Path $Item.FullName
    $Acl.SetOwner($UserRef)
    Set-Acl -Path $Item.FullName -AclObject $Acl
    Write-Host $Item.FullName
  }
}

function Invoke-BootstrapWindows {
  $ChezmoiDir = Split-Path (chezmoi source-path) -Parent
  $BootstrapPath = Join-Path $ChezmoiDir "dsc" "bootstrap-windows.ps1"
  & "$BootstrapPath"
}
