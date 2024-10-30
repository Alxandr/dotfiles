[CmdletBinding()]
Param(
  [Parameter(Mandatory = $true, Position = 0, HelpMessage = 'Operation to perform. Choose from Get, Set, Test.')]
  [ValidateSet('Get', 'Set', 'Test')]
  [string]$Operation,

  [Parameter(Mandatory = $false, Position = 1, ValueFromPipeline = $true, HelpMessage = 'Configuration or resource input in JSON format.')]
  [string]$Config = '{}'
)

function Write-DscTrace {
  param(
    [Parameter(Mandatory = $false)]
    [ValidateSet('Error', 'Warn', 'Info', 'Debug', 'Trace')]
    [string]$Operation = 'Debug',

    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [string]$Message
  )

  $trace = @{$Operation = $Message } | ConvertTo-Json -Compress
  $host.ui.WriteErrorLine($trace)
}

function ConvertTo-VsCodeExtensionObject {
  param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Id,

    [Parameter(Mandatory = $true, Position = 1)]
    [bool]$Installed
  )

  If ($null -eq $Id) {
    return $null
  }

  [string]$State

  If ($Installed) {
    $State = 'installed'
  }
  Else {
    $State = 'uninstalled'
  }

  return @{
    "id"    = $Id
    "state" = $State
  }
}

# Adding some debug info to STDERR
'PSVersion=' + $PSVersionTable.PSVersion.ToString() | Write-DscTrace
'PSPath=' + $PSHome | Write-DscTrace
'PSModulePath=' + $env:PSModulePath | Write-DscTrace

# process the operation requested to the script
$ConfigObj = ConvertFrom-Json $Config

[System.Collections.Generic.HashSet[string]]$InstalledExtensions = [System.Collections.Generic.HashSet[string]]::new()
foreach ($Extension in (code --list-extensions)) {
  $InstalledExtensions.Add($Extension) | Out-Null
}

[bool]$Installed = $InstalledExtensions.Contains($ConfigObj.id)

If ('Set' -eq $Operation -and !$Installed) {
  code --install-extension $ConfigObj.id | Out-Null
  $Installed = $true
}

return ConvertTo-VsCodeExtensionObject $ConfigObj.id $Installed | ConvertTo-Json -Depth 20 -Compress
