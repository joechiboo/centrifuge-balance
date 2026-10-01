# 離心機配平 Centrifuge Balance

把試管擺進離心機，重量平衡了才能啟動。規則一句話，答案常常出乎意料。

## 玩法

- 點孔位放入或取出試管，放滿指定支數後按「啟動」
- 平衡：轉盤加速到 4,000 rpm；不平衡：震動停機，紅色箭頭指出偏重方向
- 十個關卡（含固定試管、故障孔），以及 2–30 孔的自由模式
- 卡關時按「提示」，再按一次會畫出其中一種擺法

## 背後的數學

把每支試管看成從圓心指向孔位的向量，配平就是所有向量相加為零。

定理：n 孔的離心機能配平 k 支試管，若且唯若 k 與 n−k 都能寫成 n 的質因數之和。
例如 12 孔（質因數 2、3）：5 = 2 + 3 可以配平，1 與 11 不行。

## 專案結構

- `index.html`：網頁版 demo，單一檔案，直接開啟即可玩
- `lib/`：Flutter App
  - `game/balance.dart`：配平判定與質因數定理（純 Dart，有單元測試）
  - `game/levels.dart`：關卡資料
  - `rotor.dart`：轉盤繪製與旋轉動畫
  - `game_page.dart`：遊戲畫面與流程
- `test/`：邏輯與畫面測試

## 執行 Flutter App

平台資料夾（`android/` 等）尚未提交，第一次請先產生：

```sh
flutter create --platforms=android,web --org com.joechiboo --project-name centrifuge_balance .
flutter pub get
flutter run
```

每次 push 到 `main`，GitHub Actions 會執行分析、測試並打包 debug APK，
可在該次執行的 Artifacts 下載 `centrifuge-balance-debug-apk` 安裝到手機試玩。

## 狀態

網頁版 demo 已完成；Flutter 版功能與 demo 對齊，下一步是提交 `android/`、設定簽章並上架 Google Play。
