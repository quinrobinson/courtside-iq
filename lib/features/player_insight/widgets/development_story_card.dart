import 'package:flutter/material.dart';

import '../models/player_insight.dart';
import 'trend_pill.dart';

const _purple = Color(0xFF7936FF);
const _magenta = Color(0xFFD9005C);
const _text = Color(0xFF0F0F0F);
const _text2 = Color(0xFF8A8A8A);
const _border = Color(0xFFE6E6E6);
const _track = Color(0xFFF5F5F5);
const _skeleton = Color(0xFFE8E8E8);

class DevelopmentStoryCard extends StatelessWidget {
  const DevelopmentStoryCard.eligible({
    super.key,
    required PlayerInsight this.insight,
    required this.firstName,
  })  : gamesLogged = null,
        onRetry = null,
        _state = _CardState.eligible;

  const DevelopmentStoryCard.belowThreshold({
    super.key,
    required this.firstName,
    required int this.gamesLogged,
  })  : insight = null,
        onRetry = null,
        _state = _CardState.below;

  const DevelopmentStoryCard.loading({super.key})
      : insight = null,
        firstName = '',
        gamesLogged = null,
        onRetry = null,
        _state = _CardState.loading;

  const DevelopmentStoryCard.error({
    super.key,
    required this.firstName,
    required VoidCallback this.onRetry,
  })  : insight = null,
        gamesLogged = null,
        _state = _CardState.error;

  final PlayerInsight? insight;
  final String firstName;
  final int? gamesLogged;
  final VoidCallback? onRetry;
  final _CardState _state;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: switch (_state) {
        _CardState.eligible => _EligibleBody(insight: insight!),
        _CardState.below => _BelowBody(firstName: firstName, games: gamesLogged ?? 0),
        _CardState.loading => const _LoadingBody(),
        _CardState.error => _ErrorBody(firstName: firstName, onRetry: onRetry!),
      },
    );
  }
}

enum _CardState { eligible, below, loading, error }

class _EligibleBody extends StatelessWidget {
  const _EligibleBody({required this.insight});
  final PlayerInsight insight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TrendPill(direction: insight.trendDirection),
        const SizedBox(height: 14),
        if (insight.headline != null)
          Text(
            insight.headline!,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _text,
              height: 1.3,
            ),
          ),
        const SizedBox(height: 10),
        if (insight.text != null)
          Text(
            insight.text!,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: _text,
              height: 1.5,
            ),
          ),
        if (insight.growthEdge != null) ...[
          const SizedBox(height: 22),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 4, color: _purple),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'WATCH FOR NEXT',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _purple,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        insight.growthEdge!,
                        style: const TextStyle(
                          fontFamily: 'Inter',
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
          ),
        ],
      ],
    );
  }
}

class _BelowBody extends StatelessWidget {
  const _BelowBody({required this.firstName, required this.games});
  final String firstName;
  final int games;

  @override
  Widget build(BuildContext context) {
    final progress = (games / 5).clamp(0.0, 1.0);
    final remaining = (5 - games).clamp(0, 5);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: _purple.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Text(
            '✦ Unlocks at 5',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _purple,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          "$firstName's story is still being written",
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: _text,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "Development stories appear once a player has five logged games. Keep logging and $firstName's personalized insight will be ready soon.",
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: _text,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 22),
        Text(
          '$games of 5 games',
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _text2,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: _track,
            valueColor: const AlwaysStoppedAnimation(_purple),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          remaining == 1
              ? '1 more game to unlock'
              : '$remaining more games to unlock',
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            color: _text2,
          ),
        ),
      ],
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
            borderRadius: BorderRadius.circular(4),
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
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Text(
            "Couldn't load",
            style: TextStyle(
              fontFamily: 'Inter',
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
            fontFamily: 'Inter',
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
            fontFamily: 'Inter',
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
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              textStyle: const TextStyle(
                fontFamily: 'Inter',
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
