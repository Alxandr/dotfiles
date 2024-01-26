[string] $ChezmoiFontsDir = "$HOME\.cache\chezmoi\fonts"

. "$PSScriptRoot\font-functions.ps1"

# [void] [System.Reflection.Assembly]::LoadWithPartialName("PresentationCore")

# Function Install-Font {
#   <#
#   .SYNOPSIS
#     Installs (or updates) a user font
#   .INPUTS
#     System.IO.FileInfo
#   .OUTPUTS
#     None
#   #>
#   [CmdletBinding()]
#   Param(
#     [Parameter(Mandatory = $true)]
#     [System.IO.FileInfo]$FontFile
#   )

#   Try {
#     # Get font name
#     $Font = [Windows.Media.GlyphTypeface]::new($FontFile.FullName)
#     $Family = $Font.Win32FamilyNames['en-us']
#     $Face = $Font.Win32FaceNames['en-us']

#     if ($null -eq $Family) {
#       $Family = $Font.Win32FamilyNames.Values.Item(0)
#     }

#     if ($null -eq $Face) {
#       $Face = $Font.Win32FaceNames.Values.Item(0)
#     }

#     $FontName = ("$family $face").Trim()

#     switch ($fontFile.Extension) {
# 			".ttf" {$FontName = "$FontName (TrueType)"}
#       ".otf" {$FontName = "$FontName (OpenType)"}
#       default {"Invalid font extension: $($fontFile.Extension)"}
#     }

#     Write-Debug "Installing font: $FontFile with font name '$FontName'"

#     [string] $DstFile = "$UserFontsDir\$($FontFile.Name)"
#     If (!(Test-Path $DstFile)) {
#       Write-Host "Copying font: $FontFile"
#       # Ensure directory exists
#       If (!(Test-Path $UserFontsDir)) {
#         New-Item $UserFontsDir -ItemType Directory | Out-Null
#       }
#       Copy-Item $FontFile.FullName $DstFile | Out-Null
#     } Else {
#       # Todo: diff files (checksum)
#       Write-Host "Font file already exists at destination"
#     }

#     If (!(Get-ItemProperty -Name $FontName -Path $RegistryPath -ErrorAction SilentlyContinue)) {
#       Write-Host "Registering font: $FontFile"
#       New-ItemProperty -Name $FontName -Path $RegistryPath -PropertyType string -Value $FontFile.Name -Force
#     } Else {
#       Write-Host "Font already registered: $FontFile"
#     }
#   } Catch {
#     Write-Error "Failed to install font: $FontFile. $($_.exception.message)"
#   }
# }

Get-ChildItem $ChezmoiFontsDir | Where-Object { $_.PSIsContainer } | ForEach-Object {
  [string] $Name = $_.BaseName
  Write-Host "Installing font: $Name"

  Get-ChildItem $_ | ForEach-Object {
    Install-Font $_
  }
}
