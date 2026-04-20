import 'package:supabase_flutter/supabase_flutter.dart' hide Provider;
import '/flutter_flow/flutter_flow_util.dart';

export 'database/database.dart';
export 'storage/storage.dart';

// TEMPORARY dev flag: while Phase 1.x schema work is in progress, dev builds
// target a separate test Supabase project so in-progress changes don't touch
// the live App Store / Play Store app. Flip to `false` before submitting to
// the app stores. Using an explicit const (not kDebugMode) so `--release`
// local builds also hit test.
const bool _kUseTestSupabase = true;

const _kProdSupabaseUrl = 'https://ejwgxsszmfabujdqxxdz.supabase.co';
const _kProdSupabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVqd2d4c3N6bWZhYnVqZHF4eGR6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzkyMjkyNTksImV4cCI6MjA1NDgwNTI1OX0.YMMB1zNX2REs_T1Fa39ibsxxDGJzElsc7zLW8fnk7U8';
const _kTestSupabaseUrl = 'https://yihmccmyijtyrffpzstb.supabase.co';
const _kTestSupabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlpaG1jY215aWp0eXJmZnB6c3RiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY1NjM5OTQsImV4cCI6MjA5MjEzOTk5NH0.t2UR1uxmojNiL9sn0vVxtDbwf46_ODZwKqDgX9xt9Io';

final String _kSupabaseUrl =
    _kUseTestSupabase ? _kTestSupabaseUrl : _kProdSupabaseUrl;
final String _kSupabaseAnonKey =
    _kUseTestSupabase ? _kTestSupabaseAnonKey : _kProdSupabaseAnonKey;

class SupaFlow {
  SupaFlow._();

  static SupaFlow? _instance;
  static SupaFlow get instance => _instance ??= SupaFlow._();

  final _supabase = Supabase.instance.client;
  static SupabaseClient get client => instance._supabase;

  static Future initialize() => Supabase.initialize(
        url: _kSupabaseUrl,
        headers: {
          'X-Client-Info': 'flutterflow',
        },
        anonKey: _kSupabaseAnonKey,
        debug: false,
        authOptions:
            FlutterAuthClientOptions(authFlowType: AuthFlowType.implicit),
      );
}
