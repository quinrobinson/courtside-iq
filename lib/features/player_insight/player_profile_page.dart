import 'package:flutter/material.dart';

import '/backend/supabase/supabase.dart';
import 'widgets/averages_tab.dart';
import 'widgets/development_tab.dart';
import 'widgets/games_tab.dart';

const _bg = Color(0xFFF0F0F0);
const _text = Color(0xFF0F0F0F);
const _text2 = Color(0xFF8A8A8A);
const _card = Colors.white;
const _track = Color(0xFFF5F5F5);
const _pillInk = Color(0xFF1A1A1A);

class PlayerProfilePageV2 extends StatefulWidget {
  const PlayerProfilePageV2({super.key, required this.playerId});

  final String playerId;

  @override
  State<PlayerProfilePageV2> createState() => _PlayerProfilePageV2State();
}

class _PlayerProfilePageV2State extends State<PlayerProfilePageV2> {
  Map<String, dynamic>? _player;
  String? _error;
  int _tabIndex = 0;
  int? _gamesCount;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final row = await SupaFlow.client
          .from('player_profile_view')
          .select(
            'player_id, player_first_name, player_position, player_profile_pic, age_band, total_games',
          )
          .eq('player_id', widget.playerId)
          .maybeSingle();
      if (!mounted) return;
      setState(() {
        _player = row == null ? null : Map<String, dynamic>.from(row);
        _gamesCount = (_player?['total_games'] as num?)?.toInt();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final firstName =
        (_player?['player_first_name'] as String?) ?? 'Player';
    return Scaffold(
      backgroundColor: _bg,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: _text,
        centerTitle: true,
        title: _player == null
            ? null
            : Text(
                firstName,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _text,
                ),
              ),
      ),
      body: _error != null
          ? Center(child: Text('Error: $_error'))
          : _player == null
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                  children: [
                    const _TopGradient(),
                    _buildBody(_player!),
                  ],
                ),
    );
  }

  Widget _buildBody(Map<String, dynamic> p) {
    final firstName = (p['player_first_name'] ?? 'Player') as String;
    final position = p['player_position'] as String?;
    final ageBand = p['age_band'] as String?;
    final pic = p['player_profile_pic'] as String?;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(top: kToolbarHeight + MediaQuery.of(context).padding.top),
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (position != null) ...[
                const SizedBox(height: 4),
                Text(
                  position,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: _text2,
                  ),
                ),
              ],
              if (ageBand != null) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: _pillInk,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    ageBand,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              CircleAvatar(
                radius: 44,
                backgroundColor: const Color(0xFFDCDCDC),
                backgroundImage: (pic != null && pic.isNotEmpty)
                    ? NetworkImage(pic)
                    : null,
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _TabControl(
                  index: _tabIndex,
                  gamesCount: _gamesCount,
                  onChanged: (i) => setState(() => _tabIndex = i),
                ),
              ),
              const SizedBox(height: 4),
              _tabContent(firstName),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tabContent(String firstName) {
    switch (_tabIndex) {
      case 0:
        return DevelopmentTab(
          playerId: widget.playerId,
          firstName: firstName,
        );
      case 1:
        return AveragesTab(playerId: widget.playerId);
      case 2:
        return GamesTab(playerId: widget.playerId);
      default:
        return const SizedBox.shrink();
    }
  }
}

class _TabControl extends StatelessWidget {
  const _TabControl({
    required this.index,
    required this.onChanged,
    this.gamesCount,
  });

  final int index;
  final ValueChanged<int> onChanged;
  final int? gamesCount;

  @override
  Widget build(BuildContext context) {
    final labels = <String>[
      'Development',
      'Averages',
      gamesCount != null ? 'Games ($gamesCount)' : 'Games',
    ];
    return LayoutBuilder(
      builder: (context, c) {
        final trackW = c.maxWidth;
        final tabW = (trackW - 8) / 3;
        return SizedBox(
          height: 44,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: _track,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                left: 4 + index * tabW,
                top: 4,
                width: tabW,
                height: 36,
                child: Container(
                  decoration: BoxDecoration(
                    color: _card,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: List.generate(labels.length, (i) {
                  final active = i == index;
                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onChanged(i),
                      child: Center(
                        child: Text(
                          labels[i],
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight:
                                active ? FontWeight.w600 : FontWeight.w500,
                            color: active ? _text : _text2,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TopGradient extends StatelessWidget {
  const _TopGradient();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        height: 360,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/profile_v2_gradient.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
            // Fade to page bg at the bottom so the gradient blends cleanly
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _bg.withValues(alpha: 0),
                    _bg.withValues(alpha: 0),
                    _bg,
                  ],
                  stops: const [0.0, 0.75, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
