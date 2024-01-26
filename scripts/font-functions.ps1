<#
  .SYNOPSIS
    Functions to manage user/system fonts.
  .DESCRIPTION
    Functions to manage user/system fonts.
#>

Enum InstallTarget {
  User
  System
}

Function Get-FontsDirectory {
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory = $true)]
    [InstallTarget]$Target
  )

  Switch ($Target) {
    User { Return "$Env:LOCALAPPDATA\Microsoft\Windows\Fonts" }
    System { Return "$Env:WINDIR\Fonts" }
    Default { Throw "Invalid target" }
  }
}

Function Get-FontsRegistryPath {
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory = $true)]
    [InstallTarget]$Target
  )

  Switch ($Target) {
    User { Return "HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" }
    System { Return "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts" }
    Default { Throw "Invalid target" }
  }
}

Function Install-Font {
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory = $true, Position = 0)]
    [System.IO.FileInfo]$FontFile,

    [Parameter(Mandatory = $false)]
    [InstallTarget]$Target
  )

  If ($null -eq $Target) {
    $Target = [InstallTarget]::User
  }

  Write-Debug "Installing $FontFile for $Target"

  [System.Management.Automation.ActionPreference]$OldErrorActionPreference = $ErrorActionPreference
  $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

  Add-Type -AssemblyName PresentationCore -ErrorAction Stop

  Try {
    # Get target dir and registry path
    [string]$TargetDirectory = Get-FontsDirectory -Target $Target
    [string]$TargetRegistryPath = Get-FontsRegistryPath -Target $Target

    # mkdir -p basically
    New-Item -Path $TargetDirectory -ItemType Directory -ErrorAction Ignore | Out-Null
    New-Item -Path $TargetRegistryPath -ErrorAction Ignore | Out-Null

    # Get font name
    $Font = [Windows.Media.GlyphTypeface]::new($FontFile.FullName)
    [string]$Family = $Font.Win32FamilyNames['en-us']
    [string]$Face = $Font.Win32FaceNames['en-us']

    If ($null -eq $Family) {
      $Family = $Font.Win32FamilyNames.Values.Item(0)
    }

    If ($null -eq $Face) {
      $Face = $Font.Win32FaceNames.Values.Item(0)
    }

    If ("Regular" -eq $Face.Trim()) {
      $Face = ""
    }

    [string]$FontName = ("$family $face").Trim()

    switch ($fontFile.Extension) {
      ".ttf" {$FontName = "$FontName (TrueType)"}
      ".otf" {$FontName = "$FontName (OpenType)"}
      default {"Invalid font extension: $($fontFile.Extension)"}
    }

    Write-Debug "Font name: $FontName"

    [string]$FileHash = (Get-FileHash $FontFile.FullName -Algorithm SHA256).Hash.Substring(0, 6)
    [string]$TargetFileName = "$($FontFile.BaseName)-$FileHash$($FontFile.Extension)"
    Write-Debug "Target file name: $TargetFileName"

    [string]$TargetPath = "$TargetDirectory\$TargetFileName"
    If (!(Test-Path $TargetPath)) {
      Write-Debug "Copying font to: $TargetPath"

      # Copy file
      Copy-Item $FontFile.FullName $TargetPath | Out-Null
    }
    Else {
      Write-Debug "Font file already exists at destination"
    }

    $RegistryValue = Get-ItemPropertyValue -Name $FontName -Path $TargetRegistryPath -ErrorAction SilentlyContinue
    If ($null -eq $RegistryValue) {
      Write-Debug "Creating font configuration in registry"
      New-ItemProperty -Name $FontName -Path $TargetRegistryPath -PropertyType string -Value $TargetPath
    }
    ElseIf ($TargetPath -ne $RegistryValue) {
      Write-Debug "Updating font configuration in registry"
      Set-ItemProperty -Name $FontName -Path $TargetRegistryPath -Value $TargetPath
    }
    Else {
      Write-Debug "Already configured in registry"
    }
  }
  Finally {
    $ErrorActionPreference = $OldErrorActionPreference
  }
}
