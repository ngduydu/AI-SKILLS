param(
    [string]$RepoRoot,
    [string]$SkillPath
)

$ErrorActionPreference = "Stop"

$ToolRoot = Join-Path $HOME ".claude\tools\meeting-summary"

if (Test-Path -LiteralPath $ToolRoot) {
    Remove-Item -LiteralPath $ToolRoot -Recurse -Force
    Write-Host "Removed runtime: $ToolRoot"
} else {
    Write-Host "Runtime is not installed: $ToolRoot"
}
