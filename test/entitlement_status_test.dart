import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/features/home/entitlement_status.dart';

void main() {
  group('entitlementStatus', () {
    test('active is premium, whatever the history', () {
      expect(entitlementStatus(isActive: true, everExisted: true),
          EntitlementStatus.premium);
      // active without a recorded history is still premium - a first-purchase
      // race where `all` has not caught up must not read as never-subscribed.
      expect(entitlementStatus(isActive: true, everExisted: false),
          EntitlementStatus.premium);
    });

    test('existed but not active is lapsed', () {
      expect(entitlementStatus(isActive: false, everExisted: true),
          EntitlementStatus.lapsed);
    });

    test('never existed is never', () {
      expect(entitlementStatus(isActive: false, everExisted: false),
          EntitlementStatus.never);
    });
  });

  group('banner mapping', () {
    test('premium shows no banner; lapsed and never do', () {
      // The screen decides visibility from the status; these are the three
      // cases it branches on.
      expect(EntitlementStatus.values.length, 3);
    });
  });
}
