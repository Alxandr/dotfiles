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

function ConvertTo-CultureObject {
  param(
    [Parameter(Mandatory = $true, Position = 0)]
    [System.Globalization.CultureInfo]$Culture
  )

  If ($null -eq $Culture) {
    return $null
  }

  return @{
    "id"      = $Culture.Name
    "formats" = @{
      "date-time" = @{
        "full-date-time" = $Culture.DateTimeFormat.FullDateTimePattern
        "long-date"      = $Culture.DateTimeFormat.LongDatePattern
        "long-time"      = $Culture.DateTimeFormat.LongTimePattern
        "short-date"     = $Culture.DateTimeFormat.ShortDatePattern
        "short-time"     = $Culture.DateTimeFormat.ShortTimePattern
      }
    }
  }
}

function ConvertTo-WinGeoIdObject {
  param(
    [Parameter(Mandatory = $true, Position = 0)]
    [Microsoft.InternationalSettings.Commands.WinGeoId]$WinGeoId
  )

  If ($null -eq $WinGeoId) {
    return $null
  }

  return @{
    "id"   = $WinGeoId.GeoId
    "name" = $WinGeoId.HomeLocation
  }
}

# Adding some debug info to STDERR
'PSVersion=' + $PSVersionTable.PSVersion.ToString() | Write-DscTrace
'PSPath=' + $PSHome | Write-DscTrace
'PSModulePath=' + $env:PSModulePath | Write-DscTrace

# process the operation requested to the script
$ConfigObj = ConvertFrom-Json $Config

[System.Globalization.CultureInfo]$Culture = Get-Culture
[System.Globalization.CultureInfo]$SystemCulture = Get-WinSystemLocale
[System.Globalization.CultureInfo]$WinUILanguageOverride = Get-WinUILanguageOverride
[Microsoft.InternationalSettings.Commands.WinGeoId]$WinHomeLocation = Get-WinHomeLocation
[string]$SystemPreferredUILanguage = Get-SystemPreferredUILanguage
[string]$SystemLanguage = Get-SystemLanguage

[System.Globalization.CultureInfo]$TargetCulture = (Get-Culture -Name $ConfigObj.id).Clone()
If ($null -ne $ConfigObj.formats."date-time"."short-time") {
  $TargetCulture.DateTimeFormat.ShortTimePattern = $ConfigObj.formats."date-time"."short-time"
}
If ($null -ne $ConfigObj.formats."date-time"."short-date") {
  $TargetCulture.DateTimeFormat.ShortDatePattern = $ConfigObj.formats."date-time"."short-date"
}
If ($null -ne $ConfigObj.formats."date-time"."long-date") {
  $TargetCulture.DateTimeFormat.LongDatePattern = $ConfigObj.formats."date-time"."long-date"
}
If ($null -ne $ConfigObj.formats."date-time"."long-time") {
  $TargetCulture.DateTimeFormat.LongTimePattern = $ConfigObj.formats."date-time"."long-time"
}
If ($null -ne $ConfigObj.format."date-time"."full-date-time") {
  $TargetCulture.DateTimeFormat.FullDateTimePattern = $ConfigObj.format."date-time"."full-date-time"
}

$TargetCulture = [System.Globalization.CultureInfo]::ReadOnly($TargetCulture)

If ('Set' -eq $Operation) {
  [int]$TargetLocation = $ConfigObj."home-location"

  Set-Culture $TargetCulture
  Set-WinSystemLocale $TargetCulture
  Set-WinUILanguageOverride $TargetCulture
  Set-SystemPreferredUILanguage $TargetCulture.Name
  Set-SystemLanguage $TargetCulture.Name
  Set-WinHomeLocation $TargetLocation
  Copy-UserInternationalSettingsToSystem -WelcomeScreen $true -NewUser $true

  Set-ItemProperty -Path 'HKCU:\Control Panel\International' -Name 'sShortTime' -Value $TargetCulture.DateTimeFormat.ShortTimePattern
  Set-ItemProperty -Path 'HKCU:\Control Panel\International' -Name 'sShortDate' -Value $TargetCulture.DateTimeFormat.ShortDatePattern
  Set-ItemProperty -Path 'HKCU:\Control Panel\International' -Name 'sLongDate' -Value $TargetCulture.DateTimeFormat.LongDatePattern
  Set-ItemProperty -Path 'HKCU:\Control Panel\International' -Name 'sLongTime' -Value $TargetCulture.DateTimeFormat.LongTimePattern
  Set-ItemProperty -Path 'HKCU:\Control Panel\International' -Name 'sTimeFormat' -Value $TargetCulture.DateTimeFormat.LongTimePattern

  $Culture = Get-Culture
  $SystemCulture = Get-WinSystemLocale
  $WinUILanguageOverride = Get-WinUILanguageOverride
  $SystemPreferredUILanguage = Get-SystemPreferredUILanguage
  $SystemLanguage = Get-SystemLanguage
  $WinHomeLocation = Get-WinHomeLocation
}

return @{
  "culture"                      = (ConvertTo-CultureObject $Culture)
  "system-culture"               = (ConvertTo-CultureObject $SystemCulture)
  "winui-override"               = (ConvertTo-CultureObject $WinUILanguageOverride)
  "home-location"                = (ConvertTo-WinGeoIdObject $WinHomeLocation)
  "target"                       = (ConvertTo-CultureObject $TargetCulture)
  "system-language"              = $SystemLanguage
  "system-preferred-ui-language" = $SystemPreferredUILanguage
} | ConvertTo-Json -Depth 20 -Compress
