$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $root

Write-Host ""
Write-Host "  NAILONG PROTOCOL / 奶龙协议：早八植物园" -ForegroundColor Yellow
Write-Host "  ------------------------------------------------" -ForegroundColor DarkGray

# Prefer an explicit interpreter, then the local venv, then anything that can
# import the backend stack. This keeps the demo reproducible on this machine
# without hard-coding a single Python install in the README instructions.
$candidates = New-Object System.Collections.Generic.List[string]
if ($env:NAILONG_PYTHON) { $candidates.Add($env:NAILONG_PYTHON) }
$candidates.Add((Join-Path $root ".venv\Scripts\python.exe"))
$candidates.Add((Join-Path $env:USERPROFILE ".dsh\dsh-runtimes\dsh-primary-runtime\dependencies\python\python.exe"))
$cmd = Get-Command python -ErrorAction SilentlyContinue
if ($cmd) { $candidates.Add($cmd.Source) }
$candidates.Add((Join-Path $env:LOCALAPPDATA "Python\pythoncore-3.12-64\python.exe"))

$python = $null
foreach ($candidate in $candidates) {
    if (-not $candidate) { continue }
    if (-not (Test-Path $candidate)) { continue }
    try {
        & $candidate -c "import fastapi, uvicorn, ultralytics, httpx" *> $null
        if ($LASTEXITCODE -eq 0) { $python = $candidate; break }
    } catch { }
}

if (-not $python) {
    Write-Host "  没有找到装好依赖的 Python。" -ForegroundColor Red
    Write-Host "  先执行：" -ForegroundColor DarkGray
    Write-Host "    python -m pip install -r requirements.txt" -ForegroundColor DarkGray
    Write-Host "    python -m pip install torch==2.11.0 torchvision==0.26.0 --index-url https://download.pytorch.org/whl/cu128" -ForegroundColor DarkGray
    Write-Host "  或设置 NAILONG_PYTHON 指向你的解释器。" -ForegroundColor DarkGray
    exit 1
}

if (-not (Test-Path (Join-Path $root "dist\index.html"))) {
    Write-Host "  dist 还不存在，尝试构建前端……" -ForegroundColor Yellow
    $nodeDir = Join-Path $env:USERPROFILE ".dsh\dsh-runtimes\dsh-primary-runtime\dependencies\node\bin"
    $node = Join-Path $nodeDir "node.exe"
    $pnpm = Join-Path $env:USERPROFILE ".dsh\dsh-runtimes\dsh-primary-runtime\dependencies\pnpm\bin\pnpm.cjs"
    if ((Test-Path $node) -and (Test-Path $pnpm)) {
        $env:PATH = "$nodeDir;$env:PATH"
        & $node $pnpm install --reporter=append-only
        & $node $pnpm build
    } else {
        Write-Host "  请先运行：pnpm install && pnpm build" -ForegroundColor DarkGray
        exit 1
    }
}

Write-Host "  Python : $python" -ForegroundColor DarkGray
Write-Host "  URL    : http://127.0.0.1:8000" -ForegroundColor Green
Write-Host "  本地大脑: http://127.0.0.1:1234/v1 (LM Studio)" -ForegroundColor DarkGray
Write-Host "  没有开启 LM Studio 也能玩，AI 会切到离线人格。" -ForegroundColor DarkGray
Write-Host ""

$env:PYTHONIOENCODING = "utf-8"
$env:PYTHONUTF8 = "1"
& $python scripts\launch.py @args
