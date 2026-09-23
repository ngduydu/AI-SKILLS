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

if (-not (Test-Path -LiteralPath $InputPath -PathType Leaf)) {
    Fail "Input file was not found: $InputPath"
}

$ResolvedInput = (Resolve-Path -LiteralPath $InputPath).Path
$Stem = [System.IO.Path]::GetFileNameWithoutExtension($ResolvedInput)

# Reuse the newest transcript for this meeting when available.
# This avoids running Whisper again when only summary formatting changes.
if (-not $ForceTranscribe -and (Test-Path -LiteralPath $OutputRoot -PathType Container)) {
    $TranscriptCandidates = @()

    Get-ChildItem -LiteralPath $OutputRoot -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        $IsMatchingFolder = ($_.Name -eq $Stem) -or $_.Name.StartsWith(
            "$Stem - ",
            [System.StringComparison]::OrdinalIgnoreCase
        )

        if ($IsMatchingFolder) {
            $Candidate = Join-Path $_.FullName "transcript.txt"
            if (Test-Path -LiteralPath $Candidate -PathType Leaf) {
                $TranscriptCandidates += Get-Item -LiteralPath $Candidate
            }
        }
    }

    $ExistingTranscript = $TranscriptCandidates |
        Sort-Object LastWriteTimeUtc -Descending |
        Select-Object -First 1

    if ($null -ne $ExistingTranscript) {
        Write-Output "INFO=Reusing existing transcript; Whisper will not run."
        Write-Output "REUSED_TRANSCRIPT=1"
        Write-Output "OUTPUT_DIR=$($ExistingTranscript.Directory.FullName)"
        Write-Output "TRANSCRIPT_PATH=$($ExistingTranscript.FullName)"
        exit 0
    }
}

if (-not (Test-Path -LiteralPath $PythonScript -PathType Leaf)) {
    Fail "transcribe.py was not found: $PythonScript"
}

if (-not (Test-Path -LiteralPath $PythonExe -PathType Leaf)) {
    Fail "meeting-summary runtime is missing: $VenvRoot. Reinstall the skill from the AI-SKILLS repository."
}

& $PythonExe $PythonScript --input $ResolvedInput --output-root $OutputRoot --model "large-v3"
$ExitCode = $LASTEXITCODE

if ($ExitCode -ne 0) {
    exit $ExitCode
}
