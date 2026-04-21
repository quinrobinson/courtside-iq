import 'package:flutter/material.dart';

import '/backend/supabase/supabase.dart';

const _card = Colors.white;
const _cardBorder = Color(0xFFE3E1E0);
const _tile = Color(0xFFF3F3F3);
const _ink = Color(0xFF0F0F0F);
const _sub = Color(0xFF6A6A6A);
const _hint = Color(0xFF8E8E8E);
const _green = Color(0xFF2BC18C);
const _greenBg = Color(0xFFE6F7EF);
const _red = Color(0xFFD9005C);
const _redBg = Color(0xFFFBE5EE);

class AveragesTab extends StatefulWidget {
  const AveragesTab({super.key, required this.playerId});

  final String playerId;

  @override
  State<AveragesTab> createState() => _AveragesTabState();
}

class _AveragesTabState extends State<AveragesTab> {
  Map<String, dynamic>? _profile;
  List<Map<String, dynamic>>? _recent;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final profile = await SupaFlow.client
          .from('player_profile_view')
          .select(
            'total_points, total_fg_made, total_fg_attempt, total_three_made, '
            'total_three_attempt, total_ft_made, total_ft_attempt, '
            'total_off_reb, total_def_reb, total_assist, total_steal, '
            'total_block, total_turnover, total_games',
          )
          .eq('player_id', widget.playerId)
          .maybeSingle();
      final recent = await SupaFlow.client
          .from('v_player_game_stats')
          .select(
            'fg_made, fg_attempt, three_made, three_attempt, ft_made, ft_attempt',
          )
          .eq('player_id', widget.playerId)
          .order('created_at', ascending: false)
          .limit(5);
      if (!mounted) return;
      setState(() {
        _profile = profile == null ? null : Map<String, dynamic>.from(profile);
        _recent = List<Map<String, dynamic>>.from(recent);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Text('Error loading averages: $_error',
            style: const TextStyle(color: _sub)),
      );
    }
    if (_profile == null || _recent == null) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final p = _profile!;
    final games = (p['total_games'] as num?)?.toInt() ?? 0;
    if (games == 0) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Text(
          'No games logged yet.',
          textAlign: TextAlign.center,
          style: TextStyle(color: _sub, fontFamily: 'Inter'),
        ),
      );
    }

    double avg(String k) => (((p[k] as num?) ?? 0).toDouble()) / games;

    final ppg = avg('total_points');
    final rpg = avg('total_off_reb') + avg('total_def_reb');
    final apg = avg('total_assist');
    final spg = avg('total_steal');
    final bpg = avg('total_block');
    final topg = avg('total_turnover');

    double pct(num made, num att) => att == 0 ? 0 : made.toDouble() / att.toDouble() * 100;

    final fgMade = (p['total_fg_made'] as num?) ?? 0;
    final fgAtt = (p['total_fg_attempt'] as num?) ?? 0;
    final tpMade = (p['total_three_made'] as num?) ?? 0;
    final tpAtt = (p['total_three_attempt'] as num?) ?? 0;
    final ftMade = (p['total_ft_made'] as num?) ?? 0;
    final ftAtt = (p['total_ft_attempt'] as num?) ?? 0;

    final fgPct = pct(fgMade, fgAtt);
    final tpPct = pct(tpMade, tpAtt);
    final ftPct = pct(ftMade, ftAtt);

    num rSum(String k) => _recent!.fold<num>(0, (a, r) => a + ((r[k] as num?) ?? 0));
    final rFgPct = pct(rSum('fg_made'), rSum('fg_attempt'));
    final rTpPct = pct(rSum('three_made'), rSum('three_attempt'));
    final rFtPct = pct(rSum('ft_made'), rSum('ft_attempt'));

    final showTrend = _recent!.length >= 3;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _card1(ppg, rpg, apg, spg, bpg, topg, games),
          const SizedBox(height: 10),
          if (fgAtt > 0 || tpAtt > 0 || ftAtt > 0)
            _card2(
              fgPct: fgPct, rFgPct: rFgPct, fgMade: fgMade, fgAtt: fgAtt,
              tpPct: tpPct, rTpPct: rTpPct, tpMade: tpMade, tpAtt: tpAtt,
              ftPct: ftPct, rFtPct: rFtPct, ftMade: ftMade, ftAtt: ftAtt,
              showTrend: showTrend,
            ),
        ],
      ),
    );
  }

  Widget _card1(double ppg, double rpg, double apg, double spg, double bpg, double topg, int games) {
    String f(double v) => v.toStringAsFixed(1);
    return Container(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder, width: 1),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Per-game averages',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: _ink,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Based on $games ${games == 1 ? 'game' : 'games'}',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              color: _sub,
            ),
          ),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _tileStat(f(ppg), 'PPG')),
            const SizedBox(width: 8),
            Expanded(child: _tileStat(f(rpg), 'RPG')),
            const SizedBox(width: 8),
            Expanded(child: _tileStat(f(apg), 'APG')),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _tileStat(f(spg), 'SPG')),
            const SizedBox(width: 8),
            Expanded(child: _tileStat(f(bpg), 'BPG')),
            const SizedBox(width: 8),
            Expanded(child: _tileStat(f(topg), 'TOPG')),
          ]),
        ],
      ),
    );
  }

  Widget _card2({
    required double fgPct, required double rFgPct, required num fgMade, required num fgAtt,
    required double tpPct, required double rTpPct, required num tpMade, required num tpAtt,
    required double ftPct, required double rFtPct, required num ftMade, required num ftAtt,
    required bool showTrend,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder, width: 1),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Shooting',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: _ink,
            ),
          ),
          if (showTrend)
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Text(
                'Last 5 vs lifetime',
                style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: _sub),
              ),
            ),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _shotTile('FG%', fgPct, rFgPct, fgMade, fgAtt, showTrend)),
            const SizedBox(width: 8),
            Expanded(child: _shotTile('3P%', tpPct, rTpPct, tpMade, tpAtt, showTrend)),
            const SizedBox(width: 8),
            Expanded(child: _shotTile('FT%', ftPct, rFtPct, ftMade, ftAtt, showTrend)),
          ]),
        ],
      ),
    );
  }

  Widget _tileStat(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: _tile,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _ink,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: _hint,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _shotTile(String label, double pct, double rPct, num made, num att, bool showTrend) {
    final delta = rPct - pct;
    Color fg, bg;
    Color? border;
    String tag;
    if (delta > 0.5) {
      fg = _green; bg = _greenBg; tag = '↑ +${delta.toStringAsFixed(1)}';
    } else if (delta < -0.5) {
      fg = _red; bg = _redBg; tag = '↓ ${delta.toStringAsFixed(1)}';
    } else {
      fg = _sub; bg = Colors.white; border = const Color(0xFFD9D9D9); tag = '±0';
    }
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: _tile,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: _hint,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${pct.toStringAsFixed(1)}%',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _ink,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$made / $att',
            style: const TextStyle(fontFamily: 'Inter', fontSize: 10, color: _hint),
          ),
          if (showTrend && att > 0) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(999),
                border: border == null ? null : Border.all(color: border, width: 1),
              ),
              child: Text(
                tag,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: fg,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
