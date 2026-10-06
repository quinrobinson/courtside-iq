import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/courtside_iq/design/ci_theme.dart';
import 'package:courtside_i_q/courtside_iq/design/components/ci_avatar.dart';
import 'package:courtside_i_q/courtside_iq/design/tokens/ci_colors.dart';
import 'package:courtside_i_q/courtside_iq/design/components/ci_button.dart';
import 'package:courtside_i_q/courtside_iq/design/components/ci_field.dart';
import 'package:courtside_i_q/courtside_iq/player_averages.dart';
import 'package:courtside_i_q/courtside_iq/players_list_builder.dart';
import 'package:courtside_i_q/features/games/game_allowance.dart';
import 'package:courtside_i_q/features/games/new_game_setup_page.dart';
import 'package:courtside_i_q/features/home/widgets/game_feed_row.dart';
import 'package:courtside_i_q/features/players/players_repository.dart';

class _FakeRepo implements PlayersRepository {
  const _FakeRepo(this._players);
  final List<PlayerListEntry> _players;

  @override
  Future<List<PlayerListEntry>> load() async => _players;

  @override
  Future<List<AveragesGameRow>> loadGameRows(String playerId) async => const [];

  @override
  Future<List<GameFeedEntry>> loadGames(String playerId) async => const [];
}

PlayerListEntry _player(String id, String name) => PlayerListEntry(
      playerId: id,
      firstName: name,
      totalGames: 0,
      totalPoints: 0,
      totalRebounds: 0,
      totalAssists: 0,
    );

Future<NewGameSetup?> _pump(
  WidgetTester tester,
  List<PlayerListEntry> players, {
  bool reduceMotion = false,
  GameAllowance allowance =
      const GameAllowance(isPremium: true, gameCount: 0),
}) async {
  NewGameSetup? result;
  await tester.pumpWidget(MaterialApp(
    theme: CiTheme.base(),
    builder: reduceMotion
        ? (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: true),
              child: child!,
            )
        : null,
    home: NewGameSetupPage(
      repository: _FakeRepo(players),
      onStart: (s) => result = s,
      loadAllowance: () async => allowance,
    ),
  ));
  await tester.pumpAndSettle();
  return result;
}

void main() {
  CiButton startButton(WidgetTester tester) => tester.widget<CiButton>(
      find.ancestor(of: find.text('Start Game'), matching: find.byType(CiButton)));

  testWidgets('Start needs a player, a team AND an opponent', (tester) async {
    // The frame marks exactly one field OPTIONAL, which is the design saying
    // the others are not - and v1 disables Start without all three. An earlier
    // version required only the player.
    await _pump(tester, [_player('p1', 'Maya')]);
    expect(startButton(tester).onPressed, isNull,
        reason: 'a preselected player alone is not enough');

    await tester.enterText(find.byType(TextField), 'Hawks');
    await tester.pumpAndSettle();
    expect(startButton(tester).onPressed, isNull,
        reason: 'still no team');
  });

  testWidgets('a single player is preselected', (tester) async {
    // Nothing to choose, so the tap has only one possible answer.
    await _pump(tester, [_player('p1', 'Maya')]);
    expect(find.bySemanticsLabel('Maya'), findsOneWidget);
    // Team and event pickers become usable, which only happens once a player
    // is selected.
    expect(find.text('Select team'), findsOneWidget);
  });

  testWidgets('whitespace is not an opponent', (tester) async {
    await _pump(tester, [_player('p1', 'Maya')]);
    await tester.enterText(find.byType(TextField), '   ');
    await tester.pumpAndSettle();
    expect(startButton(tester).onPressed, isNull);
  });

  testWidgets('the event label says it is optional; team does not',
      (tester) async {
    await _pump(tester, [_player('p1', 'Maya')]);
    expect(find.text('EVENT  ·  OPTIONAL'), findsOneWidget);
    expect(find.text('TEAM'), findsOneWidget);
  });

  testWidgets('team and event pickers are disabled without a player',
      (tester) async {
    // They read that player's lists, so there is nothing to open yet.
    await _pump(tester, [_player('p1', 'Maya'), _player('p2', 'Jordan')]);
    expect(find.text('Select team'), findsOneWidget);
    // Tapping opens no empty sheet. The tap lands on the lock, which nudges
    // the player tiles instead (see the group below).
    await tester.tap(find.byKey(const ValueKey('setup-team')));
    await tester.pumpAndSettle();
    expect(find.text('Select team'), findsOneWidget);
  });

  group('choose a player first (2026-09-29)', () {
    List<CiAvatar> avatars(WidgetTester tester) =>
        tester.widgetList<CiAvatar>(find.byType(CiAvatar)).toList();

    void expectFieldsEnabled(WidgetTester tester, bool enabled) {
      for (final picker
          in tester.widgetList<CiPickerField>(find.byType(CiPickerField))) {
        expect(picker.enabled, enabled, reason: picker.label);
      }
      expect(tester.widget<CiField>(find.byType(CiField)).enabled, enabled,
          reason: 'Opponent');
    }

    testWidgets('several players: nobody chosen, all three fields locked',
        (tester) async {
      await _pump(tester, [_player('p1', 'Maya'), _player('p2', 'Jordan')]);
      expect(find.text("Who's playing?"), findsOneWidget);
      expect(avatars(tester).where((a) => a.ringWidth == 2), isEmpty);
      expect(tester.widgetList(find.byType(CiPickerField)).length, 2);
      expectFieldsEnabled(tester, false);
      expect(startButton(tester).onPressed, isNull);
      // Team shows its placeholder; nothing is preselected.
      expect(find.text('Select team'), findsOneWidget);
      // The old muted hint is gone: the label over the tiles says it.
      expect(
          find.text('Select a player above to set the team and opponent.'),
          findsNothing);

      await tester.tap(find.bySemanticsLabel('Maya'));
      await tester.pumpAndSettle();
      expectFieldsEnabled(tester, true);
    });

    testWidgets('one player: chosen for them, fields live, label still shown',
        (tester) async {
      await _pump(tester, [_player('p1', 'Maya')]);
      expect(find.text("Who's playing?"), findsOneWidget);
      expect(avatars(tester).single.ringWidth, 2);
      expectFieldsEnabled(tester, true);
    });

    testWidgets('typing is blocked while Opponent is locked', (tester) async {
      await _pump(tester, [_player('p1', 'Maya'), _player('p2', 'Jordan')]);
      await tester.tap(find.byKey(const ValueKey('setup-opponent')));
      await tester.pumpAndSettle();
      expect(tester.testTextInput.hasAnyClients, isFalse);
    });

    testWidgets('tapping a locked field pulses the player rings once',
        (tester) async {
      await _pump(tester, [_player('p1', 'Maya'), _player('p2', 'Jordan')]);
      final hairline = avatars(tester).first.ringColor;

      for (final key in ['setup-team', 'setup-opponent', 'setup-event']) {
        await tester.tap(find.byKey(ValueKey(key)));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        // Mid-pulse: pulled toward lime, and every unchosen tile together.
        for (final a in avatars(tester)) {
          expect(a.ringColor, isNot(hairline), reason: key);
          expect(a.ringWidth, greaterThan(1.35), reason: key);
        }
        await tester.pumpAndSettle();
        // And back.
        for (final a in avatars(tester)) {
          expect(a.ringColor, hairline, reason: key);
          expect(a.ringWidth, 1.35, reason: key);
        }
      }
    });

    testWidgets('with reduced motion the rings hold lime, then let go',
        (tester) async {
      await _pump(tester, [_player('p1', 'Maya'), _player('p2', 'Jordan')],
          reduceMotion: true);
      final hairline = avatars(tester).first.ringColor;

      await tester.tap(find.byKey(const ValueKey('setup-team')));
      await tester.pump();
      for (final a in avatars(tester)) {
        expect(a.ringColor, CiColors.onInk.accentGood);
      }
      await tester.pump(const Duration(milliseconds: 300));
      expect(avatars(tester).first.ringColor, CiColors.onInk.accentGood,
          reason: 'static, not animating');

      await tester.pump(const Duration(milliseconds: 300));
      expect(avatars(tester).first.ringColor, hairline);
    });
  });

  testWidgets('the hero is ink, and the chosen player wears a lime ring',
      (tester) async {
    // Read from the frame: hero #0f0f0f, selected avatar ring #9dff00 at 2pt
    // against #2e2e2e for the rest. Built on light first, by assumption.
    await _pump(tester, [_player('p1', 'Maya'), _player('p2', 'Jordan')]);

    final title = tester.widget<Text>(find.text('New Game'));
    expect(title.style!.color, CiColors.onInk.text);

    await tester.tap(find.bySemanticsLabel('Maya'));
    await tester.pumpAndSettle();

    final avatars = tester.widgetList<CiAvatar>(find.byType(CiAvatar)).toList();
    final chosen = avatars.firstWhere((a) => a.ringWidth == 2);
    expect(chosen.ringColor, CiColors.onInk.accentGood);
    // Everyone else keeps the hairline.
    expect(avatars.where((a) => a.ringWidth == 2).length, 1);
  });

  group('free games hint (roadmap 3.8)', () {
    final maya = [_player('p1', 'Maya')];

    // One pump per test: re-pumping the same page keeps its State, so the
    // hint would not reload.
    testWidgets('shows 1 of 3 for a free parent', (tester) async {
      await _pump(tester, maya,
          allowance: const GameAllowance(isPremium: false, gameCount: 1));
      expect(find.text('1 of 3 free games used'), findsOneWidget);
    });

    testWidgets('shows 2 of 3 with no sales line', (tester) async {
      await _pump(tester, maya,
          allowance: const GameAllowance(isPremium: false, gameCount: 2));
      expect(find.text('2 of 3 free games used'), findsOneWidget);
      expect(find.textContaining('Premium'), findsNothing);
    });

    testWidgets('is hidden for premium', (tester) async {
      await _pump(tester, maya,
          allowance: const GameAllowance(isPremium: true, gameCount: 2));
      expect(find.textContaining('free games used'), findsNothing);
    });

    testWidgets('is hidden before the first game', (tester) async {
      await _pump(tester, maya,
          allowance: const GameAllowance(isPremium: false, gameCount: 0));
      expect(find.textContaining('free games used'), findsNothing);
    });
  });
}
