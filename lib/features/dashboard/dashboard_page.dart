import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/pages/global/custom_nav_bar/custom_nav_bar_widget.dart';
import '../player_insight/models/player_insight.dart';
import 'widgets/snapshot_card.dart';
import 'widgets/game_feed_card.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Feature flag — set to false to revert to the FF-generated HomeWidget.
// ─────────────────────────────────────────────────────────────────────────────
const bool kUseDashboardV2 = true;

// ─────────────────────────────────────────────────────────────────────────────
// Data models
// ─────────────────────────────────────────────────────────────────────────────

class _PlayerSnapshot {
  const _PlayerSnapshot({
    required this.playerId,
    required this.firstName,
    this.lastName,
    this.profilePic,
    required this.totalGames,
    this.insight,
  });

  final String playerId;
  final String firstName;
  final String? lastName;
  final String? profilePic;
  final int totalGames;
  final PlayerInsight? insight;

  String get initials =>
      '${firstName.isNotEmpty ? firstName[0] : ''}${lastName != null && lastName!.isNotEmpty ? lastName![0] : ''}'
          .toUpperCase();
}

class _DashboardData {
  const _DashboardData({
    required this.displayName,
    required this.playerCount,
    required this.totalGames,
    required this.snapshots,
    required this.recentGames,
  });

  final String displayName;
  final int playerCount;
  final int totalGames;
  final List<_PlayerSnapshot> snapshots;
  final List<VPlayerGameStatsRow> recentGames;

  /// Only snapshots with a real (above-threshold) insight.
  List<_PlayerSnapshot> get eligibleSnapshots =>
      snapshots.where((s) => s.insight != null && !s.insight!.belowThreshold).toList();
}

// ─────────────────────────────────────────────────────────────────────────────
// Page
// ─────────────────────────────────────────────────────────────────────────────

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late Future<_DashboardData> _dataFuture;
  int _snapshotIndex = 0;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadData();
  }

  Future<_DashboardData> _loadData() async {
    final uid = currentUserUid;
    if (uid.isEmpty) {
      return const _DashboardData(
        displayName: '',
        playerCount: 0,
        totalGames: 0,
        snapshots: [],
        recentGames: [],
      );
    }

    // ── 1. Players + totals ────────────────────────────────────────────────
    final profileRows = await SupaFlow.client
        .from('player_profile_view')
        .select(
          'player_id, player_first_name, player_last_name, player_profile_pic, total_games',
        )
        .eq('user_id', uid);

    final playerCount = (profileRows as List).length;
    final totalGames = profileRows.fold<int>(
      0,
      (sum, r) => sum + ((r['total_games'] as int?) ?? 0),
    );

    // ── 2. Cached development insights (batch) ────────────────────────────
    final playerIds = profileRows
        .map<String>((r) => r['player_id'] as String? ?? '')
        .where((id) => id.isNotEmpty)
        .toList();

    final Map<String, PlayerInsight> insightMap = {};
    if (playerIds.isNotEmpty) {
      final insightRows = await SupaFlow.client
          .from('player_development_insights')
          .select('player_id, insight_json')
          .inFilter('player_id', playerIds)
          .order('created_at', ascending: false);

      for (final r in (insightRows as List)) {
        final pid = r['player_id'] as String?;
        if (pid == null || insightMap.containsKey(pid)) continue;
        final raw = r['insight_json'];
        if (raw is Map) {
          try {
            insightMap[pid] =
                PlayerInsight.fromJson(Map<String, dynamic>.from(raw));
          } catch (_) {}
        }
      }
    }

    // ── 3. Build snapshots list ────────────────────────────────────────────
    final snapshots = profileRows.map<_PlayerSnapshot>((r) {
      final pid = r['player_id'] as String? ?? '';
      return _PlayerSnapshot(
        playerId: pid,
        firstName: r['player_first_name'] as String? ?? '',
        lastName: r['player_last_name'] as String?,
        profilePic: r['player_profile_pic'] as String?,
        totalGames: (r['total_games'] as int?) ?? 0,
        insight: insightMap[pid],
      );
    }).toList();

    // Sort: players with insights first, then by most games
    snapshots.sort((a, b) {
      final aHas = a.insight != null && !a.insight!.belowThreshold ? 0 : 1;
      final bHas = b.insight != null && !b.insight!.belowThreshold ? 0 : 1;
      if (aHas != bHas) return aHas.compareTo(bHas);
      return b.totalGames.compareTo(a.totalGames);
    });

    // ── 4. Recent games ────────────────────────────────────────────────────
    final gameRows = await SupaFlow.client
        .from('v_player_game_stats')
        .select()
        .eq('user_id', uid)
        .order('created_at', ascending: false)
        .limit(5);

    final recentGames = (gameRows as List)
        .map((r) => VPlayerGameStatsRow(Map<String, dynamic>.from(r)))
        .toList();

    // ── 5. Display name ────────────────────────────────────────────────────
    final nameParts = currentUserDisplayName.trim().split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts.first : '';

    return _DashboardData(
      displayName: firstName,
      playerCount: playerCount,
      totalGames: totalGames,
      snapshots: snapshots,
      recentGames: recentGames,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F0F0),
        body: FutureBuilder<_DashboardData>(
          future: _dataFuture,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const _LoadingState();
            }
            if (snap.hasError || !snap.hasData) {
              return _ErrorState(onRetry: () {
                setState(() => _dataFuture = _loadData());
              });
            }
            return _Body(
              data: snap.data!,
              snapshotIndex: _snapshotIndex,
              onSnapshotIndexChanged: (i) =>
                  setState(() => _snapshotIndex = i),
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Body — Stack: scroll content + fixed nav bar
// ─────────────────────────────────────────────────────────────────────────────

class _Body extends StatelessWidget {
  const _Body({
    required this.data,
    required this.snapshotIndex,
    required this.onSnapshotIndexChanged,
  });

  final _DashboardData data;
  final int snapshotIndex;
  final ValueChanged<int> onSnapshotIndexChanged;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final eligible = data.eligibleSnapshots;

    return Stack(
      children: [
        // ── Scroll content ─────────────────────────────────────────────
        CustomScrollView(
          slivers: [
            // ── Gradient hero: greeting + snapshots ───────────────────
            SliverToBoxAdapter(
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image:
                        AssetImage('assets/images/Profile_Gradient.png'),
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(20, top + 24, 20, 0),
                      child: _Greeting(
                        displayName: data.displayName,
                        playerCount: data.playerCount,
                        totalGames: data.totalGames,
                      ),
                    ),
                    if (eligible.isNotEmpty) ...[
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(20, 24, 20, 12),
                        child: _SectionHeader(
                          label: 'DEVELOPMENT SNAPSHOTS',
                          count: eligible.length,
                          currentIndex: snapshotIndex,
                        ),
                      ),
                      _SnapshotCarousel(
                        snapshots: eligible,
                        currentIndex: snapshotIndex,
                        onIndexChanged: onSnapshotIndexChanged,
                      ),
                      const SizedBox(height: 28),
                    ] else
                      const SizedBox(height: 28),
                  ],
                ),
              ),
            ),

            // ── Recent Games ───────────────────────────────────────────
            if (data.recentGames.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'RECENT GAMES',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF8A8A8A),
                          letterSpacing: 0.8,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: const Text(
                          'See all',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF7936FF),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => Padding(
                      padding: EdgeInsets.only(
                        bottom:
                            i < data.recentGames.length - 1 ? 12 : 0,
                      ),
                      child: GameFeedCard(row: data.recentGames[i]),
                    ),
                    childCount: data.recentGames.length,
                  ),
                ),
              ),
            ],

            // Bottom padding for nav bar clearance
            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),

        // ── Fixed nav bar ──────────────────────────────────────────────
        const Align(
          alignment: Alignment.bottomCenter,
          child: CustomNavBarWidget(page: 'Home'),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Greeting — white text, sits on gradient
// ─────────────────────────────────────────────────────────────────────────────

class _Greeting extends StatelessWidget {
  const _Greeting({
    required this.displayName,
    required this.playerCount,
    required this.totalGames,
  });

  final String displayName;
  final int playerCount;
  final int totalGames;

  @override
  Widget build(BuildContext context) {
    final greeting =
        displayName.isNotEmpty ? 'Hey, $displayName 👋' : 'Hey there 👋';

    final playerLabel =
        playerCount == 1 ? '1 player' : '$playerCount players';
    final gameLabel =
        totalGames == 1 ? '1 game tracked' : '$totalGames games tracked';
    final subtitle = '$playerLabel · $gameLabel';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 1.2,
          ),
        ),
        if (playerCount > 0) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section header — white on gradient
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.label,
    required this.count,
    required this.currentIndex,
  });

  final String label;
  final int count;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.white.withValues(alpha: 0.8),
            letterSpacing: 0.8,
          ),
        ),
        if (count > 1)
          Row(
            children: List.generate(count, (i) {
              final active = i == currentIndex;
              return Padding(
                padding: EdgeInsets.only(left: i > 0 ? 5 : 0),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: active ? 16 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: active
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            }),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Snapshot carousel
// ─────────────────────────────────────────────────────────────────────────────

class _SnapshotCarousel extends StatefulWidget {
  const _SnapshotCarousel({
    required this.snapshots,
    required this.currentIndex,
    required this.onIndexChanged,
  });

  final List<_PlayerSnapshot> snapshots;
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;

  @override
  State<_SnapshotCarousel> createState() => _SnapshotCarouselState();
}

class _SnapshotCarouselState extends State<_SnapshotCarousel> {
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(
      // Only peek at next card if there's more than one
      viewportFraction: widget.snapshots.length > 1 ? 0.92 : 1.0,
      initialPage: widget.currentIndex,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: PageView.builder(
        controller: _controller,
        physics: widget.snapshots.length > 1
            ? const PageScrollPhysics()
            : const NeverScrollableScrollPhysics(),
        itemCount: widget.snapshots.length,
        onPageChanged: widget.onIndexChanged,
        itemBuilder: (context, i) {
          final s = widget.snapshots[i];
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: widget.snapshots.length > 1 ? 0 : 20,
            ),
            child: SnapshotCard(
              firstName: s.firstName,
              lastName: s.lastName,
              initials: s.initials,
              totalGames: s.totalGames,
              profilePic: s.profilePic,
              insight: s.insight,
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Loading + error states
// ─────────────────────────────────────────────────────────────────────────────

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, top + 20, 20, 0),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Skeleton(width: 180, height: 28),
          SizedBox(height: 8),
          _Skeleton(width: 140, height: 14),
          SizedBox(height: 32),
          _Skeleton(width: double.infinity, height: 160),
          SizedBox(height: 28),
          _Skeleton(width: double.infinity, height: 160),
          SizedBox(height: 12),
          _Skeleton(width: double.infinity, height: 160),
        ],
      ),
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton({required this.width, required this.height});
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE8E8E8),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Could not load dashboard',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F0F0F),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onRetry,
            child: const Text(
              'Try again',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: Color(0xFF7936FF),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
