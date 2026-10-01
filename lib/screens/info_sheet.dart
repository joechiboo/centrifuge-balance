import 'package:flutter/material.dart';

import '../state/game_state.dart';
import '../theme/palette.dart';

/// Rules, legend and the maths, tucked away behind the info button.
Future<void> showInfoSheet(BuildContext context, GameState state) {
  final p = Palette.of(context);
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: p.panel,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _h(p, '玩法'),
            _bullet(p, '點孔位放入或取出試管，放滿指定支數後按啟動。'),
            _bullet(p, '平衡就會加速到 4,000 rpm；不平衡會震動停機，箭頭指出偏重方向。'),
            _bullet(p, '卡關按提示，再按一次會畫出其中一種擺法。'),
            const SizedBox(height: 18),
            _h(p, '圖例'),
            _legend(p, p.cap, '你放的試管'),
            _legend(p, p.fixed, '已固定，不能拿走'),
            _legend(p, p.steelLo, '故障孔，不能放', dashed: true),
            const SizedBox(height: 18),
            _h(p, '背後的數學'),
            _para(p, '把每支試管看成從圓心指向孔位的向量，配平就是所有向量相加為零。'),
            _para(p, '定理：n 孔的離心機能配平 k 支試管，若且唯若 k 與 n−k 都能寫成 n 的質因數之和。'),
            _para(
              p,
              '目前 ${state.n} 孔（質因數 ${state.primeFactorText}）能配平的支數：${state.balanceableText}。',
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _h(Palette p, String t) => Padding(
  padding: const EdgeInsets.only(bottom: 8),
  child: Text(
    t,
    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: p.ink),
  ),
);

TextStyle _body(Palette p) =>
    TextStyle(fontSize: 14.5, color: p.muted, height: 1.6);

Widget _para(Palette p, String t) => Padding(
  padding: const EdgeInsets.only(bottom: 6),
  child: Text(t, style: _body(p)),
);

Widget _bullet(Palette p, String t) => Padding(
  padding: const EdgeInsets.only(bottom: 4),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('• ', style: _body(p)),
      Expanded(child: Text(t, style: _body(p))),
    ],
  ),
);

Widget _legend(Palette p, Color fill, String t, {bool dashed = false}) =>
    Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: fill,
              border: dashed ? Border.all(color: p.muted) : null,
            ),
          ),
          const SizedBox(width: 8),
          Text(t, style: _body(p)),
        ],
      ),
    );
