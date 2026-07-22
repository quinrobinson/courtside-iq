// The insight card and its two other states — Phase 4.14
//
// Measured from 145:610 (delivered), 424:1904 (loading) and 425:1909 (error).
//
// THE GROUND CARRIES THE STATE, and this is the detail worth not losing:
// delivered and loading are limeWash, error is plain grey. The lime is
// reserved for an insight that arrived or is arriving. Painting the failure
// lime too would make the one case where the app has nothing to say look
// exactly like the case where it does.
//
// WHY THESE STATES EXIST AT ALL. The Game Complete screen promises "Save to
// unlock Maya's game insight". Generation is fired after the rows upload and
// its failures are swallowed, so before this the promise could simply never
// be kept - no insight, no explanation, no way to ask again. Loading and
// error are how that promise gets honoured or, failing that, retried.

import 'package:flutter/material.dart';

import '/courtside_iq/design/components/ci_button.dart';
import '/courtside_iq/design/components/ci_spark.dart';
import '/courtside_iq/design/tokens/ci_colors.dart';
import '/courtside_iq/design/tokens/ci_metrics.dart';
import '/courtside_iq/design/tokens/ci_type.dart';

enum InsightState { ready, loading, error }

class GameInsightCard extends StatelessWidget {
  const GameInsightCard({
    super.key,
    required this.state,
    required this.playerName,
    this.text,
    this.label,
    this.onAbout,
    this.onRetry,
  });

  final InsightState state;
  final String playerName;

  /// The insight itself, when [state] is ready.
  final String? text;

  /// "SCORING EFFICIENCY · ELITE". Absent on legacy rows that stored no
  /// metric, which is not a reason to hide the insight - the text is the
  /// value and this is a label for it.
  final String? label;

  final VoidCallback? onAbout;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    final ground =
        state == InsightState.error ? c.surfaceSunk : c.accentGoodWash;

    return Container(
      width: double.infinity,
      color: ground,
      padding: const EdgeInsets.fromLTRB(
          CiSpace.screen, CiSpace.s5, CiSpace.screen, CiSpace.s5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CiSpark(size: 16, color: c.text),
              const SizedBox(width: CiSpace.s2),
              Flexible(
                child: Text('Courtside IQ',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: CiType.caption.copyWith(color: c.textMuted)),
              ),
              const Spacer(),
              if (label != null) ...[
                const SizedBox(width: CiSpace.s3),
                // FLEXIBLE, not a Spacer plus fixed text. "SCORING EFFICIENCY
                // · ELITE" is the longest eyebrow the app can produce and it
                // overflowed the row beside the wordmark. It ellipsises
                // rather than wrapping: this is a label for the paragraph
                // below, and two lines of it would compete with the insight
                // it is labelling.
                Flexible(
                  child: Text(label!,
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CiType.micro.copyWith(
                          color: c.textMuted,
                          fontWeight: CiWeight.semiBold,
                          letterSpacing: 0.4)),
                ),
              ],
            ],
          ),
          const SizedBox(height: CiSpace.s3),
          switch (state) {
            InsightState.ready => _Ready(text: text ?? '', onAbout: onAbout),
            InsightState.loading => _Loading(playerName: playerName),
            InsightState.error => _Error(onRetry: onRetry),
          },
        ],
      ),
    );
  }
}

class _Ready extends StatelessWidget {
  const _Ready({required this.text, this.onAbout});

  final String text;
  final VoidCallback? onAbout;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(text, style: CiType.body.copyWith(color: c.text, height: 1.5)),
        if (onAbout != null) ...[
          const SizedBox(height: CiSpace.s4),
          InkWell(
            onTap: onAbout,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.info_outline, size: 15, color: c.textMuted),
                const SizedBox(width: 6),
                Text('About insights',
                    style: CiType.caption.copyWith(color: c.textMuted)),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Named skeleton lines, because the wait is for THIS child's game.
///
/// "Reading Maya's game..." is doing work a spinner cannot: it says what is
/// being waited on, and it is the only moment in the app where the parent is
/// waiting on the model rather than the network.
class _Loading extends StatelessWidget {
  const _Loading({required this.playerName});

  final String playerName;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    final who = playerName.trim().isEmpty ? 'this' : "${playerName.trim()}'s";
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Reading $who game...',
            style: CiType.h4.copyWith(color: c.text)),
        const SizedBox(height: CiSpace.s4),
        // Widths taper, so the block reads as a paragraph rather than a
        // loading bar that stalled.
        for (final w in const [1.0, 0.86, 0.62]) ...[
          FractionallySizedBox(
            widthFactor: w,
            child: Container(
              height: 10,
              decoration: BoxDecoration(
                // A shade of the ground, not grey: the card is already lime
                // and a grey skeleton on it reads as a rendering fault.
                color: c.accentGood.withValues(alpha: 0.28),
                borderRadius: CiRadius.chipR,
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _Error extends StatelessWidget {
  const _Error({this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.error_outline, size: 18, color: c.accentEnergy),
            const SizedBox(width: CiSpace.s2),
            Expanded(
              child: Text("We couldn't generate this insight",
                  style: CiType.h4.copyWith(color: c.text)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        // Leads with what is SAFE. The game is the thing a parent would fear
        // for, and it was never at risk.
        Text("Check your connection. We'll keep your game saved.",
            style: CiType.bodySm.copyWith(color: c.textMuted)),
        const SizedBox(height: CiSpace.s4),
        CiButton(
          label: 'Try again',
          style: CiButtonStyle.secondary,
          size: CiButtonSize.sm,
          onPressed: onRetry,
        ),
      ],
    );
  }
}
