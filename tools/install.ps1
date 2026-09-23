param(
    [string[]]$Skill,
    [ValidateSet("claude")]
    [string]$Target = "claude"
)

$ErrorActionPreference = "Stop"

function Write-Step([string]$Message) {
    Write-Host "[AI-SKILLS] $Message"
}

function Get-PropertyValue($Object, [string]$Name) {
    if ($Object.PSObject.Properties.Name -contains $Name) {
        return $Object.$Name
    }
    return $null
}

$RepoRoot = Split-Path -Parent $PSScriptRoot
$ManifestPath = Join-Path $RepoRoot "manifest.json"

if (-not (Test-Path -LiteralPath $ManifestPath -PathType Leaf)) {
    throw "manifest.json was not found: $ManifestPath"
}

$Manifest = Get-Content -LiteralPath $ManifestPath -Raw | ConvertFrom-Json
$AllSkills = @($Manifest.skills)

if ($AllSkills.Count -eq 0) {
    throw "manifest.json does not contain any skills."
}

if ($Skill -and $Skill.Count -gt 0) {
    $SelectedSkills = @()
    foreach ($RequestedName in $Skill) {
        $Matched = @($AllSkills | Where-Object { $_.name -eq $RequestedName })
        if ($Matched.Count -eq 0) {
            throw "Unknown skill: $RequestedName"
        }
        $SelectedSkills += $Matched[0]
    }
} else {
    $SelectedSkills = $AllSkills
}

switch ($Target) {
    "claude" {
        $TargetRoot = Join-Path $HOME ".claude\skills"
    }
    default {
        throw "Unsupported target: $Target"
    }
}

New-Item -ItemType Directory -Force -Path $TargetRoot | Out-Null

foreach ($SkillInfo in $SelectedSkills) {
    $SupportedTargets = @(Get-PropertyValue $SkillInfo "targets")
    if ($SupportedTargets.Count -gt 0 -and -not ($SupportedTargets -contains $Target)) {
        throw "Skill '$($SkillInfo.name)' does not support target '$Target'."
    }

    $SourcePath = Join-Path $RepoRoot $SkillInfo.path
    $SkillFile = Join-Path $SourcePath "SKILL.md"
    if (-not (Test-Path -LiteralPath $SkillFile -PathType Leaf)) {
        throw "Invalid skill '$($SkillInfo.name)': missing SKILL.md at $SkillFile"
    }

    $DestinationPath = Join-Path $TargetRoot $SkillInfo.name
    Write-Step "Installing '$($SkillInfo.name)' to $DestinationPath"

    if (Test-Path -LiteralPath $DestinationPath) {
        Remove-Item -LiteralPath $DestinationPath -Recurse -Force
    }

    Copy-Item -LiteralPath $SourcePath -Destination $DestinationPath -Recurse -Force

    $InstallerRelative = Get-PropertyValue $SkillInfo "installer"
    if (-not [string]::IsNullOrWhiteSpace([string]$InstallerRelative)) {
        $InstallerPath = Join-Path $RepoRoot $InstallerRelative
        if (-not (Test-Path -LiteralPath $InstallerPath -PathType Leaf)) {
            throw "Installer for '$($SkillInfo.name)' was not found: $InstallerPath"
        }

        Write-Step "Installing dependencies for '$($SkillInfo.name)'"
        & $InstallerPath -RepoRoot $RepoRoot -SkillPath $DestinationPath
    }

    Write-Host "[PASS] $($SkillInfo.name)"
}

Write-Host ""
Write-Host "[PASS] Installation completed."
