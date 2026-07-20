# paper_sjkim 저장소를 원격과 동기화한다 (pull -> commit -> push).
# 사용법: 이 폴더에서 PowerShell로 실행 -> .\scripts\sync.ps1

$ErrorActionPreference = "Stop"
Set-Location (Split-Path -Parent $PSScriptRoot)

Write-Host "== git pull =="
git pull --rebase

$status = git status --porcelain
if ($status) {
    Write-Host "== changes detected, committing =="
    git add -A
    $msg = "sync: $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
    git commit -m $msg
} else {
    Write-Host "== no local changes =="
}

Write-Host "== git push =="
git push

Write-Host "== done =="
