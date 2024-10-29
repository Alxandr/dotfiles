#Requires -RunAsAdministrator

function Add-Path {
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

function Confirm-Choice {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Title,

    [Parameter(Mandatory = $false)]
    [string]$Message
  )

  [int]$Choice = $Host.UI.PromptForChoice($Title, $null, @('&Yes', '&No'), 1)
  return ($Choice -eq 0)
}

function Invoke-BootstrapWorkload {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Path,

    [Parameter(Mandatory = $true)]
    [string]$WorkloadName
  )


  Write-Host "Bootstrapping $WorkloadName"
  dsc config set --path $Path
}

class Workload {
  [string]$Name
  [string]$Path

  Workload([string]$Name, [string]$Path) {
    $this.Name = $Name
    $this.Path = $Path
  }
}


Add-Path -Prepend "$HOME/.local/bin"
Add-Path -Prepend "$HOME/.local/dsc"

if (Confirm-Choice "install dependencies?") {
  Install-PSResource -Name Microsoft.Winget.DSC -Prerelease
  Install-PSResource -Name PSDscResources
}

Write-Host "Boostrapping scripts location: $($PSScriptRoot)"

$Workloads = @(
  [Workload]::new("Windows Locale", (Join-Path $PSScriptRoot "base" "locale.yml")),
  [Workload]::new("Windows Settings", (Join-Path $PSScriptRoot "base" "settings.yml")),
  [Workload]::new("Common Windows Apps", (Join-Path $PSScriptRoot "base" "apps.yml"))
)

$WorkloadFiles = Get-ChildItem (Join-Path $PSScriptRoot "workloads") -File | Sort-Object -Property BaseName
foreach ($File in $WorkloadFiles) {
  [string]$WorkloadName = [regex]::Replace($File.BaseName, '^[0-9]{1,2}\-', '')
  [string]$Path = $File.FullName
  If (Confirm-Choice "Bootstrap $WorkloadName workload?") {
    $Workloads += [Workload]::new($WorkloadName, $Path)
  }
}

foreach ($Workload in $Workloads) {
  Invoke-BootstrapWorkload -Path $Workload.Path -WorkloadName $Workload.Name
}
