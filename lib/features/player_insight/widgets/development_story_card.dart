import '/courtside_iq/design_tokens.dart';
import 'package:flutter/material.dart';

import '../models/player_insight.dart';
import 'trend_pill.dart';

const _purple = CIColors.royal500;
const _amber = CIColors.spark500;
const _magenta = CIColors.rose500;
const _green = CIColors.jade500;
const _text = CIColors.ink;
const _text2 = CIColors.ink3;
const _border = CIColors.hairline;
const _track = CIColors.surfaceAlt;
const _skeleton = CIColors.canvasSunk;

class DevelopmentStoryCard extends StatelessWidget {
  const DevelopmentStoryCard.eligible({
    super.key,
    required PlayerInsight this.insight,
    required this.firstName,
    this.suppressTrendPill = false,
    this.onRetry,
  })  : gamesLogged = null,
        _state = _CardState.eligible;

  const DevelopmentStoryCard.belowThreshold({
    super.key,
    required this.firstName,
    required int this.gamesLogged,
  })  : insight = null,
        onRetry = null,
        suppressTrendPill = false,
        _state = _CardState.below;

  const DevelopmentStoryCard.loading({super.key})
      : insight = null,
        firstName = '',
        gamesLogged = null,
        onRetry = null,
        suppressTrendPill = false,
        _state = _CardState.loading;

  const DevelopmentStoryCard.error({
    super.key,
    required this.firstName,
    required VoidCallback this.onRetry,
  })  : insight = null,
        gamesLogged = null,
        suppressTrendPill = false,
        _state = _CardState.error;

  final PlayerInsight? insight;
  final String firstName;
  final int? gamesLogged;
  final VoidCallback? onRetry;
  final bool suppressTrendPill;
  final _CardState _state;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CIColors.surface,
        borderRadius: BorderRadius.circular(CIRadius.lg),
        border: Border.all(color: _border),
        boxShadow: CIElevation.card,
      ),
      padding: const EdgeInsets.all(20),
      child: switch (_state) {
        _CardState.eligible => _EligibleBody(
            insight: insight!,
            suppressTrendPill: suppressTrendPill,
            onRetry: onRetry,
          ),
        _CardState.below => _BelowBody(firstName: firstName, games: gamesLogged ?? 0),
        _CardState.loading => const _LoadingBody(),
        _CardState.error => _ErrorBody(firstName: firstName, onRetry: onRetry!),
      },
    );
  }
}

enum _CardState { eligible, below, loading, error }

class _EligibleBody extends StatelessWidget {
  const _EligibleBody({
    required this.insight,
    this.suppressTrendPill = false,
    this.onRetry,
  });
  final PlayerInsight insight;
  final bool suppressTrendPill;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final hasSplit = insight.hasSplitNarrative;
    final legacyText = insight.text;
    final showLegacy = !hasSplit && legacyText != null && legacyText.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!suppressTrendPill) ...[
          TrendPill(direction: insight.trendDirection),
          const SizedBox(height: 14),
        ],
        if (insight.headline != null)
          Text(
            insight.headline!,
            style: const TextStyle(
              fontFamily: CIType.fontFamily,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _text,
              height: 1.3,
            ),
          ),
        if (showLegacy) ...[
          const SizedBox(height: 10),
          Text(
            legacyText,
            style: const TextStyle(
              fontFamily: CIType.fontFamily,
              fontSize: 14,
              color: _text,
              height: 1.5,
            ),
          ),
        ],
        if (insight.whatsWorking != null &&
            insight.whatsWorking!.trim().isNotEmpty) ...[
          const SizedBox(height: 22),
          _AccentSection(
            color: _green,
            label: 'BRIGHT SPOTS',
            body: insight.whatsWorking!,
          ),
        ],
        if (insight.needsDevelopment != null &&
            insight.needsDevelopment!.trim().isNotEmpty) ...[
          const SizedBox(height: 18),
          _AccentSection(
            color: _magenta,
            label: 'ROOM TO GROW',
            body: insight.needsDevelopment!,
          ),
        ],
        if (insight.growthEdge != null) ...[
          const SizedBox(height: 18),
          _AccentSection(
            color: _purple,
            label: 'WATCH FOR NEXT',
            body: insight.growthEdge!,
          ),
        ],
        if (onRetry != null) ...[
          const SizedBox(height: 22),
          _RetryChip(onTap: onRetry!),
        ],
      ],
    );
  }
}

class _AccentSection extends StatelessWidget {
  const _AccentSection({
    required this.color,
    required this.label,
    required this.body,
  });

  final Color color;
  final String label;
  final String body;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 2,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(CIRadius.xs),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: CIType.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: color,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: const TextStyle(
                    fontFamily: CIType.fontFamily,
                    fontSize: 13,
                    color: _text,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RetryChip extends StatelessWidget {
  const _RetryChip({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(CIRadius.md),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _track,
              borderRadius: BorderRadius.circular(CIRadius.md),
              border: Border.all(color: _border),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '↻',
                  style: TextStyle(
                    fontFamily: CIType.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _text2,
                  ),
                ),
                SizedBox(width: 6),
                Text(
                  "Couldn't refresh · tap to retry",
                  style: TextStyle(
                    fontFamily: CIType.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _text2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BelowBody extends StatelessWidget {
  const _BelowBody({required this.firstName, required this.games});
  final String firstName;
  final int games;

  @override
  Widget build(BuildContext context) {
    final remaining = (5 - games).clamp(0, 5);
    final chipLabel = remaining == 1 ? '✦ 1 to go' : '✦ $remaining to go';
    final headline = remaining == 1
        ? "One more for $firstName's first story"
        : "$firstName's story is taking shape";
    final body = remaining == 1
        ? "You'll see where $firstName is shining, where there's room to grow, and what to watch for next."
        : "Every game you log sharpens what we can see in $firstName's development.";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: _amber.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(CIRadius.md),
          ),
          child: Text(
            chipLabel,
            style: const TextStyle(
              fontFamily: CIType.fontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _amber,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          headline,
          style: const TextStyle(
            fontFamily: CIType.fontFamily,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: _text,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          body,
          style: const TextStyle(
            fontFamily: CIType.fontFamily,
            fontSize: 14,
            color: _text,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        _DotProgress(filled: games, total: 5),
        const SizedBox(height: 8),
        Text(
          '$games of 5 games logged',
          style: const TextStyle(
            fontFamily: CIType.fontFamily,
            fontSize: 12,
            color: _text2,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Unlocks bright spots, room to grow, and what to watch for next',
          style: TextStyle(
            fontFamily: CIType.fontFamily,
            fontSize: 12,
            color: _text2.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}

class _DotProgress extends StatelessWidget {
  const _DotProgress({required this.filled, required this.total});
  final int filled;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (i) {
        final isFilled = i < filled;
        return Padding(
          padding: EdgeInsets.only(right: i < total - 1 ? 8 : 0),
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isFilled ? _amber : Colors.transparent,
              border: Border.all(
                color: isFilled ? _amber : CIColors.hairline,
                width: 1.5,
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _LoadingBody extends StatelessWidget {
  const _LoadingBody();

  @override
  Widget build(BuildContext context) {
    Widget bar(double width, double height) => Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: _skeleton,
            borderRadius: BorderRadius.circular(CIRadius.sm),
          ),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        bar(98, 26),
        const SizedBox(height: 18),
        bar(double.infinity, 16),
        const SizedBox(height: 8),
        bar(180, 16),
        const SizedBox(height: 16),
        bar(double.infinity, 10),
        const SizedBox(height: 8),
        bar(double.infinity, 10),
        const SizedBox(height: 8),
        bar(double.infinity, 10),
        const SizedBox(height: 8),
        bar(220, 10),
      ],
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.firstName, required this.onRetry});
  final String firstName;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: _magenta.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(CIRadius.md),
          ),
          child: const Text(
            "Couldn't load",
            style: TextStyle(
              fontFamily: CIType.fontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _magenta,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          "We couldn't generate $firstName's story",
          style: const TextStyle(
            fontFamily: CIType.fontFamily,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: _text,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Something went wrong reaching the insight service. Your data is safe. Try again in a moment.',
          style: TextStyle(
            fontFamily: CIType.fontFamily,
            fontSize: 14,
            color: _text,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 22),
        SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: _text,
              foregroundColor: CIColors.inkOnBrand,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              textStyle: const TextStyle(
                fontFamily: CIType.fontFamily,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: const Text('Try again'),
          ),
        ),
      ],
    );
  }
}
