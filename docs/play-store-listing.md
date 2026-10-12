# Google Play 商店資訊

上架帳號：大安聯合醫事檢驗所（Google Play 組織帳號）
套件名稱：`tw.com.ucl.centrifuge_balance`
定稿：2026-10-12（v1.1.0；v1.0.0 版本見 git 歷史）

## 應用程式名稱（30 字內）

```
離心機配平 — 試管平衡解謎
```

## 簡短說明（80 字內）

```
把試管擺進離心機，重量平衡了才能啟動。關卡、實務兩套謎題，破關領醫檢師執照。
```

## 完整說明（4000 字內）

```
把試管擺進離心機，重量平衡了才能啟動。

在檢驗室裡，離心機一定要配平：試管放得不對稱，一轉起來就會劇烈震動。這款解謎遊戲把這件每天都在做的小事，變成一道道題目。規則只有一句話，答案卻常常出乎意料。

【玩法】
・點孔位放入或取出試管，放滿指定支數後按「啟動」
・平衡：轉盤一路加速到 4,000 rpm
・不平衡：震動停機，紅色箭頭指出偏重的方向
・卡關時按「提示」，再按一次會畫出其中一種擺法
・實務模式：檢體管不能動，只能用有限的備用管配平，跟檢驗室裡的做法一樣

【內容】
・「關卡」10 關，從 6 孔到 30 孔，包含不能拿走的固定試管與不能使用的故障孔
・「實務」10 關，備用管支數就是題目，少一支就配不平
・自由模式：2 到 30 孔任選，自己出題
・10 關全過頒發「醫檢師執照」，可寫上暱稱、分享成圖片；實務全過加蓋「實務合格」章
・記錄每一關的最佳成績，下次打開接著玩
・繁體中文與英文介面，跟著系統語言
・震動回饋與過關動畫

【背後的數學】
把每支試管看成從圓心指向孔位的向量，配平就是所有向量相加為零。n 孔的離心機能配平 k 支試管，條件是 k 與 n−k 都能寫成 n 的質因數之和。例如 12 孔可以配平 5 支（5 = 2 + 3），卻配不平 1 支或 11 支。

【安心遊玩】
・免費，沒有廣告
・不需要帳號，不連網，不蒐集任何個人資料

由大安聯合醫事檢驗所製作。
```

## 其他欄位

| 欄位 | 內容 |
|---|---|
| 應用程式類別 | 遊戲 → 益智 |
| 聯絡 Email | SUPPORT@ucl.com.tw |
| 隱私權政策網址 | https://joechiboo.github.io/centrifuge-balance/privacy.html |

## 圖片素材（`docs/store/`）

| 檔案 | 用途 | 規格 |
|---|---|---|
| `icon-512.png` | 高解析圖示 | 512×512 PNG，從 `assets/icon/icon.png` 縮小 |
| `feature-graphic-1024x500.png` | 主要圖片 | 1024×500 PNG |
| `screenshots/01-hint.png` ～ `06-math.png` | 手機螢幕截圖，依序上傳 | 1226×2180（9:16） |

截圖是 2026-10-03 在 SM-S9110 上用 adb 拍的。原圖 1080×2340 超過 2:1，Play 不收，所以裁掉狀態列與手勢列後左右補背景色成 9:16。

### en-US（`docs/store/en-US/`，2026-10-12，v1.1.0）

| 檔案 | 用途 | 規格 |
|---|---|---|
| `feature-graphic-1024x500.png` | en-US 主要圖片：轉盤沿用中文版，左半邊改英文標題與標語 | 1024×500 PNG |
| `screenshots/01-hint.png` ～ `06-free-30-holes.png` | 提示、不平衡、旋轉中、配平成功、實務模式、自由 30 孔 | 1226×2180（9:16） |

圖示沿用 `icon-512.png`。拍法：不改手機系統語言，用 Android 13+ 的單一 App 語言
`adb shell cmd locale set-app-locales <套件> --user 0 --locales en-US`（拍完用 `--locales ''` 還原）；
三星的遊戲加速器浮動鈕會被截進去，拍前 `pm disable-user --user 0 com.samsung.android.game.gametools`、拍完 `pm enable`。
原圖用 `adb exec-out screencap -p > raw.png` 抓，再用 `tool/storeshot.py raw.png out.png` 裁成上面的規格
（App 是全螢幕繪製，狀態列 100 px、手勢列 60 px 用固定高度切）。

功能有增減時，記得一起更新這份說明，再同步到 Play Console。


## en-US 商店資訊

### App name（30 字內）

```
Centrifuge Balance Puzzle
```

### Short description（80 字內）

```
Balance the centrifuge before you start it. 20 levels, a lab mode, maths inside.
```

### Full description（4000 字內）

```
Load the tubes so the rotor balances. Only then will it start.

In a clinical lab the centrifuge must be balanced: load it unevenly and it shakes itself to a stop. This puzzle game turns that everyday chore into a set of levels. The rule fits in one sentence; the answers keep surprising you.

HOW TO PLAY
• Tap a hole to place or remove a tube, then press Start
• Balanced: the rotor spins up to 4,000 rpm
• Unbalanced: it shakes, stops, and a red arrow points at the heavy side
• Stuck? Tap Hint for a clue, and again to see one layout drawn on the rotor
• Lab mode: specimen tubes stay where they are; balance the rotor with a limited number of spare tubes, the way technologists do

WHAT'S INSIDE
• Levels: 10 puzzles from 6 to 30 holes, with fixed tubes you cannot move and broken holes you cannot use
• Lab: 10 puzzles where the spare-tube budget is the puzzle; one tube fewer and it will not balance
• Free mode: pick any rotor from 2 to 30 holes and set your own problems
• Clear all 10 levels to earn the Medical Technologist Licence; add your name and share it as an image. Clear the lab levels for the Lab endorsement
• Best score per level, and the game reopens exactly where you left it
• Traditional Chinese and English, following your system language
• Haptic feedback and a proper spin-up animation

THE MATHS
Think of each tube as a vector from the centre to its hole. Balanced means the vectors sum to zero. An n-hole rotor can balance k tubes exactly when both k and n−k can be written as sums of n's prime factors. A 12-hole rotor balances 5 tubes (5 = 2 + 3) but never 1 or 11.

No account, no internet, no ads, no tracking. Progress is stored only on your device.
```

## 1.1.0 更新說明（500 字內）

zh-TW：

```
・新增「實務」模式 10 關：檢體管不能動，只能用有限的備用管配平，跟檢驗室裡的做法一樣
・10 關全過頒發「醫檢師執照」，可寫上暱稱、分享成圖片；實務 10 關全過加蓋「實務合格」章
・支援英文介面，跟著系統語言切換
・畫面文字精簡，提示更短
・修正 Android 震動回饋太弱的問題
```

en-US:

```
• New Lab mode, 10 levels: specimen tubes stay put; balance the rotor with a limited number of spare tubes, the way it is done in a real lab
• Clear all 10 levels to earn the Medical Technologist Licence; add your name and share it as an image. Clear the 10 lab levels for the Lab endorsement
• English interface, following the system language
• Shorter on-screen text and hints
• Stronger haptic feedback on Android
```
