import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/courtside_iq/event_types.dart';

void main() {
  test('the label a parent reads is not the value stored', () {
    // The whole point of this file. "Long-Term" is the vocabulary of whoever
    // built the table; a parent labelling a weekend tournament should not
    // have to translate it.
    expect(EventType.season.label, 'Season');
    expect(EventType.season.stored, 'Long-Term');
    expect(EventType.tournament.label, 'Tournament');
    expect(EventType.tournament.stored, 'Short-Term');
  });

  test('round-trips every type through its stored form', () {
    for (final t in EventType.values) {
      expect(eventTypeFromStored(t.stored), t, reason: t.name);
    }
  });

  test('tolerates spacing and case in stored values', () {
    // Rows written by hand or by an older build.
    expect(eventTypeFromStored('long term'), EventType.season);
    expect(eventTypeFromStored('SHORT-TERM'), EventType.tournament);
    expect(eventTypeFromStored('  Long-Term  '), EventType.season);
  });

  test('an unknown value yields no type rather than a guess', () {
    // A mislabelled event is worse than an unlabelled one.
    expect(eventTypeFromStored(null), isNull);
    expect(eventTypeFromStored(''), isNull);
    expect(eventTypeFromStored('Seasonal'), isNull);
    expect(eventTypeFromStored('Medium-Term'), isNull);
  });

  test('no stored value ever leaks into a label', () {
    for (final t in EventType.values) {
      expect(t.label, isNot(contains('Term')));
    }
  });
}
