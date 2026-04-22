import 'package:flutter/material.dart';

import '../../player_insight/models/player_insight.dart';
import 'dashboard_avatar.dart';

const _text = Color(0xFF0F0F0F);
const _sub = Color(0xFF8A8A8A);
const _purple = Color(0xFF7936FF);
const _border = Color(0xFFE3E1E0);

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
    required this.initials,
    required this.totalGames,
    this.profilePic,
    this.insight,
  });

  final String firstName;
  final String? lastName;
  final String initials;
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      // Column fills the full carousel height so the lavender body
      // extends flush to the bottom of the card.
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
                  initials: initials,
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

          // Small gap between avatar and lavender body
          const SizedBox(height: 12),

          // ── Narrative body — expands to fill remaining card height ────────
          Expanded(
            child: body != null
                ? Container(
                    decoration: BoxDecoration(
                      color: _purple.withValues(alpha: 0.06),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
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
                : Padding(
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
