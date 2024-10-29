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

function ConvertTo-FeaturesObject {
  param(
    [Parameter(Mandatory = $true, Position = 0)]
    [Microsoft.LanguagePackManagement.Powershell.Commands.LanguageFeatures]$Features
  )

  return @{
    "basic-typing"     = $Features.HasFlag([Microsoft.LanguagePackManagement.Powershell.Commands.LanguageFeatures]::BasicTyping)
    "fonts"            = $Features.HasFlag([Microsoft.LanguagePackManagement.Powershell.Commands.LanguageFeatures]::Fonts)
    "handwriting"      = $Features.HasFlag([Microsoft.LanguagePackManagement.Powershell.Commands.LanguageFeatures]::Handwriting)
    "speech"           = $Features.HasFlag([Microsoft.LanguagePackManagement.Powershell.Commands.LanguageFeatures]::Speech)
    "text-to-speech"   = $Features.HasFlag([Microsoft.LanguagePackManagement.Powershell.Commands.LanguageFeatures]::TextToSpeech)
    "ocr"              = $Features.HasFlag([Microsoft.LanguagePackManagement.Powershell.Commands.LanguageFeatures]::OCR)
    "locale-data"      = $Features.HasFlag([Microsoft.LanguagePackManagement.Powershell.Commands.LanguageFeatures]::LocaleData)
    "supplement-fonts" = $Features.HasFlag([Microsoft.LanguagePackManagement.Powershell.Commands.LanguageFeatures]::SupplementFonts)
  }
}

# Adding some debug info to STDERR
'PSVersion=' + $PSVersionTable.PSVersion.ToString() | Write-DscTrace
'PSPath=' + $PSHome | Write-DscTrace
'PSModulePath=' + $env:PSModulePath | Write-DscTrace

# process the operation requested to the script
$ConfigObj = ConvertFrom-Json $Config
$Lang = (Get-InstalledLanguage -Language $ConfigObj.id)[0]

If ($null -eq $Lang) {
  $Installed = $false
  $Id = $ConfigObj.id
  $Features = [Microsoft.LanguagePackManagement.Powershell.Commands.LanguageFeatures]::None
}
Else {
  $Installed = $true
  $Id = $Lang.LanguageId
  $Features = $Lang.LanguageFeatures
}

[Microsoft.LanguagePackManagement.Powershell.Commands.LanguageFeatures]$RequestedFeatures = [Microsoft.LanguagePackManagement.Powershell.Commands.LanguageFeatures]::None
If ($ConfigObj.features."basic-typing") {
  $RequestedFeatures += [Microsoft.LanguagePackManagement.Powershell.Commands.LanguageFeatures]::BasicTyping
}
If ($ConfigObj.features."fonts") {
  $RequestedFeatures += [Microsoft.LanguagePackManagement.Powershell.Commands.LanguageFeatures]::Fonts
}
If ($ConfigObj.features."handwriting") {
  $RequestedFeatures += [Microsoft.LanguagePackManagement.Powershell.Commands.LanguageFeatures]::Handwriting
}
If ($ConfigObj.features."speech") {
  $RequestedFeatures += [Microsoft.LanguagePackManagement.Powershell.Commands.LanguageFeatures]::Speech
}
If ($ConfigObj.features."text-to-speech") {
  $RequestedFeatures += [Microsoft.LanguagePackManagement.Powershell.Commands.LanguageFeatures]::TextToSpeech
}
If ($ConfigObj.features."ocr") {
  $RequestedFeatures += [Microsoft.LanguagePackManagement.Powershell.Commands.LanguageFeatures]::OCR
}
If ($ConfigObj.features."locale-data") {
  $RequestedFeatures += [Microsoft.LanguagePackManagement.Powershell.Commands.LanguageFeatures]::LocaleData
}
If ($ConfigObj.features."supplement-fonts") {
  $RequestedFeatures += [Microsoft.LanguagePackManagement.Powershell.Commands.LanguageFeatures]::SupplementFonts
}

$Covered = $Features.HasFlag($RequestedFeatures)

If ('Get' -eq $Operation) {
  return @{
    id        = $Id
    installed = $Installed
    features  = (ConvertTo-FeaturesObject $Features)
    covered   = $Covered
  } | ConvertTo-Json -Compress
}

if ('Set' -eq $Operation) {
  If ($Covered) {
    # "Language already covered, not installing" | Write-DscTrace Info
    return @{
      id        = $Id
      installed = $Installed
      features  = (ConvertTo-FeaturesObject $Features)
      covered   = $Covered
    } | ConvertTo-Json -Compress
  }

  "Installing language $Id" | Write-DscTrace Info
  $Lang = (Install-Language -Language $Id)[0]
  $Features = $Lang.LanguageFeatures
  $Covered = $Features.HasFlag($RequestedFeatures)

  return @{
    id        = $Id
    installed = $Installed
    features  = (ConvertTo-FeaturesObject $Features)
    covered   = $Covered
  } | ConvertTo-Json -Compress
}
