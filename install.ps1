# Install the ui-ux-sketchbook skill for one or more coding agents (Windows PowerShell 5.1+ / PowerShell 7).
#
#   irm https://raw.githubusercontent.com/TssHack/ui-ux-sketchbook/main/install.ps1 | iex
#   & ([scriptblock]::Create((irm https://raw.githubusercontent.com/TssHack/ui-ux-sketchbook/main/install.ps1))) -Agent hermes
#
# -Agent    claude | codex | cursor | hermes | all   (default: every agent found on this machine, else claude)
# -Project  install into the current project instead of your home folder
# -Dir      install into <Dir>\ui-ux-sketchbook (any other agent)
# -Version  a release tag such as v1.0.0 (default: latest release)
param(
  [string[]]$Agent = @(),
  [switch]$Project,
  [string]$Dir = "",
  [string]$Version = "latest"
)
$ErrorActionPreference = "Stop"
$Repo = "TssHack/ui-ux-sketchbook"
$Name = "ui-ux-sketchbook"

function Get-Target([string]$a) {
  $base = if ($Project) { (Get-Location).Path } else { $HOME }
  switch ($a) {
    "claude" { return Join-Path $base ".claude\skills" }
    "codex"  { if ($Project) { return Join-Path $base ".agents\skills" } else { return Join-Path $base ".codex\skills" } }
    "cursor" { return Join-Path $base ".cursor\skills" }
    "hermes" { return Join-Path $base ".hermes\skills" }
    default  { throw "Unknown agent: $a (use claude, codex, cursor, hermes or -Dir)" }
  }
}

if ($Agent.Count -eq 0 -and -not $Dir) {
  $Agent = @("claude", "codex", "cursor", "hermes") | Where-Object { Test-Path (Join-Path $HOME ".$_") }
  if (-not $Agent) { $Agent = @("claude") }
}
if ($Agent -contains "all") { $Agent = @("claude", "codex", "cursor", "hermes") }

# Use a local checkout when the script runs from one, otherwise download the release.
$local = if ($PSScriptRoot) { Join-Path $PSScriptRoot "skills\$Name" } else { "" }
$tmp = $null
if ($local -and (Test-Path (Join-Path $local "SKILL.md"))) {
  $src = $local
} else {
  $tmp = Join-Path ([IO.Path]::GetTempPath()) ("sketchbook-" + [guid]::NewGuid())
  New-Item -ItemType Directory -Path $tmp | Out-Null
  $url = if ($Version -eq "latest") { "https://github.com/$Repo/releases/latest/download/$Name.zip" } else { "https://github.com/$Repo/releases/download/$Version/$Name.zip" }
  Write-Host "Downloading $url"
  Invoke-WebRequest -Uri $url -OutFile (Join-Path $tmp "skill.zip") -UseBasicParsing
  Expand-Archive -Path (Join-Path $tmp "skill.zip") -DestinationPath $tmp -Force
  $src = Join-Path $tmp $Name
}
if (-not (Test-Path (Join-Path $src "SKILL.md"))) { throw "SKILL.md not found in $src" }

function Install-To([string]$parent) {
  $dest = Join-Path $parent $Name
  New-Item -ItemType Directory -Path $parent -Force | Out-Null
  if (Test-Path $dest) { Remove-Item -Recurse -Force $dest }
  Copy-Item -Recurse $src $dest
  Write-Host "  installed -> $dest"
}

Write-Host "Installing $Name"
if ($Dir) { Install-To $Dir }
foreach ($a in $Agent) { Write-Host "${a}:"; Install-To (Get-Target $a) }
if ($tmp) { Remove-Item -Recurse -Force $tmp }
Write-Host "Done. Restart your agent so it picks up the new skill."
