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

    LogInResult result = await Purchases.logIn(userId);

    debugPrint('RevenueCat login successful');
    return true;
  } catch (e) {
    debugPrint('RevenueCat login error: $e');
    return false;
  }
}
