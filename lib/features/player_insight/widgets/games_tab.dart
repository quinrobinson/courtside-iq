import 'package:flutter/material.dart';

import '/backend/supabase/supabase.dart';
import '/custom_code/widgets/highlight_metric_tag_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'spark_icon.dart';

const _card = Colors.white;
const _cardBorder = Color(0xFFE2E0DF);
const _tile = Color(0xFFF3F3F3);
const _ink = Color(0xFF0F0F0F);
const _sub = Color(0xFF6A6A6A);
const _hint = Color(0xFF8E8E8E);
const _purple = Color(0xFF7936FF);

class GamesTab extends StatefulWidget {
  const GamesTab({super.key, required this.playerId});

  final String playerId;

  @override
  State<GamesTab> createState() => _GamesTabState();
}

class _GamesTabState extends State<GamesTab> {
  List<Map<String, dynamic>>? _games;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final rows = await SupaFlow.client
          .from('v_player_game_stats')
          .select(
            'game_id, created_at, opponent_team, player_team_name, event_name, '
            'points, off_reb, def_reb, assist, game_insights',
          )
          .eq('player_id', widget.playerId)
          .order('created_at', ascending: false);
      if (!mounted) return;
      setState(() => _games = List<Map<String, dynamic>>.from(rows));
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
        child: Text('Error loading games: $_error',
            style: const TextStyle(color: _sub)),
      );
    }
    if (_games == null) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_games!.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Text(
          'No games logged yet.',
          textAlign: TextAlign.center,
          style: TextStyle(color: _sub, fontFamily: 'Inter'),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...(_games!.map((g) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _gameCard(g, () => _openGame(g['game_id']?.toString())),
              ))),
          const SizedBox(height: 4),
          const Center(
            child: Text(
              '✦ marks games with an AI insight · tap a row for details',
              style: TextStyle(fontFamily: 'Inter', fontSize: 10, color: _hint),
            ),
          ),
        ],
      ),
    );
  }

  void _openGame(String? gameId) {
    if (gameId == null || gameId.isEmpty) return;
    context.pushNamed(
      GameStatsWidget.routeName,
      queryParameters: {
        'playerID': serializeParam(widget.playerId, ParamType.String),
        'gameID': serializeParam(gameId, ParamType.String),
      }.withoutNulls,
    );
  }

  Widget _gameCard(Map<String, dynamic> g, VoidCallback onTap) {
    final created = DateTime.tryParse(g['created_at']?.toString() ?? '');
    final date = created != null ? _fmtDate(created) : '—';
    final opponent = (g['opponent_team'] as String?)?.trim();
    final opp = (opponent == null || opponent.isEmpty) ? 'Opponent' : 'vs $opponent';
    final pts = ((g['points'] as num?) ?? 0).toInt();
    final reb = (((g['off_reb'] as num?) ?? 0) + ((g['def_reb'] as num?) ?? 0)).toInt();
    final ast = ((g['assist'] as num?) ?? 0).toInt();
    final insights = g['game_insights'];
    final highlightMetric = insights is Map
        ? insights['highlight_metric'] as String?
        : null;
    final hasInsight = insights != null;

    return Material(
      color: _card,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _cardBorder, width: 1),
          ),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      date,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _ink,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        opp,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: _sub,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (highlightMetric != null)
                HighlightMetricTagWidget(highlightMetric: highlightMetric)
              else if (hasInsight)
                const SparkIcon(size: 14, color: _purple),
            ],
          ),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _statTile('$pts', 'PTS')),
            const SizedBox(width: 8),
            Expanded(child: _statTile('$reb', 'REB')),
            const SizedBox(width: 8),
            Expanded(child: _statTile('$ast', 'AST')),
          ]),
        ],
          ),
        ),
      ),
    );
  }

  Widget _statTile(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
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

  String _fmtDate(DateTime d) {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }
}
