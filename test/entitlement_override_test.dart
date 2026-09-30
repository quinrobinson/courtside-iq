// The dev entitlement override must never ship set.
//
// It exists because a lapse cannot be produced on demand - it comes from
// RevenueCat, and a sandbox subscription takes ~30 minutes of accelerated
// renewals to expire. The override makes the lapsed surfaces reviewable in
// seconds, and would make every parent look lapsed if it shipped.
//
// It is a plain const, not a kDebugMode check, because device testing runs in
// --release here. So this test is the only thing standing between a review
// session and a shipped build that lies about everyone's subscription.

import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/features/home/entitlement_status.dart';

void main() {
  test('kDebugForceEntitlement is null', () {
    expect(kDebugForceEntitlement, isNull,
        reason: 'set it back to null before committing');
  });
}
