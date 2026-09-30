import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/courtside_iq/design/ci_theme.dart';
import 'package:courtside_i_q/features/nav/ci_nav_bar.dart';

void main() {
  testWidgets('the bar forwards a refresh callback it is given',
      (tester) async {
    // The bar is shared chrome and cannot know how to refresh the screen it
    // sits under. Without this plumbing a player added from the nav bar saved
    // correctly and then appeared nowhere until a manual pull-to-refresh -
    // which reads to a parent as the save having failed.
    var refreshed = 0;
    final bar = CiNavBar(
      active: CiNavTab.home,
      onPlayerAdded: () => refreshed++,
    );

    expect(bar.onPlayerAdded, isNotNull);
    bar.onPlayerAdded!();
    expect(refreshed, 1);
  });

  testWidgets('an explicit onCreate takes the whole interaction over',
      (tester) async {
    var opened = 0;
    await tester.pumpWidget(MaterialApp(
      theme: CiTheme.base(),
      home: Scaffold(
        bottomNavigationBar: CiNavBar(
          active: CiNavTab.home,
          onCreate: () => opened++,
        ),
      ),
    ));

    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pump();
    // No network, no sheet: the override wins, which is what keeps this
    // testable at all.
    expect(opened, 1);
  });
}
