[string] $ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

& "$ScriptDir\link-external.ps1"
#& "$ScriptDir\install-fonts.ps1"
