import 'package:flutter/material.dart';

import '../theme/palette.dart';

/// Web copy of this policy. Shown as selectable text only: the app has no
/// INTERNET permission and no URL launcher, which is what the policy says.
const String privacyPolicyUrl =
    'https://joechiboo.github.io/centrifuge-balance/privacy.html';

/// In-app copy of the privacy policy. The wording mirrors the Chinese
/// section of privacy.html at the repository root; keep the two in sync.
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  static const String lastUpdated = '2026-10-03';

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final body = TextStyle(fontSize: 15, color: p.ink, height: 1.7);
    final muted = TextStyle(fontSize: 13.5, color: p.muted, height: 1.6);

    Widget item(String title, String text) => Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$title：',
              style: body.copyWith(fontWeight: FontWeight.w700),
            ),
            TextSpan(text: text),
          ],
        ),
        style: body,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('隱私權政策'),
        backgroundColor: p.bg,
        foregroundColor: p.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '離心機配平 隱私權政策',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: p.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('最後更新：$lastUpdated', style: muted),
                  const SizedBox(height: 18),
                  Text('「離心機配平」App（以下簡稱本 App）由大安聯合醫事檢驗所提供。', style: body),
                  const SizedBox(height: 14),
                  item(
                    '我們不蒐集任何個人資料',
                    '本 App 不需要帳號、不連接網路、沒有廣告，也沒有任何分析或追蹤工具，不會與任何第三方分享資料。',
                  ),
                  item(
                    '只存在你手機上的資料',
                    '關卡進度、最佳成績與上次的遊戲狀態，只儲存在你的裝置中，不會上傳。刪除本 App 或清除本 App 的資料，就會一併刪除。',
                  ),
                  item('權限', '本 App 只使用「震動」權限，用於遊戲中的觸覺回饋。'),
                  item('兒童', '本 App 適合所有年齡，不蒐集任何兒童資料。'),
                  item(
                    '政策變更',
                    '如果日後新增會影響資料使用的功能（例如廣告），我們會先更新本政策，並在 App 的更新說明中告知。',
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '聯絡我們',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: p.ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    '大安聯合醫事檢驗所 資訊室\n'
                    '台北市大安區復興南路二段 151 巷 33 號\n'
                    '電話：02-2704-9977\n'
                    'Email：SUPPORT@ucl.com.tw',
                    style: body,
                  ),
                  const SizedBox(height: 28),
                  Divider(color: p.line, height: 1),
                  const SizedBox(height: 14),
                  Text('網頁版', style: muted),
                  const SizedBox(height: 4),
                  SelectableText(
                    privacyPolicyUrl,
                    style: TextStyle(fontSize: 13.5, color: p.cap, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
