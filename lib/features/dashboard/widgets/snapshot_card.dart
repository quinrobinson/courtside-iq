import '/courtside_iq/design_tokens.dart';
import 'package:flutter/material.dart';

import '../../player_insight/models/player_insight.dart';
import 'dashboard_avatar.dart';

// Tier 3 · Surface card colors — white surface with royal burst accent
const _textPrimary   = CIColors.ink;
const _textSecondary = CIColors.ink3;
const _dividerColor  = CIColors.hairline;

/// A single card in the Development Snapshots carousel.
///
/// White surface with a royal radial burst from the bottom-right corner,
/// hairline border, and standard card elevation.
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
        color: CIColors.surface,
        borderRadius: BorderRadius.circular(CIRadius.lg),
        border: Border.all(color: CIColors.hairline, width: 1.0),
        boxShadow: CIElevation.card,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // ── Royal radial burst — bottom-right corner ────────────────
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 200,
              height: 150,
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.bottomRight,
                  radius: 1.0,
                  colors: [
                    Color(0x386B35C9), // royal500 @ 22%
                    Color(0x006B35C9), // royal500 @ 0%
                  ],
                  stops: [0.0, 1.0],
                ),
              ),
            ),
          ),

          // ── Card content ────────────────────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ────────────────────────────────────────────
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
                            fontFamily: CIType.fontFamily,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: _textPrimary,
                          ),
                        ),
                        Text(
                          'Last $gameLabel',
                          style: const TextStyle(
                            fontFamily: CIType.fontFamily,
                            fontSize: 12,
                            color: _textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Hairline divider ────────────────────────────────────
              const Divider(height: 22, thickness: 1, color: _dividerColor),

              // ── Narrative body ──────────────────────────────────────
              if (body != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text(
                    body,
                    style: const TextStyle(
                      fontFamily: CIType.fontFamily,
                      fontSize: 13,
                      color: _textPrimary,
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
                      fontFamily: CIType.fontFamily,
                      fontSize: 13,
                      color: _textSecondary,
                      height: 1.55,
                    ),
                  ),
                ),
            ],
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
