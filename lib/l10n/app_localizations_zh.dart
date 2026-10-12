// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '離心機配平';

  @override
  String get modeLevels => '關卡';

  @override
  String get modeLab => '實務';

  @override
  String get modeFree => '自由';

  @override
  String get infoTooltip => '說明';

  @override
  String get licenseTooltip => '執照';

  @override
  String levelTitle(int n) {
    return '第 $n 關';
  }

  @override
  String labTitle(int n) {
    return '實務 $n';
  }

  @override
  String freeTitle(int n) {
    return '自由 · $n 孔';
  }

  @override
  String sparesChip(int n) {
    return '備用管 ×$n';
  }

  @override
  String holes(int n) {
    return '$n 孔';
  }

  @override
  String get fewerHoles => '減少孔數';

  @override
  String get moreHoles => '增加孔數';

  @override
  String progress(int done, int total) {
    return '$done / $total';
  }

  @override
  String segmentLabel(String title, String status) {
    return '$title$status';
  }

  @override
  String get statusCleared => '，已過關';

  @override
  String get statusCurrent => '，目前';

  @override
  String get hintBtn => '提示';

  @override
  String get hintBtnShow => '看擺法';

  @override
  String get clearBtn => '清空';

  @override
  String get startBtn => '啟動';

  @override
  String get spinning => '運轉中';

  @override
  String missing(int n) {
    return '還差 $n 支';
  }

  @override
  String msgTooMany(int k) {
    return '只有 $k 支試管，先拿走一支。';
  }

  @override
  String get msgNoSpares => '備用管用完了。';

  @override
  String get msgGuide => '虛線是其中一種擺法。';

  @override
  String get celebrate => '配平成功';

  @override
  String get celebrateAll => '全部過關！';

  @override
  String get firstTry => '一次就過';

  @override
  String attempts(int n) {
    return '第 $n 次成功';
  }

  @override
  String best(int n) {
    return '最佳 $n 次';
  }

  @override
  String freeResult(int n, int t) {
    return '$n 孔放 $t 支';
  }

  @override
  String get rulesHeading => '玩法';

  @override
  String get rule1 => '點孔位放試管，按啟動。';

  @override
  String get rule3 => '實務模式：檢體不能動，用備用管配平。';

  @override
  String get legendHeading => '圖例';

  @override
  String get legendYours => '你放的試管';

  @override
  String get legendFixed => '固定試管';

  @override
  String get legendSpecimen => '檢體管';

  @override
  String get legendSpare => '備用管';

  @override
  String get legendBroken => '故障孔';

  @override
  String get scoresHeading => '成績';

  @override
  String get mathHeading => '背後的數學';

  @override
  String get math1 => '每支試管是從圓心指向孔位的向量，配平就是向量和為零。';

  @override
  String get math2 => 'n 孔能配平 k 支，若且唯若 k 與 n−k 都能寫成 n 的質因數之和。';

  @override
  String mathNow(int n, String factors, String counts) {
    return '$n 孔（質因數 $factors）：$counts。';
  }

  @override
  String get mathOnlyFull => '只有放滿';

  @override
  String mathAndFull(String counts) {
    return '$counts，以及放滿';
  }

  @override
  String get listSeparator => '、';

  @override
  String get privacyHeading => '隱私權政策';

  @override
  String get privacyTitle => '離心機配平 隱私權政策';

  @override
  String lastUpdated(String date) {
    return '最後更新：$date';
  }

  @override
  String get privacyIntro => '「離心機配平」App（以下簡稱本 App）由大安聯合醫事檢驗所提供。';

  @override
  String get privacy1Title => '我們不蒐集任何個人資料';

  @override
  String get privacy1 => '本 App 不需要帳號、不連接網路、沒有廣告，也沒有任何分析或追蹤工具，不會與任何第三方分享資料。';

  @override
  String get privacy2Title => '只存在你手機上的資料';

  @override
  String get privacy2 =>
      '關卡進度、最佳成績、上次的遊戲狀態，以及你自行輸入在執照上的暱稱，只儲存在你的裝置中，不會上傳。刪除本 App 或清除本 App 的資料，就會一併刪除。';

  @override
  String get privacy3Title => '權限';

  @override
  String get privacy3 =>
      '本 App 只使用「震動」權限，用於遊戲中的觸覺回饋。分享執照圖片時使用系統分享面板，本 App 本身不會送出任何資料。';

  @override
  String get privacy4Title => '兒童';

  @override
  String get privacy4 => '本 App 適合所有年齡，不蒐集任何兒童資料。';

  @override
  String get privacy5Title => '政策變更';

  @override
  String get privacy5 => '如果日後新增會影響資料使用的功能（例如廣告），我們會先更新本政策，並在 App 的更新說明中告知。';

  @override
  String get contactHeading => '聯絡我們';

  @override
  String get contactBlock =>
      '大安聯合醫事檢驗所 資訊室\n台北市大安區復興南路二段 151 巷 33 號\n電話：02-2704-9977\nEmail：SUPPORT@ucl.com.tw';

  @override
  String get webVersion => '網頁版';

  @override
  String get licenseTitle => '醫檢師執照';

  @override
  String get licenseSubtitle => '離心機配平 · 合格證明';

  @override
  String get holder => '持照人';

  @override
  String get holderUnnamed => '未具名';

  @override
  String get issued => '核發日期';

  @override
  String get licenseNo => '執照編號';

  @override
  String get statLevels => '關卡';

  @override
  String get statLaunches => '啟動次數';

  @override
  String get statFirstTry => '一次就過';

  @override
  String get stampLab => '實務合格';

  @override
  String get labPending => '實務模式 10 關全過，執照加蓋「實務合格」。';

  @override
  String get editName => '編輯暱稱';

  @override
  String get share => '分享';

  @override
  String get nicknameHint => '暱稱';

  @override
  String get save => '儲存';

  @override
  String get cancel => '取消';

  @override
  String get shareText => '我拿到「離心機配平」的醫檢師執照了！';

  @override
  String get shareFailed => '這裡無法分享。';

  @override
  String get licenseEarned => '取得執照！';

  @override
  String get endorsementEarned => '取得實務合格章！';

  @override
  String get viewLicense => '查看執照';

  @override
  String get hintL1 => '兩支面對面放。';

  @override
  String get hintL2 => '隔一孔放一支，排成三角形。';

  @override
  String get hintL3 => '每支固定管，對面補一支。';

  @override
  String get hintL4 => '對面壞了，改排三角形（每隔 4 孔）。';

  @override
  String get hintL5 => '5 = 3 + 2：一個三角形加一對。';

  @override
  String get hintL6 => '看空孔：5 個空孔平衡，試管就平衡。';

  @override
  String get hintL7 => '每隔一孔一支，正五邊形。';

  @override
  String get hintL8 => '一支配對面，另一支當三角形頂點。';

  @override
  String get hintL9 => '7 = 5 + 2：五邊形加一對。';

  @override
  String get hintL10 => '五邊形每隔 6 孔一支，再加一對。';

  @override
  String get hintLab1 => '對面補一支。';

  @override
  String get hintLab2 => '每支檢體對面各補一支。';

  @override
  String get hintLab3 => '兩支檢體差 120°，補上三角形第三個頂點。';

  @override
  String get hintLab4 => '對面壞了，用兩支排三角形。';

  @override
  String get hintLab5 => '已經對稱的那一對不用管。';

  @override
  String get hintLab6 => '三支備用管補成正五邊形。';

  @override
  String get hintLab7 => '一對加一個三角形，共兩支。';

  @override
  String get hintLab8 => '兩對加一個三角形。';

  @override
  String get hintLab9 => '15 孔沒有正對面，排五邊形。';

  @override
  String get hintLab10 => '五邊形缺兩個頂點，再補一支對面。';
}
