# 離心機配平 Flutter App

網頁 demo（`../index.html`）的手機版，規則、關卡、提示與動畫一比一移植。

## 結構

- `lib/logic/balance.dart` 純數學：質因數、配平定理、向量和
- `lib/data/levels.dart` 十個關卡
- `lib/state/game_state.dart` 遊戲狀態（ChangeNotifier），過關紀錄存 shared_preferences
- `lib/widgets/rotor.dart` CustomPainter 轉盤：點擊孔位、加速動畫、震動、偏重箭頭、虛線擺法
- `lib/screens/game_screen.dart` 主畫面
- `lib/theme/palette.dart` 淺色／深色配色

## 開發

```sh
flutter pub get
flutter test
flutter run            # 接手機或模擬器
flutter build apk      # Android
flutter build web      # 網頁版
```
