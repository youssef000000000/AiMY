# Validates config/dart_defines.json exists and keys are non-empty (local helper only).
param(
    [string] $Path = (Join-Path (Split-Path -Parent $PSScriptRoot) "config\dart_defines.json")
)

$ErrorActionPreference = "Stop"
if (-not (Test-Path $Path)) {
    Write-Host "Missing: $Path — copy config\dart_defines.example.json" -ForegroundColor Red
    exit 1
}

$raw = Get-Content -Raw -Path $Path
try {
    $j = $raw | ConvertFrom-Json
} catch {
    Write-Host "Invalid JSON: $Path" -ForegroundColor Red
    exit 1
}

$required = @(
    "TWILIO_ACCOUNT_SID", "TWILIO_API_KEY_SID", "TWILIO_API_KEY_SECRET", "TWILIO_TWIML_APP_SID",
    "FIREBASE_API_KEY", "FIREBASE_PROJECT_ID", "FIREBASE_MESSAGING_SENDER_ID", "FIREBASE_ANDROID_APP_ID"
)

$bad = @()
foreach ($k in $required) {
    $v = $j.$k
    if ([string]::IsNullOrWhiteSpace($v)) { $bad += "$k is empty" }
}

if ($bad.Count -gt 0) {
    Write-Host "Issues:" -ForegroundColor Yellow
    $bad | ForEach-Object { Write-Host " - $_" }
    exit 1
}

Write-Host "dart_defines.json: required keys present (still verify real Twilio/Firebase values in Console)." -ForegroundColor Green
exit 0
