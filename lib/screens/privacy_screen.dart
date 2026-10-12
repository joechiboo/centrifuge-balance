import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/palette.dart';

/// Web copy of this policy. Shown as selectable text only: the app has no
/// INTERNET permission and no URL launcher, which is what the policy says.
const String privacyPolicyUrl =
    'https://joechiboo.github.io/centrifuge-balance/privacy.html';

/// In-app copy of the privacy policy. The wording mirrors privacy.html at
/// the repository root (Chinese and English sections); keep them in sync.
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  static const String lastUpdated = '2026-10-12';

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final l = AppLocalizations.of(context);
    final body = TextStyle(fontSize: 15, color: p.ink, height: 1.7);
    final muted = TextStyle(fontSize: 13.5, color: p.muted, height: 1.6);

    Widget item(String title, String text) => Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$title: ',
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
        title: Text(l.privacyHeading),
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
                    l.privacyTitle,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: p.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(l.lastUpdated(lastUpdated), style: muted),
                  const SizedBox(height: 18),
                  Text(l.privacyIntro, style: body),
                  const SizedBox(height: 14),
                  item(l.privacy1Title, l.privacy1),
                  item(l.privacy2Title, l.privacy2),
                  item(l.privacy3Title, l.privacy3),
                  item(l.privacy4Title, l.privacy4),
                  item(l.privacy5Title, l.privacy5),
                  const SizedBox(height: 6),
                  Text(
                    l.contactHeading,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: p.ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SelectableText(l.contactBlock, style: body),
                  const SizedBox(height: 28),
                  Divider(color: p.line, height: 1),
                  const SizedBox(height: 14),
                  Text(l.webVersion, style: muted),
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
