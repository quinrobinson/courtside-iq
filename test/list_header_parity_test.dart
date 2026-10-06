import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/courtside_iq/design/ci_theme.dart';
import 'package:courtside_i_q/courtside_iq/design/tokens/ci_colors.dart';
import 'package:courtside_i_q/courtside_iq/design/tokens/ci_metrics.dart';
import 'package:courtside_i_q/courtside_iq/design/tokens/ci_type.dart';

/// Games and Players are the same kind of screen, so their headers must not
/// drift. This asserts the shared floor rather than the built widgets, because
/// both real headers need a repository to render.
void main() {
  testWidgets('both list headers share one content height', (tester) async {
    // The Players header is sized by a 40pt icon button; the Games header has
    // only text, which measures ~31. Without the shared constant they sat 9pt
    // apart, visible the moment a parent switches tabs.
    expect(kCiListHeaderContentHeight, 40);

    await tester.pumpWidget(MaterialApp(
      theme: CiTheme.base(),
      home: CiSurface.ink(
        child: Builder(builder: (context) {
          final c = CiColors.of(context);
          return Scaffold(
            body: SizedBox(
              height: kCiListHeaderContentHeight,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Games',
                    style: CiType.h2.copyWith(
                        color: c.text, fontWeight: CiWeight.extraBold)),
              ),
            ),
          );
        }),
      ),
    ));

    // The title fits inside the shared height rather than being clipped by it.
    final title = tester.getSize(find.text('Games'));
    expect(title.height, lessThanOrEqualTo(kCiListHeaderContentHeight));
  });
}
