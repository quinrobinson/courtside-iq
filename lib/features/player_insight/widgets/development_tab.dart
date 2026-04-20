import 'package:flutter/material.dart';

import '../data/player_insight_service.dart';
import '../models/player_insight.dart';
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
  Future<PlayerInsightResponse>? _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _future = _service.fetch(widget.playerId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: FutureBuilder<PlayerInsightResponse>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const DevelopmentStoryCard.loading();
          }
          if (snap.hasError || snap.data == null) {
            return DevelopmentStoryCard.error(
              firstName: widget.firstName,
              onRetry: _load,
            );
          }
          final resp = snap.data!;
          if (resp.insight.belowThreshold) {
            final logged = 5 - (resp.gamesUntilUnlock ?? 5);
            return DevelopmentStoryCard.belowThreshold(
              firstName: widget.firstName,
              gamesLogged: logged.clamp(0, 5),
            );
          }
          return Column(
            children: [
              DevelopmentStoryCard.eligible(
                insight: resp.insight,
                firstName: widget.firstName,
              ),
              const SizedBox(height: 14),
              Text(
                "Based on ${widget.firstName}'s last 5 games",
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: Color(0xFF8A8A8A),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
