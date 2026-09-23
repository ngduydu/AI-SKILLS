param(
    [string]$RepoRoot,
    [string]$SkillPath
)

$ErrorActionPreference = "Stop"

function Write-Step([string]$Message) {
    Write-Host "[meeting-summary] $Message"
}

if ([string]::IsNullOrWhiteSpace($SkillPath)) {
    $SkillPath = Join-Path $HOME ".claude\skills\meeting-summary"
}

$SkillFile = Join-Path $SkillPath "SKILL.md"
if (-not (Test-Path -LiteralPath $SkillFile -PathType Leaf)) {
    throw "Installed skill was not found: $SkillFile"
}

$UvCommand = Get-Command uv -ErrorAction SilentlyContinue
if (-not $UvCommand) {
    throw "uv was not found in PATH. Install uv first, then run tools\install.ps1 again."
}

$UvExe = $UvCommand.Source
if ([string]::IsNullOrWhiteSpace($UvExe)) {
    $UvExe = "uv"
}

$ToolRoot = Join-Path $HOME ".claude\tools\meeting-summary"
$VenvRoot = Join-Path $ToolRoot ".venv"
$PythonExe = Join-Path $VenvRoot "Scripts\python.exe"

Write-Step "Ensuring Python 3.12 is available via uv"
& $UvExe python install 3.12
if ($LASTEXITCODE -ne 0) {
    throw "uv python install 3.12 failed with exit code $LASTEXITCODE."
}

New-Item -ItemType Directory -Force -Path $ToolRoot | Out-Null

if (-not (Test-Path -LiteralPath $PythonExe -PathType Leaf)) {
    Write-Step "Creating isolated Python environment: $VenvRoot"
    & $UvExe venv $VenvRoot --python 3.12
    if ($LASTEXITCODE -ne 0) {
        throw "uv venv failed with exit code $LASTEXITCODE."
    }
}

Write-Step "Installing/updating faster-whisper"
& $UvExe pip install --python $PythonExe --upgrade faster-whisper
if ($LASTEXITCODE -ne 0) {
    throw "Installing faster-whisper failed with exit code $LASTEXITCODE."
}

Write-Step "Verifying faster-whisper import"
& $PythonExe -c "import faster_whisper; print('faster-whisper: OK')"
if ($LASTEXITCODE -ne 0) {
    throw "Unable to import faster_whisper."
}

$TranscribeScript = Join-Path $SkillPath "scripts\transcribe.py"
if (-not (Test-Path -LiteralPath $TranscribeScript -PathType Leaf)) {
    throw "transcribe.py was not found: $TranscribeScript"
}

Write-Step "Verifying transcription script"
& $PythonExe $TranscribeScript --help | Out-Null
if ($LASTEXITCODE -ne 0) {
    throw "transcribe.py validation failed."
}

Write-Host "[PASS] meeting-summary dependencies are ready."
Write-Host "Runtime: $ToolRoot"
