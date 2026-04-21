// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import '/features/players/birth_date_profile_banner.dart';

/// Place this at the top of the player profile screen. Self-fetches
/// `players.birth_date` by [playerId]; renders the teal banner only when the
/// column is null, otherwise collapses to zero size.
class BirthDateProfileBannerWidget extends StatefulWidget {
  const BirthDateProfileBannerWidget({
    super.key,
    this.width,
    this.height,
    required this.playerId,
    required this.playerFirstName,
  });

  final double? width;
  final double? height;
  final String playerId;
  final String playerFirstName;

  @override
  State<BirthDateProfileBannerWidget> createState() =>
      _BirthDateProfileBannerWidgetState();
}

class _BirthDateProfileBannerWidgetState
    extends State<BirthDateProfileBannerWidget> {
  bool _loading = true;
  bool _hasBirthDate = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final row = await SupaFlow.client
          .from('players')
          .select('birth_date')
          .eq('id', widget.playerId)
          .maybeSingle();
      final bd = row?['birth_date'];
      if (!mounted) return;
      setState(() {
        _loading = false;
        _hasBirthDate = bd != null && bd.toString().isNotEmpty;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _hasBirthDate) return const SizedBox.shrink();
    return SizedBox(
      width: widget.width,
      child: BirthDateProfileBanner(
        playerId: widget.playerId,
        playerFirstName: widget.playerFirstName,
        onSaved: () {
          if (mounted) setState(() => _hasBirthDate = true);
        },
      ),
    );
  }
}
