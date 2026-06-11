import '/courtside_iq/design_tokens.dart';
import 'package:flutter/material.dart';

import '/backend/supabase/supabase.dart';
import '/courtside_iq/skeleton_widget.dart';
import '/custom_code/widgets/highlight_metric_tag_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'spark_icon.dart';

const _card = CIColors.surface;
const _cardBorder = CIColors.hairline;
const _ink = CIColors.ink;
const _sub = CIColors.ink3;
const _hint = CIColors.ink3;

class GamesTab extends StatefulWidget {
  const GamesTab({super.key, required this.playerId});

  final String playerId;

  @override
  State<GamesTab> createState() => _GamesTabState();
}

class _GamesTabState extends State<GamesTab> {
  List<Map<String, dynamic>>? _games;
  String? _error;
  String? _activeEvent; // null = All

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
            'points, off_reb, def_reb, assist, game_insights_json',
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
        padding: EdgeInsets.fromLTRB(16, 12, 16, 20),
        child: Column(
          children: [
            SkeletonBox(width: double.infinity, height: 92),
            SizedBox(height: 10),
            SkeletonBox(width: double.infinity, height: 92),
            SizedBox(height: 10),
            SkeletonBox(width: double.infinity, height: 92),
          ],
        ),
      );
    }
    if (_games!.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Text(
          'No games logged yet.',
          textAlign: TextAlign.center,
          style: TextStyle(color: _sub, fontFamily: CIType.fontFamily),
        ),
      );
    }

    // Distinct event names present in this player's games.
    final eventNames = _games!
        .map((g) => (g['event_name'] as String?)?.trim())
        .where((e) => e != null && e.isNotEmpty)
        .toSet()
        .cast<String>()
        .toList()
      ..sort();

    // Games visible after applying the active event filter.
    final visible = _activeEvent == null
        ? _games!
        : _games!
            .where((g) =>
                (g['event_name'] as String?)?.trim() == _activeEvent)
            .toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Event filter chips (only when 2+ distinct events) ──────
          if (eventNames.length >= 2) ...[
            _EventFilterChips(
              eventNames: eventNames,
              activeEvent: _activeEvent,
              onSelect: (e) => setState(() => _activeEvent = e),
            ),
            const SizedBox(height: 12),
          ],
          // ── Game cards ────────────────────────────────────────────
          if (visible.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text(
                  'No games for this event.',
                  style: const TextStyle(
                    fontFamily: CIType.fontFamily,
                    fontSize: 14,
                    color: _sub,
                  ),
                ),
              ),
            )
          else
            ...visible.map((g) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child:
                      _gameCard(g, () => _openGame(g['game_id']?.toString())),
                )),
          const SizedBox(height: 4),
          const Center(
            child: Text(
              '✦ marks games with an AI insight · tap a row for details',
              style: TextStyle(
                fontFamily: CIType.fontFamily,
                fontSize: 14,
                color: CIColors.ink2,
              ),
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
    final eventName = (g['event_name'] as String?)?.trim();
    final pts = ((g['points'] as num?) ?? 0).toInt();
    final reb = (((g['off_reb'] as num?) ?? 0) + ((g['def_reb'] as num?) ?? 0)).toInt();
    final ast = ((g['assist'] as num?) ?? 0).toInt();
    final insights = g['game_insights_json'];
    final highlightMetric = insights is Map
        ? insights['highlight_metric'] as String?
        : null;
    // Only consider an insight present if there is real text or a highlight metric.
    // A non-null but empty/incomplete jsonb object (e.g. {}) must not trigger the spark.
    final insightText = switch (insights) {
      final String s when s.isNotEmpty => s,
      final Map m when (m['text'] is String && (m['text'] as String).isNotEmpty) =>
        m['text'] as String,
      _ => null,
    };
    final hasInsight = insightText != null || highlightMetric != null;

    return Material(
      color: _card,
      borderRadius: BorderRadius.circular(CIRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(CIRadius.lg),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(CIRadius.lg),
            border: Border.all(color: _cardBorder, width: 1),
          ),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Column(
        children: [
          Row(
            children: [
              // Date stacked above opponent
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      date,
                      style: const TextStyle(
                        fontFamily: CIType.fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _ink,
                      ),
                    ),
                    if (opponent != null && opponent.isNotEmpty)
                      Text(
                        'vs $opponent',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: CIType.fontFamily,
                          fontSize: 12,
                          color: _sub,
                        ),
                      ),
                  ],
                ),
              ),
              // Badges: event first, then insight
              if (eventName != null && eventName.isNotEmpty) ...[
                _EventTag(label: eventName),
                const SizedBox(width: 6),
              ],
              if (highlightMetric != null)
                HighlightMetricTagWidget(highlightMetric: highlightMetric)
              else if (hasInsight)
                const SparkIcon(size: 14),
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
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: CIColors.canvas.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(CIRadius.lg),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontFamily: CIType.fontFamily,
              fontSize: 20,
              fontWeight: FontWeight.w400,
              fontFeatures: const [FontFeature.tabularFigures()],
              color: _ink,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontFamily: CIType.fontFamily,
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

// ── Event filter chip row ─────────────────────────────────────────────────────

class _EventFilterChips extends StatelessWidget {
  const _EventFilterChips({
    required this.eventNames,
    required this.activeEvent,
    required this.onSelect,
  });

  final List<String> eventNames;
  final String? activeEvent;
  final void Function(String?) onSelect;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _chip('All', activeEvent == null, () => onSelect(null)),
          ...eventNames.map(
            (e) => Padding(
              padding: const EdgeInsets.only(left: 8),
              child: _chip(e, activeEvent == e, () => onSelect(e)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: active ? _ink : Colors.transparent,
          borderRadius: BorderRadius.circular(CIRadius.xl),
          border: Border.all(
            color: active ? _ink : _cardBorder,
            width: 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontFamily: CIType.fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: active ? CIColors.inkOnBrand : _sub,
          ),
        ),
      ),
    );
  }
}

// ── Event badge ───────────────────────────────────────────────────────────────

class _EventTag extends StatelessWidget {
  const _EventTag({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: CIColors.canvas.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(CIRadius.md),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: CIType.fontFamily,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: CIColors.ink2,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
