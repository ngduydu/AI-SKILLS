param(
    [Parameter(Mandatory = $true)]
    [string]$InputPath,

    [Parameter(Mandatory = $true)]
    [string]$OutputRoot,

    [switch]$ForceTranscribe
)

$ErrorActionPreference = "Stop"

function Fail([string]$Message) {
    Write-Error $Message
    exit 1
}

$PythonScript = Join-Path $PSScriptRoot "transcribe.py"
$ToolRoot = Join-Path $HOME ".claude\tools\meeting-summary"
$VenvRoot = Join-Path $ToolRoot ".venv"
$PythonExe = Join-Path $VenvRoot "Scripts\python.exe"

if (-not (Test-Path -LiteralPath $PythonScript -PathType Leaf)) {
    Fail "transcribe.py was not found: $PythonScript"
}

if (-not (Test-Path -LiteralPath $InputPath -PathType Leaf)) {
    Fail "Input file was not found: $InputPath"
}

if (-not (Test-Path -LiteralPath $PythonExe -PathType Leaf)) {
    Fail "meeting-summary runtime is missing: $VenvRoot. Reinstall the skill from the AI-SKILLS repository."
}

$Arguments = @(
    $PythonScript,
    "--input", $InputPath,
    "--output-root", $OutputRoot,
    "--model", "large-v3"
)

if ($ForceTranscribe) {
    $Arguments += "--force-transcribe"
}

& $PythonExe @Arguments
$ExitCode = $LASTEXITCODE

if ($ExitCode -ne 0) {
    exit $ExitCode
}
