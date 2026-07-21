// Entitlement status — Phase 4.10b
//
// Which premium state to show a parent, decided from a CLIENT-SIDE RevenueCat
// read. This does not touch Supabase, does not touch prod, and has nothing to
// do with the deferred `subscriptions` backfill or the server-side RLS limit.
// It reads only what RevenueCat already tells the client.
//
// The distinction the two banners need - never-subscribed vs lapsed - is
// cheaply available: RevenueCat's `entitlements.all` includes INACTIVE
// entitlements, so a `premium_users` key present in `.all` but absent from
// `.active` means the subscription once existed and expired.

import 'package:purchases_flutter/purchases_flutter.dart';

import '/auth/supabase_auth/auth_util.dart';

const String kPremiumEntitlement = 'premium_users';

enum EntitlementStatus {
  /// Active premium. No banner.
  premium,

  /// Was premium, now expired. Renew banner.
  lapsed,

  /// Never subscribed. Upgrade banner.
  never,
}

/// Maps a RevenueCat customer to a premium state.
///
/// Pure: a [CustomerInfo] in, a status out, no I/O. That is what makes the
/// three-way distinction testable without a live purchase - the render of the
/// lapsed state still needs a genuinely expired account, but the LOGIC does
/// not.
EntitlementStatus entitlementStatusOf(CustomerInfo info) => entitlementStatus(
      isActive: info.entitlements.active.containsKey(kPremiumEntitlement),
      everExisted: info.entitlements.all.containsKey(kPremiumEntitlement),
    );

/// The pure decision, on plain booleans so it can be tested without building a
/// CustomerInfo - which is a RevenueCat model with no simple constructor.
EntitlementStatus entitlementStatus({
  required bool isActive,
  required bool everExisted,
}) {
  if (isActive) return EntitlementStatus.premium;
  // Ever existed but not active means it lapsed; never existed means never.
  if (everExisted) return EntitlementStatus.lapsed;
  return EntitlementStatus.never;
}

/// Reads the current customer and maps it. Returns [EntitlementStatus.never]
/// on any failure - the safe default is to invite rather than to nag, and a
/// network blip must not tell a paying parent their premium has ended.
///
/// IDENTIFIES THE USER FIRST, and that is not optional. RevenueCat keeps
/// whatever app-user id it was last given, so reading customer info without
/// logging in returns the entitlement of whoever happened to be signed in
/// before. On device that attributed a real purchase to a DIFFERENT account
/// than the one signed in: the buyer stayed non-premium and the server
/// rejected their next insert. The v1 dashboard called loginToRevenueCat on
/// load; the 2.0 screens must do the equivalent.
Future<EntitlementStatus> fetchEntitlementStatus() async {
  try {
    final uid = currentUserUid;
    final info = uid.isEmpty
        ? await Purchases.getCustomerInfo()
        : (await Purchases.logIn(uid)).customerInfo;
    return entitlementStatusOf(info);
  } catch (_) {
    return EntitlementStatus.never;
  }
}
