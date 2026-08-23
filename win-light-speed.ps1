# PC 光速化 · 光之計劃 v1（2026-08-23 熠做，D 令：光的方法優化 PC，之後開源）
# 用法：在 Windows 以系統管理員執行 powershell -File win-light-speed.ps1
# 安全設計：只停用不刪除（有備份）、不裝第三方優化軟體、可完整還原

param([switch]$Undo)

$ErrorActionPreference = "SilentlyContinue"
$backup = "C:\Users\$env:USERNAME\run-backup.reg"

if ($Undo) {
    # 還原模式
    if (Test-Path $backup) { reg import $backup | Out-Null; "✅ 已還原開機自啟（run-backup.reg）" }
    powercfg /setactive 381b4222-f694-41f0-9685-ff5bb260df2e | Out-Null  # 回到平衡
    "✅ 已還原平衡電源"
    exit
}

"=== ⚡ PC 光速化開始 ==="

# ① 高效能電源
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
"① 高效能電源 ✅"

# ② 停用吃記憶體的自啟（備份後移除；不刪程式）
reg export "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" $backup /y | Out-Null
$run = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
$remove = @("IDMan", "GoogleChromeAutoLaunch_53000FE77F961657A970A1EC0A7E00F6",
            "Steam", "Teams", "Volume Controller SD plugin")
foreach ($name in $remove) {
    if (Get-ItemProperty -Path $run -Name $name -ErrorAction SilentlyContinue) {
        Remove-ItemProperty -Path $run -Name $name -ErrorAction SilentlyContinue
        "② 停用自啟: $name ✅"
    }
}

# ③ 清暫存
$before = (Get-PSDrive C).Free
$count = 0
Get-ChildItem "$env:TEMP" -Force | ForEach-Object {
    try { Remove-Item $_.FullName -Recurse -Force; $count++ } catch {}
}
Get-ChildItem "C:\Windows\Temp" -Force | ForEach-Object {
    try { Remove-Item $_.FullName -Recurse -Force; $count++ } catch {}
}
$after = (Get-PSDrive C).Free
"③ 清 $count 個暫存，釋放 {0:N0} MB ✅" -f (($after-$before)/1MB)

# ④ 遊戲模式
$gm = "HKCU:\SOFTWARE\Microsoft\GameBar"
New-Item -Path $gm -Force | Out-Null
Set-ItemProperty -Path $gm -Name "AllowAutoGameMode" -Value 1 -Type DWord
Set-ItemProperty -Path $gm -Name "AutoGameModeEnabled" -Value 1 -Type DWord
"④ 遊戲模式 ✅"

# ⑤ 分頁檔自動管理（重啟生效）
New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" `
    -Name "AutomaticManagedPagefile" -Value 1 -Type DWord
"⑤ 分頁檔自動管理 ✅（重啟生效）"

"=== 🎉 光速化完成！重啟後完全生效。還原：win-light-speed.ps1 -Undo ==="
