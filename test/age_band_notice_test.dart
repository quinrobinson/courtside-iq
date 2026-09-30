import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/courtside_iq/design/ci_theme.dart';
import 'package:courtside_i_q/features/players/age_band_service.dart';
import 'package:courtside_i_q/features/players/widgets/age_band_notice.dart';

Widget _host(Widget child) => MaterialApp(
      theme: CiTheme.base(),
      home: CiSurface.light(child: Scaffold(body: child)),
    );

void main() {
  group('movedUp', () {
    test('a first sighting announces nothing', () {
      // The trap: with nothing stored, every existing player would be told
      // they "moved up to" the band they have always been in, the first time
      // they open this build.
      expect(AgeBandService.movedUp(current: 'U14', lastSeen: null), isFalse);
      expect(AgeBandService.movedUp(current: 'U14', lastSeen: ''), isFalse);
    });

    test('the same band announces nothing', () {
      expect(AgeBandService.movedUp(current: 'U14', lastSeen: 'U14'), isFalse);
      // Whitespace is not a transition.
      expect(
          AgeBandService.movedUp(current: ' U14 ', lastSeen: 'U14'), isFalse);
    });

    test('a different band announces', () {
      expect(AgeBandService.movedUp(current: 'U16', lastSeen: 'U14'), isTrue);
    });

    test('a player with no band announces nothing', () {
      // No birth date, so no band. There is nothing to have moved up from.
      expect(AgeBandService.movedUp(current: null, lastSeen: 'U14'), isFalse);
      expect(AgeBandService.movedUp(current: '', lastSeen: 'U14'), isFalse);
    });
  });

  testWidgets('the notice explains the shift before it is misread',
      (tester) async {
    await tester.pumpWidget(_host(const AgeBandNotice(
      firstName: 'Maya',
      ageBand: 'U16',
    )));

    expect(find.text('Maya moved up to U16'), findsOneWidget);
    expect(
        find.text('Ratings are now calibrated for the U16 age band, '
            'so comparisons stay fair.'),
        findsOneWidget);
  });

  testWidgets('a player without a first name still reads as a sentence',
      (tester) async {
    await tester.pumpWidget(_host(const AgeBandNotice(
      firstName: '',
      ageBand: 'U16',
    )));

    expect(find.text('Your player moved up to U16'), findsOneWidget);
  });

  testWidgets('dismiss is offered only when it does something', (tester) async {
    await tester.pumpWidget(_host(const AgeBandNotice(
      firstName: 'Maya',
      ageBand: 'U16',
    )));
    expect(find.byIcon(Icons.close), findsNothing);

    var dismissed = false;
    await tester.pumpWidget(_host(AgeBandNotice(
      firstName: 'Maya',
      ageBand: 'U16',
      onDismiss: () => dismissed = true,
    )));
    await tester.tap(find.byIcon(Icons.close));
    expect(dismissed, isTrue);
  });
}
