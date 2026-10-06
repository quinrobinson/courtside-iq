// Managing a subscription — Phase 4.16
//
// APPLE AND GOOGLE OWN CANCELLATION. Nothing in this app can change, pause or
// end a subscription: the store took the money and the store holds the
// arrangement. So "Manage subscription" can only ever be a door out to the
// right page.
//
// That is the same fact the Help Center answer and the Delete Account screen
// both state. All three now point at the same place, so a parent told to
// cancel in the app store has a button that takes them there rather than a
// set of directions to follow by hand.

import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:url_launcher/url_launcher.dart';

/// Apple's account subscriptions page. Opens the App Store app when it is
/// installed and falls back to the web otherwise, which is why it is the
/// https form rather than itms-apps://.
const String kAppleSubscriptionsUrl =
    'https://apps.apple.com/account/subscriptions';

/// Google Play's subscriptions page.
const String kPlaySubscriptionsUrl =
    'https://play.google.com/store/account/subscriptions';

String get storeSubscriptionsUrl =>
    defaultTargetPlatform == TargetPlatform.android
        ? kPlaySubscriptionsUrl
        : kAppleSubscriptionsUrl;

/// Opens the store's subscription management page.
///
/// Never throws: a parent tapping this is already being sent somewhere we do
/// not control, and a crash on the way out would be the worst of both.
Future<void> openStoreSubscriptions() async {
  final uri = Uri.tryParse(storeSubscriptionsUrl);
  if (uri == null) return;
  try {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    // Nothing useful to say. The Help Center carries the manual steps.
  }
}
