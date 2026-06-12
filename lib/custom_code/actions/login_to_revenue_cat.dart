// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
import 'package:purchases_flutter/purchases_flutter.dart';

Future<bool> loginToRevenueCat(String userId) async {
  try {
    if (userId.isEmpty) {
      debugPrint('RevenueCat: Cannot log in with empty user ID');
      return false;
    }

    final result = await Purchases.logIn(userId);

    // Premium = the user actually holds the `premium_users` entitlement.
    // Previously this returned `true` whenever login merely succeeded (which
    // is always), silently granting premium to every account.
    return result.customerInfo.entitlements.active.containsKey('premium_users');
  } catch (e) {
    debugPrint('RevenueCat login error: $e');
    return false;
  }
}
