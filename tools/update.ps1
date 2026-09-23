param(
    [string[]]$Skill,
    [ValidateSet("claude")]
    [string]$Target = "claude"
)

$ErrorActionPreference = "Stop"

$InstallScript = Join-Path $PSScriptRoot "install.ps1"
if (-not (Test-Path -LiteralPath $InstallScript -PathType Leaf)) {
    throw "install.ps1 was not found: $InstallScript"
}

$Arguments = @{
    Target = $Target
}

if ($Skill -and $Skill.Count -gt 0) {
    $Arguments.Skill = $Skill
}

& $InstallScript @Arguments
