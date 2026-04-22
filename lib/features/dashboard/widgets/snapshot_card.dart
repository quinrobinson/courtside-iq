import 'package:flutter/material.dart';

import '../../player_insight/models/player_insight.dart';
import 'dashboard_avatar.dart';

const _bg = Color(0xFF0F0F0F);
const _text = Color(0xFFFFFFFF);
const _sub = Color(0xFF9A9A9A);
const _divider = Color(0xFF2A2A2A);
const _border = Color(0xFF1A1A1A);

/// A single card in the Development Snapshots carousel.
///
/// Shows the player's avatar, name, and a one-paragraph snapshot of their
/// most recent development narrative. The card fills the full carousel height
/// so the lavender body always extends to the bottom edge.
class SnapshotCard extends StatelessWidget {
  const SnapshotCard({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.totalGames,
    this.profilePic,
    this.insight,
  });

  final String firstName;
  final String? lastName;
  final int totalGames;
  final String? profilePic;
  final PlayerInsight? insight;

  @override
  Widget build(BuildContext context) {
    final fullName = [firstName, lastName ?? '']
        .where((s) => s.isNotEmpty)
        .join(' ');
    final gameLabel = totalGames == 1 ? '1 game' : '$totalGames games';
    final body = _bodyText(insight);

    return Container(
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      // Column stretches to fill the carousel height.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                DashboardAvatar(
                  profilePic: profilePic,
                  size: 44,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _text,
                      ),
                    ),
                    Text(
                      'Last $gameLabel',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: _sub,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Hairline divider ──────────────────────────────────────────────
          const Divider(height: 22, thickness: 1, color: _divider),

          // ── Narrative body ────────────────────────────────────────────────
          if (body != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                body,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: _text,
                  height: 1.55,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                "Log more games to see $firstName's development story.",
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: _sub,
                  height: 1.55,
                ),
              ),
            ),
        ],
      ),
    );
  }

  static String? _bodyText(PlayerInsight? insight) {
    if (insight == null) return null;
    if (insight.whatsWorking != null &&
        insight.whatsWorking!.trim().isNotEmpty) {
      return insight.whatsWorking;
    }
    if (insight.text != null && insight.text!.trim().isNotEmpty) {
      return insight.text;
    }
    return null;
  }
}
