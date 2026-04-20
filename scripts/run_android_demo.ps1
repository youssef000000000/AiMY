# Runs the app on Android with secrets from config/dart_defines.json (gitignored).
# Setup: copy config\dart_defines.example.json to config\dart_defines.json and fill real values.
# Requires Flutter 3.7+ for --dart-define-from-file.
param(
    [string] $Device = "android",
    [string] $FlutterBat = $env:FLUTTER_BAT
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$DefinesPath = Join-Path $ProjectRoot "config\dart_defines.json"
$ExamplePath = Join-Path $ProjectRoot "config\dart_defines.example.json"

if (-not (Test-Path $DefinesPath)) {
    Write-Host "Missing: $DefinesPath" -ForegroundColor Yellow
    Write-Host "Copy the example and edit (this file is gitignored):" -ForegroundColor Yellow
    Write-Host "  copy `"$ExamplePath`" `"$DefinesPath`"" -ForegroundColor Cyan
    exit 1
}

if (-not $FlutterBat -or -not (Test-Path $FlutterBat)) {
    $FlutterBat = "C:\src\flutter\flutter\bin\flutter.bat"
}
if (-not (Test-Path $FlutterBat)) {
    Write-Host "Set FLUTTER_BAT to your flutter.bat path, or install Flutter at C:\src\flutter\flutter" -ForegroundColor Yellow
    exit 1
}

Set-Location $ProjectRoot
$relativeDefines = "config/dart_defines.json"
Write-Host "Running: flutter run -d $Device --dart-define-from-file=$relativeDefines" -ForegroundColor Gray
& $FlutterBat run -d $Device --dart-define-from-file=$relativeDefines
