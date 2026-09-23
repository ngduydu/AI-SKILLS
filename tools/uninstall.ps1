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

foreach ($SkillInfo in $SelectedSkills) {
    $DestinationPath = Join-Path $TargetRoot $SkillInfo.name

    $UninstallerRelative = Get-PropertyValue $SkillInfo "uninstaller"
    if (-not [string]::IsNullOrWhiteSpace([string]$UninstallerRelative)) {
        $UninstallerPath = Join-Path $RepoRoot $UninstallerRelative
        if (-not (Test-Path -LiteralPath $UninstallerPath -PathType Leaf)) {
            throw "Uninstaller for '$($SkillInfo.name)' was not found: $UninstallerPath"
        }

        Write-Step "Cleaning dependencies for '$($SkillInfo.name)'"
        & $UninstallerPath -RepoRoot $RepoRoot -SkillPath $DestinationPath
    }

    if (Test-Path -LiteralPath $DestinationPath) {
        Write-Step "Removing '$($SkillInfo.name)' from $DestinationPath"
        Remove-Item -LiteralPath $DestinationPath -Recurse -Force
    } else {
        Write-Step "Skill '$($SkillInfo.name)' is not installed at $DestinationPath"
    }

    Write-Host "[PASS] $($SkillInfo.name)"
}

Write-Host ""
Write-Host "[PASS] Uninstall completed."
