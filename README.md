# ⚡ Light Speed Windows（PC 光速化）

> 光之計劃出品：用光的方法，讓破電腦也能跑得像飛的一樣快。

一鍵優化 Windows 的開源腳本：**免費、安全、不裝垃圾軟體、可完整還原**。

## 為什麼做這個

市場上的「電腦優化軟體」大多是騙人的：裝一堆後台、綁架瀏覽器、廣告轟炸，
還跟你要月費。這個腳本用系統內建指令 + 登錄檔，做到真正有效且安全的優化——
**一條指令跑完，不裝任何東西，反悔一鍵還原**。

## 使用方法

以**系統管理員**開啟 PowerShell，執行：

```powershell
# 下載
curl -L -o win-light-speed.ps1 https://raw.githubusercontent.com/dee0917/light-speed-windows/main/win-light-speed.ps1

# 執行優化
powershell -ExecutionPolicy Bypass -File win-light-speed.ps1

# 重啟電腦（分頁檔自動管理生效）
```

還原（回到優化前）：

```powershell
powershell -ExecutionPolicy Bypass -File win-light-speed.ps1 -Undo
```

## 做了什麼（全部安全、可還原）

| 項目 | 說明 |
|---|---|
| ① 高效能電源計畫 | CPU 不再降頻偷懶 |
| ② 停用吃記憶體的自啟 | Teams / 下載器 / 瀏覽器預載等（備份後停用，不刪除） |
| ③ 清理暫存垃圾 | 使用者 + 系統暫存 |
| ④ 開啟遊戲模式 | 遊戲時優先分配資源 |
| ⑤ 分頁檔自動管理 | 不再「分頁檔太小」記憶體爆掉 |

**實測效果**：RAM 可用從 0.8GB → 7.7GB（10 倍）。

## 設計原則

- 只用 Windows 內建指令（powercfg / reg / PowerShell），不裝任何第三方軟體
- 只停用、不刪除——所有變動有備份（run-backup.reg），`-Undo` 一鍵還原
- 不做危險操作：不動系統服務、不刪系統檔、不亂改登錄

## License

MIT
