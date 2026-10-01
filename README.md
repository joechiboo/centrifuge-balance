# 離心機配平 Centrifuge Balance

把試管擺進離心機，重量平衡了才能啟動。規則一句話，答案常常出乎意料。

## 玩法

- 點孔位放入或取出試管，放滿指定支數後按啟動
- 平衡：轉盤加速到 4,000 rpm；不平衡：震動停機，紅色箭頭指出偏重方向
- 十個關卡（含固定試管、故障孔），以及 2–30 孔的自由模式
- 卡關時按提示，再按一次會畫出其中一種擺法

## 背後的數學

把每支試管看成從圓心指向孔位的向量，配平就是所有向量相加為零。

定理：n 孔的離心機能配平 k 支試管，若且唯若 k 與 n−k 都能寫成 n 的質因數之和。
例如 12 孔（質因數 2、3）：5 = 2 + 3 可以配平，1 與 11 不行。

## 專案結構

- `index.html`：網頁版 demo，單一檔案，直接開啟即可玩，可用 GitHub Pages 發佈
- `lib/`：Flutter App（Android / iOS / web）
  - `logic/balance.dart`：配平判定與質因數定理，純 Dart，有單元測試
  - `data/levels.dart`：關卡資料
  - `state/game_state.dart`：遊戲狀態，過關紀錄存在裝置上
  - `widgets/rotor.dart`：轉盤繪製、旋轉、震動、偏重箭頭、虛線擺法
  - `screens/`：主畫面與說明頁
- `test/`：邏輯與畫面測試

## 執行 Flutter App

```sh
flutter pub get
flutter test
flutter run            # 接手機或模擬器
flutter build apk      # Android
flutter build web      # 網頁版
```

每次 push，GitHub Actions 會分析、測試並打包 release APK，
可在該次執行的 Artifacts 下載 `centrifuge-balance-apk` 安裝到手機試玩。
CI 的 APK 是 debug 簽章，只能試玩；正式版請從 GitHub Releases 下載。

### 正式簽章

release build 會讀 `android/key.properties`（已 gitignore，只放在發版的電腦上）：

```properties
storePassword=...
keyPassword=...
keyAlias=release
storeFile=C:/path/to/release.jks
```

沒有這個檔案時自動退回 debug 簽章，所以 CI 與新 clone 照樣能 build。

## 狀態

網頁版 demo 完成；Flutter 版已移植全部關卡、自由模式、提示與動畫，並加上進度條、震動回饋與過關動畫。App icon 與正式簽章已完成，APK 發布在 GitHub Releases；下一步是上架 Google Play。
