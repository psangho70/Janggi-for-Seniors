#
# sync_web_assets.ps1
# 청춘 장기 (Janggi for Seniors) - 최신 웹 코어 자원을 iOS 번들(www/)로 동기화
#

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$projectRoot = Split-Path -Parent $scriptDir
$targetDir = Join-Path $scriptDir "JanggiForSeniors\Resources\www"

if (-not (Test-Path $targetDir)) {
    New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
}

$filesToCopy = @(
    "index.html",
    "icon.svg",
    "icon_512.png",
    "manifest.json",
    "sw.js"
)

Write-Host "=========================================="
Write-Host " 청춘 장기 iOS 웹 자원 동기화 (sync_web_assets)"
Write-Host "=========================================="
Write-Host "소스 경로: $projectRoot"
Write-Host "대상 경로: $targetDir"
Write-Host "------------------------------------------"

foreach ($file in $filesToCopy) {
    $src = Join-Path $projectRoot $file
    $dst = Join-Path $targetDir $file
    if (Test-Path $src) {
        Copy-Item -Path $src -Destination $dst -Force
        Write-Host " [OK] $file 동기화 완료" -ForegroundColor Green
    } else {
        Write-Host " [SKIP] $file 파일을 찾을 수 없습니다." -ForegroundColor Yellow
    }
}

Write-Host "------------------------------------------"
Write-Host " 동기화 작업이 성공적으로 완료되었습니다!" -ForegroundColor Cyan
Write-Host "=========================================="

