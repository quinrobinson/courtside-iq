import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/courtside_iq/design/ci_theme.dart';
import 'package:courtside_i_q/courtside_iq/event_types.dart';
import 'package:courtside_i_q/features/players/teams_events_repository.dart';
import 'package:courtside_i_q/features/players/teams_events_sheets.dart';

/// In-memory stand-in. The sheets are the thing under test, not Supabase.
class _FakeRepo implements TeamsEventsRepository {
  _FakeRepo({List<PlayerTeam>? teams, List<PlayerEvent>? events})
      : teams = teams ?? [],
        events = events ?? [];

  final List<PlayerTeam> teams;
  final List<PlayerEvent> events;
  final List<String> calls = [];

  @override
  Future<List<PlayerTeam>> loadTeams(String playerId) async => teams;

  @override
  Future<void> addTeam(String playerId, String name) async {
    calls.add('addTeam:$name');
    teams.add(PlayerTeam(id: teams.length + 1, name: name));
  }

  @override
  Future<void> removeTeam(int id) async {
    calls.add('removeTeam:$id');
    teams.removeWhere((t) => t.id == id);
  }

  @override
  Future<List<PlayerEvent>> loadEvents(String playerId) async => events;

  @override
  Future<void> addEvent(String playerId, String name, EventType type) async {
    calls.add('addEvent:$name:${type.stored}');
    events.add(PlayerEvent(id: events.length + 1, name: name, type: type));
  }

  @override
  Future<void> removeEvent(int id) async {
    calls.add('removeEvent:$id');
    events.removeWhere((e) => e.id == id);
  }
}

Future<bool> _openTeams(WidgetTester tester, _FakeRepo repo) async {
  bool? changed;
  await tester.pumpWidget(MaterialApp(
    theme: CiTheme.base(),
    home: Scaffold(
      body: Builder(builder: (context) {
        return TextButton(
          onPressed: () async {
            changed = await presentTeamsSheet(context,
                playerId: 'p1', repository: repo);
          },
          child: const Text('open'),
        );
      }),
    ),
  ));
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return changed ?? false;
}

void main() {
  testWidgets('the teams sheet says removing does not touch history',
      (tester) async {
    // This caption is the whole reason there is no rename.
    final repo = _FakeRepo(teams: [const PlayerTeam(id: 1, name: 'Hawks')]);
    await _openTeams(tester, repo);

    expect(find.text('Teams'), findsOneWidget);
    expect(
        find.text('Teams you can pick when logging a game. Past games keep '
            'the team they were logged with.'),
        findsOneWidget);
    expect(find.text('Hawks'), findsOneWidget);
  });

  testWidgets('remove is labelled, not a bare glyph', (tester) async {
    // An unlabelled X beside a team name could mean edit or close. This one
    // deletes a row.
    final repo = _FakeRepo(teams: [const PlayerTeam(id: 7, name: 'Hawks')]);
    await _openTeams(tester, repo);

    expect(find.text('Remove'), findsOneWidget);
    expect(find.bySemanticsLabel('Remove Hawks'), findsOneWidget);

    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();
    expect(repo.calls, contains('removeTeam:7'));
  });

  testWidgets('offers no rename anywhere', (tester) async {
    final repo = _FakeRepo(teams: [const PlayerTeam(id: 1, name: 'Hawks')]);
    await _openTeams(tester, repo);
    for (final word in ['Rename', 'Edit']) {
      expect(find.text(word), findsNothing, reason: word);
    }
  });

  testWidgets('an empty list still offers the add row', (tester) async {
    final repo = _FakeRepo();
    await _openTeams(tester, repo);
    expect(find.text('+   Add team'), findsOneWidget);
  });

  testWidgets('events show the LABEL, never the stored value', (tester) async {
    final repo = _FakeRepo(events: [
      const PlayerEvent(id: 1, name: 'Spring Classic', type: EventType.tournament),
      const PlayerEvent(id: 2, name: 'Metro League', type: EventType.season),
    ]);
    await tester.pumpWidget(MaterialApp(
      theme: CiTheme.base(),
      home: Scaffold(
        body: Builder(builder: (context) {
          return TextButton(
            onPressed: () =>
                presentEventsSheet(context, playerId: 'p1', repository: repo),
            child: const Text('open'),
          );
        }),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Tournament'), findsOneWidget);
    expect(find.text('Season'), findsOneWidget);
    expect(find.text('Short-Term'), findsNothing);
    expect(find.text('Long-Term'), findsNothing);
  });

  testWidgets('an event with an unrecognised type still lists', (tester) async {
    // Better a row with no type than a row labelled the wrong one.
    final repo = _FakeRepo(events: [
      const PlayerEvent(id: 1, name: 'Mystery Cup'),
    ]);
    await tester.pumpWidget(MaterialApp(
      theme: CiTheme.base(),
      home: Scaffold(
        body: Builder(builder: (context) {
          return TextButton(
            onPressed: () =>
                presentEventsSheet(context, playerId: 'p1', repository: repo),
            child: const Text('open'),
          );
        }),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Mystery Cup'), findsOneWidget);
  });
}
