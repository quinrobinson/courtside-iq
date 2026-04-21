// Dev-only smoke test for the generate-player-insight Edge Function.
//
// Usage:
//   export TEST_USER_PASSWORD='...'
//   dart run tool/smoke_player_insight.dart [playerId]
//
// If playerId is omitted, the script invokes the function for every player
// belonging to testuser@mail.com.

import 'dart:convert';
import 'dart:io';

import 'package:supabase/supabase.dart';

const _testUrl = 'https://yihmccmyijtyrffpzstb.supabase.co';
const _testAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlpaG1jY215aWp0eXJmZnB6c3RiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY1NjM5OTQsImV4cCI6MjA5MjEzOTk5NH0.t2UR1uxmojNiL9sn0vVxtDbwf46_ODZwKqDgX9xt9Io';
const _email = 'testuser@mail.com';

Future<void> main(List<String> args) async {
  final password = Platform.environment['TEST_USER_PASSWORD'];
  if (password == null || password.isEmpty) {
    stderr.writeln('Set TEST_USER_PASSWORD in the environment.');
    exit(1);
  }

  final supabase = SupabaseClient(_testUrl, _testAnonKey);
  final auth = await supabase.auth.signInWithPassword(
    email: _email,
    password: password,
  );
  final userId = auth.user?.id;
  if (userId == null) {
    stderr.writeln('Sign-in failed.');
    exit(1);
  }
  stdout.writeln('Signed in as $_email ($userId)');

  List<String> playerIds;
  if (args.isNotEmpty) {
    playerIds = [args.first];
  } else {
    final rows = await supabase
        .from('players')
        .select('id, first_name')
        .order('first_name');
    playerIds = [];
    for (final r in rows as List) {
      final m = r as Map;
      stdout.writeln('  player: ${m['first_name']}  (${m['id']})');
      playerIds.add(m['id'] as String);
    }
  }

  const pretty = JsonEncoder.withIndent('  ');
  for (final pid in playerIds) {
    stdout.writeln('\n--- invoking for $pid ---');
    try {
      final res = await supabase.functions.invoke(
        'generate-player-insight',
        body: {'player_id': pid},
      );
      stdout.writeln('status: ${res.status}');
      stdout.writeln(pretty.convert(res.data));
    } catch (e) {
      stderr.writeln('error: $e');
    }
  }

  await supabase.auth.signOut();
  exit(0);
}
