import '/courtside_iq/design_tokens.dart';
import 'package:flutter/material.dart';

import '/backend/supabase/database/tables/v_player_game_stats.dart';
import '/features/player_insight/widgets/spark_icon.dart';
import 'dashboard_avatar.dart';

const _text = CIColors.ink;
const _muted = CIColors.ink4;
const _sub = CIColors.ink3;
const _magenta = CIColors.rose500;
const _border = CIColors.hairline;
const _badgeBlueText = CIColors.ink2;

class GameFeedCard extends StatelessWidget {
  const GameFeedCard({super.key, required this.row, this.onTap});

  final VPlayerGameStatsRow row;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final firstName = row.firstName ?? '';
    final lastName = row.lastName ?? '';
    final fullName =
        [firstName, lastName].where((s) => s.isNotEmpty).join(' ');

    final pts = row.points ?? 0;
    final reb = (row.offReb ?? 0) + (row.defReb ?? 0);
    final ast = row.assist ?? 0;
    final blk = row.block ?? 0;
    final stl = row.steal ?? 0;
    final tov = row.turnover ?? 0;

    final dateStr =
        row.createdAt != null ? _fmtDate(row.createdAt!) : '';
    final opp = row.opponentTeam ?? '';
    final sub =
        opp.isNotEmpty ? '$dateStr · vs $opp' : dateStr;
    final event = row.eventName;
    final insight = row.gameInsights;

    return GestureDetector(
      onTap: onTap,
      child: Container(
      decoration: BoxDecoration(
        color: CIColors.surface,
        borderRadius: BorderRadius.circular(CIRadius.lg),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                DashboardAvatar(
                  profilePic: row.playerProfilePic,
                  size: 42,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName,
                        style: const TextStyle(
                          fontFamily: CIType.fontFamily,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: _text,
                        ),
                      ),
                      if (sub.isNotEmpty)
                        Text(
                          sub,
                          style: const TextStyle(
                            fontFamily: CIType.fontFamily,
                            fontSize: 12,
                            color: _sub,
                          ),
                        ),
                    ],
                  ),
                ),
                if (event != null && event.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  _EventBadge(label: event),
                ],
              ],
            ),
          ),

          // ── Stats ────────────────────────────────────────────────────────
          const Divider(height: 22, thickness: 1, color: _border),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: _StatGrid(
              pts: pts,
              reb: reb,
              ast: ast,
              blk: blk,
              stl: stl,
              tov: tov,
            ),
          ),

          // ── Insight ───────────────────────────────────────────────────────
          if (insight != null && insight.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SparkIcon(size: 12),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      insight,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: CIType.fontFamily,
                        fontSize: 13,
                        color: _text,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            const SizedBox(height: 12),
        ],
      ),
    ),
    );
  }

  static String _fmtDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}';
  }
}

// ── Event badge ────────────────────────────────────────────────────────────────

class _EventBadge extends StatelessWidget {
  const _EventBadge({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: CIColors.canvas.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(CIRadius.sm),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: CIType.fontFamily,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: _badgeBlueText,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

// ── Stat grid ─────────────────────────────────────────────────────────────────

class _StatGrid extends StatelessWidget {
  const _StatGrid({
    required this.pts,
    required this.reb,
    required this.ast,
    required this.blk,
    required this.stl,
    required this.tov,
  });

  final int pts, reb, ast, blk, stl, tov;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Tile(value: pts, label: 'PTS'),
        _Tile(value: reb, label: 'REB'),
        _Tile(value: ast, label: 'AST'),
        _Tile(value: blk, label: 'BLK'),
        _Tile(value: stl, label: 'STL'),
        _Tile(value: tov, label: 'TOV', isTov: true),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.value,
    required this.label,
    this.isTov = false,
  });

  final int value;
  final String label;
  final bool isTov;

  @override
  Widget build(BuildContext context) {
    final isZero = value == 0;
    final Color valueColor;
    if (isZero) {
      valueColor = _muted;
    } else if (isTov) {
      valueColor = _magenta;
    } else {
      valueColor = _text;
    }

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: CIColors.surface,
          borderRadius: BorderRadius.circular(CIRadius.lg),
        ),
        child: Column(
          children: [
            Text(
              '$value',
              style: TextStyle(
                fontFamily: CIType.fontFamily,
                fontSize: 20,
                fontWeight: FontWeight.w400,
                fontFeatures: const [FontFeature.tabularFigures()],
                color: valueColor,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(
                fontFamily: CIType.fontFamily,
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: _sub,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
