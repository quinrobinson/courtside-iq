// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:supabase_flutter/supabase_flutter.dart';

Future<String?> updatePassword(
  String newPassword,
  String confirmNewPassword,
) async {
  // Add your function code here!

  // Get a reference your Supabase client
  final supabase = SupaFlow.client;

  // Check if passwords match
  if (newPassword != confirmNewPassword) {
    return "Passwords do not match!";
  }

  try {
    await supabase.auth.updateUser(UserAttributes(password: newPassword));

    // Return null if the user has successfully reset their password
    return null;
  } catch (e) {
    // Return the error as to why reset password failed
    return e.toString();
  }
}
