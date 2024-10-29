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

function ConvertTo-FeatureStateString {
  param(
    [Parameter(Mandatory = $true, Position = 0)]
    [Microsoft.Dism.Commands.FeatureState]$State
  )

  If ($null -eq $State) {
    return $null
  }

  switch ($State) {
    "Disabled" { return "disabled" }
    "Enabled" { return "enabled" }
    "DisablePending" { return "disable-pending" }
    "EnablePending" { return "enable-pending" }
    "Superseded" { return "superseded" }
    "PartiallyInstalled" { return "partially-installed" }
    "DisabledWithPayloadRemoved" { return "disabled-with-payload-removed" }
    Default { return $State.ToString() }
  }
}

function ConvertTo-WindowsOptionalFeatureObject {
  param(
    [Parameter(Mandatory = $true, Position = 0)]
    [Microsoft.Dism.Commands.AdvancedFeatureObject]$Feature
  )

  If ($null -eq $Feature) {
    return $null
  }

  return @{
    "name"  = $Feature.FeatureName
    "state" = (ConvertTo-FeatureStateString $Feature.State)
  }
}

# Adding some debug info to STDERR
'PSVersion=' + $PSVersionTable.PSVersion.ToString() | Write-DscTrace
'PSPath=' + $PSHome | Write-DscTrace
'PSModulePath=' + $env:PSModulePath | Write-DscTrace

# process the operation requested to the script
$ConfigObj = ConvertFrom-Json $Config

[Microsoft.Dism.Commands.AdvancedFeatureObject]$Feature = Get-WindowsOptionalFeature -Online -FeatureName $ConfigObj.name

If ('Set' -eq $Operation -and $null -ne $Feature) {
  $State = ConvertTo-FeatureStateString $Feature.State
  If ($ConfigObj.state -ne $State) {
    If ('enabled' -eq $ConfigObj.state) {
      Enable-WindowsOptionalFeature -Online -FeatureName $Feature.FeatureName -NoRestart -All:$ConfigObj.all
    }
    ElseIf ('disabled' -eq $ConfigObj.state) {
      Disable-WindowsOptionalFeature -Online -FeatureName $Feature.FeatureName -NoRestart
    }
  }

  $Feature = Get-WindowsOptionalFeature -Online -FeatureName $Feature.FeatureName
}

return ConvertTo-WindowsOptionalFeatureObject $Feature | ConvertTo-Json -Depth 20 -Compress
