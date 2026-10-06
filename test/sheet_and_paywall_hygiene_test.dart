// Sheets and the paywall, under the nav shell — Phase 4.19f
//
// TWO INVARIANTS THE SHELL MADE LOAD-BEARING, both found by checking the
// free-tier paywall on device rather than by any test:
//
// 1. A modal sheet must cover the nav bar. `showModalBottomSheet` defaults to
//    `useRootNavigator: false`, so it pushes onto the CURRENT navigator - and
//    inside the shell that is the BRANCH navigator, which lives in the shell's
//    body. The sheet then renders inside the branch with the tabs sitting over
//    it. Every sheet in the app was written before the shell existed, so every
//    one of them was wrong the moment it landed.
//
// 2. There is ONE paywall API. Three screens built their own sheet around the
//    v1 PaywallWidget instead of calling showPaywall, which meant they ignored
//    kUsePaywall2 - a FREE parent hitting the add-player gate got the v1
//    paywall on the primary conversion path, and after the shell, got it with
//    a nav bar over it.
//
// Source-scanning rather than widget-pumping on purpose: these are properties
// of how the app is WIRED, and a widget test only ever proves the one path it
// happens to pump.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Dart sources under the 2.0 surfaces.
List<File> _sources() => [
      for (final dir in const ['lib/features', 'lib/courtside_iq'])
        ...Directory(dir)
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart')),
    ];

void main() {
  test('every modal sheet covers the nav bar', () {
    final offenders = <String>[];

    for (final file in _sources()) {
      final src = file.readAsStringSync();
      var from = 0;
      while (true) {
        final i = src.indexOf('showModalBottomSheet', from);
        if (i < 0) break;
        from = i + 1;
        // The flag has to appear inside this call, not merely in the file.
        final close = src.indexOf(');', i);
        final call = close < 0 ? src.substring(i) : src.substring(i, close);
        if (!call.contains('useRootNavigator')) {
          offenders.add('${file.path} @${src.substring(0, i).split('\n').length}');
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason: 'these sheets push onto the shell BRANCH navigator, so the nav '
          'bar renders over them: ${offenders.join(', ')}',
    );
  });

  test('the live screens use the one paywall API, not the v1 widget', () {
    final offenders = <String>[];
    for (final file in _sources()) {
      // paywall_launcher IS the one API, and it owns the kUsePaywall2 fallback
      // to the v1 widget - that is the whole point of routing through it.
      if (file.path.endsWith('paywall_launcher.dart')) continue;
      // DashboardPage is the pre-Today fallback and is unreachable while
      // kUseToday2 is on. Deliberately exempt rather than silently skipped.
      if (file.path.endsWith('dashboard_page.dart')) continue;
      if (file.readAsStringSync().contains('PaywallWidget(')) {
        offenders.add(file.path);
      }
    }

    expect(
      offenders,
      isEmpty,
      reason: 'building the v1 PaywallWidget directly bypasses showPaywall and '
          'kUsePaywall2, so a free parent sees the wrong paywall: '
          '${offenders.join(', ')}',
    );
  });
}
