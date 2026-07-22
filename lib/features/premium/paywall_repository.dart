// The paywall's data and purchase path — Phase 4.16
//
// Wraps RevenueCat so the screen and the pricing logic can be tested without a
// live purchase. The screen talks to this; this talks to purchases_flutter.
//
// PRICE STRINGS COME FROM REVENUECAT, not the frame. The design draws $5.99
// and $1.99, but storeProduct.priceString is localised and follows a price
// change without an app update - a parent in the UK must see £, and a price
// we raise next year must not still read $5.99 on an old build. The frame's
// numbers are the fallback for when offerings cannot load.
//
// EVERYTHING IDENTIFIES TO REVENUECAT AS THE SUPABASE UID FIRST. A purchase
// attributed to the wrong app-user id is the multi-device and wrong-account
// bug the entitlement notes describe: buy on one device, and every other
// device signed into the same account must see it. logIn(uid) is what ties
// the entitlement to the login rather than the handset.

import 'package:flutter/services.dart' show PlatformException;
import 'package:purchases_flutter/purchases_flutter.dart';

import '/auth/supabase_auth/auth_util.dart';
import '/flutter_flow/revenue_cat_util.dart' as revenue_cat;

/// One plan the paywall can sell.
class PaywallPlan {
  const PaywallPlan({
    required this.packageId,
    required this.price,
    required this.hasTrial,
  });

  /// The RevenueCat package identifier, passed back to purchase().
  final String packageId;

  /// Localised, e.g. "$5.99" or "£4.99". Never assembled by hand.
  final String price;

  /// Whether this plan carries the intro free trial. Monthly does, weekly
  /// does not - confirmed with the store config 2026-07-23.
  final bool hasTrial;
}

/// The two plans, either of which may be null if the store did not return it.
class PaywallOffer {
  const PaywallOffer({this.monthly, this.weekly});

  final PaywallPlan? monthly;
  final PaywallPlan? weekly;

  bool get hasAny => monthly != null || weekly != null;
}

/// What a purchase attempt did.
enum PurchaseOutcome {
  /// Bought, entitlement now active.
  purchased,

  /// The parent backed out of the store sheet. NOT an error - no message.
  cancelled,

  /// The store or network failed. Worth a retry.
  failed,

  /// Already premium. Nothing to buy; send them on.
  alreadyPremium,
}

class PaywallRepository {
  const PaywallRepository();

  /// Reads the current offering as a plain model.
  ///
  /// Identifies as the signed-in uid first, so the offering and any later
  /// purchase attach to the account, not the device.
  Future<PaywallOffer> loadOffer() async {
    final uid = currentUserUid;
    if (uid.isNotEmpty) {
      try {
        await Purchases.logIn(uid);
      } catch (_) {
        // A failed login is not a reason to hide the paywall. The purchase
        // path logs in again and is the one that must not be wrong.
      }
    }

    await revenue_cat.loadOfferings();
    final current = revenue_cat.offerings?.current;
    if (current == null) return const PaywallOffer();

    PaywallPlan? plan(Package? p, {required bool hasTrial}) {
      if (p == null) return null;
      return PaywallPlan(
        packageId: p.identifier,
        price: p.storeProduct.priceString,
        hasTrial: hasTrial,
      );
    }

    return PaywallOffer(
      monthly: plan(current.monthly, hasTrial: true),
      weekly: plan(current.weekly, hasTrial: false),
    );
  }

  /// Whether the account is already premium, so the paywall can show the
  /// Already-Premium state rather than trying to sell to a subscriber.
  Future<bool> isPremium() async {
    final entitled = await revenue_cat.isEntitled('premium_users');
    return entitled ?? false;
  }

  Future<PurchaseOutcome> purchase(String packageId) async {
    final uid = currentUserUid;
    if (uid.isNotEmpty) {
      try {
        await Purchases.logIn(uid);
      } catch (_) {
        // Fall through: purchasePackage still attempts, and a wrong-account
        // purchase is caught by the webhook keying on app_user_id.
      }
    }

    // Purchases.purchasePackage directly, not revenue_cat.purchasePackage,
    // which swallows every error into a bool. A CANCEL and a FAILURE both
    // return false there, and cancel must not raise the red error state - the
    // parent chose to stop.
    final package = revenue_cat.offerings?.current?.getPackage(packageId);
    if (package == null) return PurchaseOutcome.failed;

    try {
      // ignore: deprecated_member_use
      // purchasePackage is deprecated for purchase(PurchaseParams) in this SDK
      // version, but it is what ships in v1 and what revenue_cat_util uses.
      // Changing the purchase primitive is not a paywall-UI decision.
      await Purchases.purchasePackage(package);
      return PurchaseOutcome.purchased;
    } on PlatformException catch (e) {
      final code = PurchasesErrorHelper.getErrorCode(e);
      if (code == PurchasesErrorCode.purchaseCancelledError) {
        return PurchaseOutcome.cancelled;
      }
      if (code == PurchasesErrorCode.productAlreadyPurchasedError) {
        return PurchaseOutcome.alreadyPremium;
      }
      return PurchaseOutcome.failed;
    } catch (_) {
      return PurchaseOutcome.failed;
    }
  }

  /// Restores a purchase made on another device or a reinstall. Apple
  /// REQUIRES this control on any screen that sells a subscription.
  Future<PurchaseOutcome> restore() async {
    try {
      await revenue_cat.restorePurchases();
      return await isPremium()
          ? PurchaseOutcome.alreadyPremium
          : PurchaseOutcome.failed;
    } catch (_) {
      return PurchaseOutcome.failed;
    }
  }
}
