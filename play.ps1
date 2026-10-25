# NAILONG PROTOCOL launcher.
# PowerShell is used instead of cmd.exe because Smart App Control on this
# machine blocks .cmd files launched from Explorer (Code Integrity event 3033).
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$url = "http://127.0.0.1:8000"

function Test-NailongHealth {
    try {
        $response = Invoke-WebRequest -Uri "$url/api/health" -UseBasicParsing -TimeoutSec 2
        return ($response.StatusCode -eq 200)
    } catch {
        return $false
    }
}

if (Test-NailongHealth) {
    Start-Process $url
    exit 0
}

$candidates = @()
if ($env:NAILONG_PYTHON) { $candidates += $env:NAILONG_PYTHON }
$candidates += (Join-Path $root ".venv\Scripts\python.exe")
$candidates += (Join-Path $env:USERPROFILE ".dsh\dsh-runtimes\dsh-primary-runtime\dependencies\python\python.exe")
$command = Get-Command python -ErrorAction SilentlyContinue
if ($command) { $candidates += $command.Source }

$python = $candidates | Where-Object { $_ -and (Test-Path $_) } | Select-Object -First 1
if (-not $python) {
    Write-Host "No Python found. Run start.cmd from a terminal or install the dependencies first."
    exit 1
}

Start-Process -FilePath $python -ArgumentList @("scripts\launch.py") -WorkingDirectory $root -WindowStyle Minimized
