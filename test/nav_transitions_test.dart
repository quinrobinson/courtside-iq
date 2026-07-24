// Transition policy — Phase 4.19f part 2
//
// The bug this guards against is a SILENT one. `hasTransition: false` looks
// like "no animation", but it falls through to MaterialPage, and on iOS that
// is the Cupertino push slide - so the app slid every screen in from the right
// while the code read as though it did nothing at all. Screens that wanted a
// fade had to hand-roll one, and five of them did.
//
// So this asserts the POLICY, not an animation: the default is a crossfade,
// the slide exists but must be opted into, and the opt-in carries it under the
// key the router actually reads.

import 'package:flutter_test/flutter_test.dart';
import 'package:page_transition/page_transition.dart';

import 'package:courtside_i_q/flutter_flow/nav/nav.dart';

void main() {
  test('the default is a quick crossfade, not an inherited slide', () {
    final t = TransitionInfo.appDefault();
    expect(t.hasTransition, isTrue,
        reason: 'false falls through to MaterialPage, which slides on iOS');
    expect(t.transitionType, PageTransitionType.fade);
    expect(t.duration.inMilliseconds, lessThanOrEqualTo(250),
        reason: 'a slow fade on a tab-level move reads as lag');
  });

  test('the slide exists for real pushes, and is opt-in', () {
    final t = TransitionInfo.push();
    expect(t.hasTransition, isTrue);
    expect(t.transitionType, PageTransitionType.rightToLeft,
        reason: 'a push comes from the right and can be swiped back');
    // Distinct from the default, or opting in would be a no-op.
    expect(t.transitionType, isNot(TransitionInfo.appDefault().transitionType));
  });

  test('slideInExtra carries the slide under the key the router reads', () {
    final extra = slideInExtra();
    expect(extra, contains(kTransitionInfoKey));
    final t = extra[kTransitionInfoKey] as TransitionInfo;
    expect(t.transitionType, PageTransitionType.rightToLeft);
  });
}
