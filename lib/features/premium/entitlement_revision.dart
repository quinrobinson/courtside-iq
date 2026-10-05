// "The premium state changed" — Release 2.1
//
// The twin of players_revision.dart and games_revision.dart. Today reads the
// entitlement once and is kept alive by the nav shell's indexedStack, so a
// parent who subscribed from anywhere but Today's own banner (the add-player
// gate, the game limit sheet, Menu) came back to a Today still saying
// "Unlock Premium" - the first thing a brand new subscriber sees. Found on
// the 2.1 sandbox purchase, 2026-10-05.
//
// RevenueCat announces instead. Its customer-info listener (revenue_cat_util)
// fires on purchase, restore, renewal and expiry, wherever they started, and
// bumps this. Screens that show premium state subscribe and re-read.

import 'package:flutter/foundation.dart';

/// Bumped whenever RevenueCat reports a customer change. The value is
/// meaningless; only the change matters.
final ValueNotifier<int> entitlementRevision = ValueNotifier<int>(0);

/// Call when the premium state may have changed.
void notifyEntitlementChanged() => entitlementRevision.value++;
