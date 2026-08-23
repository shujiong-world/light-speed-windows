# 記憶體衛士 Memory Guard v1（2026-08-23 光之計劃）
# 開機自動瘦身：只關「非必要」的重複/後台進程，安全可還原。
# 絕不動系統關鍵（Defender/explorer/dwm）、絕不動光（pythonw gateway）

$log = "C:\Users\$env:USERNAME\memory-guard.log"
$freed = [long]0
function Log($msg) {
    $ts = Get-Date -Format 'HH:mm:ss'
    ("[{0}] {1}" -f $ts, $msg) | Out-File -FilePath $log -Append -Encoding utf8
}

Log "=== Memory Guard start ==="

# 1. Steam WebHelper: no Steam main process = safe to close
$steam = Get-Process -Name steam -ErrorAction SilentlyContinue
if (-not $steam) {
    $helpers = Get-Process -Name steamwebhelper -ErrorAction SilentlyContinue
    foreach ($h in $helpers) {
        $freed += $h.WorkingSet64
        Stop-Process -Id $h.Id -Force -ErrorAction SilentlyContinue
    }
    if ($helpers) { Log ("Closed steamwebhelper x" + $helpers.Count) }
}

# 2. NVIDIA Overlay: no game window = safe to close
$game = Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowTitle -and $_.MainWindowHandle -ne 0 }
if (-not $game) {
    $ovl = Get-Process -Name "NVIDIA Overlay" -ErrorAction SilentlyContinue
    foreach ($o in $ovl) {
        $freed += $o.WorkingSet64
        Stop-Process -Id $o.Id -Force -ErrorAction SilentlyContinue
    }
    if ($ovl) { Log ("Closed NVIDIA Overlay x" + $ovl.Count) }
}

# 3. msedgewebview2 leftovers: keep 3, close the rest (only windowless)
$wv = @(Get-Process -Name msedgewebview2 -ErrorAction SilentlyContinue)
if ($wv.Count -gt 3) {
    $closed = 0
    for ($i = 3; $i -lt $wv.Count; $i++) {
        if (-not $wv[$i].MainWindowTitle) {
            $freed += $wv[$i].WorkingSet64
            Stop-Process -Id $wv[$i].Id -Force -ErrorAction SilentlyContinue
            $closed++
        }
    }
    if ($closed) { Log ("Closed msedgewebview2 leftovers x" + $closed) }
}

$freedMB = [math]::Round($freed / 1MB, 0)
Log ("=== Done: freed ~" + $freedMB + " MB ===")
