import 'dart:convert';

import 'package:flutter/material.dart';

import '/backend/supabase/supabase.dart';

class PlayerInsightDebugPage extends StatefulWidget {
  const PlayerInsightDebugPage({super.key});

  @override
  State<PlayerInsightDebugPage> createState() => _PlayerInsightDebugPageState();
}

class _PlayerInsightDebugPageState extends State<PlayerInsightDebugPage> {
  List<Map<String, dynamic>> _players = [];
  bool _loading = true;
  String? _error;

  String? _invokingPlayerId;
  Map<String, dynamic>? _response;
  String? _invokeError;

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  Future<void> _loadPlayers() async {
    try {
      final rows = await SupaFlow.client
          .from('players')
          .select('id, first_name, last_name, birth_date, player_position')
          .order('first_name');
      setState(() {
        _players = List<Map<String, dynamic>>.from(rows);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _invoke(String playerId) async {
    setState(() {
      _invokingPlayerId = playerId;
      _response = null;
      _invokeError = null;
    });
    try {
      final res = await SupaFlow.client.functions.invoke(
        'generate-player-insight',
        body: {'player_id': playerId},
      );
      setState(() {
        _response = res.data is Map
            ? Map<String, dynamic>.from(res.data as Map)
            : {'raw': res.data};
      });
    } catch (e) {
      setState(() => _invokeError = e.toString());
    } finally {
      setState(() => _invokingPlayerId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Player insight (debug)')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const Text(
                      'Tap a player to invoke generate-player-insight.',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    ..._players.map((p) {
                      final id = p['id'] as String;
                      final busy = _invokingPlayerId == id;
                      return Card(
                        child: ListTile(
                          title: Text(
                            '${p['first_name'] ?? ''} ${p['last_name'] ?? ''}'
                                .trim(),
                          ),
                          subtitle: Text(
                            'birth: ${p['birth_date'] ?? '-'}   pos: ${p['player_position'] ?? '-'}',
                          ),
                          trailing: busy
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.play_arrow),
                          onTap: busy ? null : () => _invoke(id),
                        ),
                      );
                    }),
                    const SizedBox(height: 24),
                    if (_invokeError != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        color: Colors.red.withValues(alpha: 0.1),
                        child: SelectableText(
                          'Invoke error:\n$_invokeError',
                          style: const TextStyle(fontFamily: 'monospace'),
                        ),
                      ),
                    if (_response != null) _ResponseView(response: _response!),
                  ],
                ),
    );
  }
}

class _ResponseView extends StatelessWidget {
  const _ResponseView({required this.response});

  final Map<String, dynamic> response;

  @override
  Widget build(BuildContext context) {
    final insight = response['insight'];
    final insightMap =
        insight is Map ? Map<String, dynamic>.from(insight) : null;
    final cached = response['cached'] == true;
    final gamesUntilUnlock = response['games_until_unlock'];
    const encoder = JsonEncoder.withIndent('  ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Chip(label: Text(cached ? 'cached' : 'fresh')),
            const SizedBox(width: 8),
            if (gamesUntilUnlock != null)
              Chip(label: Text('unlock in $gamesUntilUnlock')),
          ],
        ),
        const SizedBox(height: 12),
        if (insightMap != null) ...[
          if (insightMap['headline'] != null)
            Text(
              insightMap['headline'] as String,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          const SizedBox(height: 8),
          if (insightMap['text'] != null)
            SelectableText(insightMap['text'] as String),
          const SizedBox(height: 12),
          if (insightMap['growth_edge'] != null)
            SelectableText(
              'Growth edge: ${insightMap['growth_edge']}',
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          const SizedBox(height: 16),
        ],
        const Text(
          'Raw response',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          color: Colors.black.withValues(alpha: 0.05),
          child: SelectableText(
            encoder.convert(response),
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
      ],
    );
  }
}
