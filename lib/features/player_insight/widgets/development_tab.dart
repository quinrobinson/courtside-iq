import 'package:flutter/material.dart';

import '../data/player_insight_service.dart';
import '../models/player_insight.dart';
import 'about_story_sheet.dart';
import 'development_story_card.dart';

class DevelopmentTab extends StatefulWidget {
  const DevelopmentTab({
    super.key,
    required this.playerId,
    required this.firstName,
  });

  final String playerId;
  final String firstName;

  @override
  State<DevelopmentTab> createState() => _DevelopmentTabState();
}

class _DevelopmentTabState extends State<DevelopmentTab> {
  final _service = PlayerInsightService();

  // Rendered content. Sourced first from the client-side cache read, then
  // swapped in-place when the Edge Function returns fresher content.
  PlayerInsight? _insight;

  // Last server response — needed for gamesUntilUnlock on below-threshold.
  PlayerInsightResponse? _lastResponse;

  // True while we haven't yet resolved at least one source (cache or server).
  bool _initialLoading = true;

  // True when the Edge Function refresh failed but _insight is still set
  // from cache — renders the card without trend pill + shows retry chip.
  bool _refreshFailed = false;

  // Tracks whether the server call is in flight (for retry debounce).
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // Fire both reads in parallel so whichever resolves first gets rendered.
    final cacheFuture = _service.readCached(widget.playerId);
    _startRefresh();

    try {
      final cached = await cacheFuture;
      if (!mounted) return;
      if (cached != null && _insight == null) {
        // Server hasn't arrived yet — show cached instantly.
        setState(() {
          _insight = cached;
          _initialLoading = false;
        });
      }
    } catch (_) {
      // Cache read failure is non-fatal; the server call still covers us.
    }
  }

  Future<void> _startRefresh() async {
    if (_refreshing) return;
    _refreshing = true;
    try {
      final resp = await _service.fetch(widget.playerId);
      if (!mounted) return;
      setState(() {
        _insight = resp.insight;
        _lastResponse = resp;
        _initialLoading = false;
        _refreshFailed = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _initialLoading = false;
        // Only surface failure if we have cached content to keep rendering.
        // With no cache, the builder below will show the full error card.
        _refreshFailed = _insight != null;
      });
    } finally {
      _refreshing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: _buildChild(),
      ),
    );
  }

  Widget _buildChild() {
    // 1. Initial loading — no cache and no server response yet.
    if (_initialLoading) {
      return const KeyedSubtree(
        key: ValueKey('loading'),
        child: DevelopmentStoryCard.loading(),
      );
    }

    // 2. No insight at all after bootstrap → full error card.
    if (_insight == null) {
      return KeyedSubtree(
        key: const ValueKey('error'),
        child: DevelopmentStoryCard.error(
          firstName: widget.firstName,
          onRetry: () {
            setState(() {
              _initialLoading = true;
              _refreshFailed = false;
            });
            _startRefresh();
          },
        ),
      );
    }

    final insight = _insight!;

    // 3. Below-threshold. `gamesUntilUnlock` is only available from the
    //    server response (cache table never stores below-threshold rows).
    if (insight.belowThreshold) {
      final unlock = _lastResponse?.gamesUntilUnlock ?? 5;
      final logged = (5 - unlock).clamp(0, 5);
      return KeyedSubtree(
        key: const ValueKey('below'),
        child: DevelopmentStoryCard.belowThreshold(
          firstName: widget.firstName,
          gamesLogged: logged,
        ),
      );
    }

    // 4. Eligible — normal render, or degraded (no trend pill + retry chip)
    //    when we're showing stale cached content after a refresh failure.
    final key = ValueKey(
      'eligible:${insight.headline}:${_refreshFailed ? 'stale' : 'fresh'}',
    );
    return KeyedSubtree(
      key: key,
      child: Column(
        children: [
          DevelopmentStoryCard.eligible(
            insight: insight,
            firstName: widget.firstName,
            suppressTrendPill: _refreshFailed,
            onRetry: _refreshFailed ? _startRefresh : null,
          ),
          const SizedBox(height: 14),
          InkWell(
            onTap: () => AboutStorySheet.show(context),
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Based on ${widget.firstName}'s last 5 games",
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: Color(0xFF8A8A8A),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'ⓘ',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: Color(0xFF8A8A8A),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
