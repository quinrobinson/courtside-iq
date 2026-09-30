// Set Birth Date — Phase 4.11d
//
// Measured from 643:2188: two wheels side by side under one selection band,
// then the reason we are asking.
//
// MONTH AND YEAR ONLY, never a day. The birth date exists to place a player
// in an age band, and a band never turns on which day of the month a child
// was born. Asking for a day would collect a more precise piece of personal
// data about a minor than the feature has any use for.

import 'package:flutter/material.dart';

import '/courtside_iq/design/components/ci_sheet.dart';
import '/courtside_iq/design/components/ci_wheel_picker.dart';
import '/courtside_iq/design/tokens/ci_colors.dart';
import '/courtside_iq/design/tokens/ci_metrics.dart';
import '/courtside_iq/design/tokens/ci_type.dart';

const _months = [
  'January', 'February', 'March', 'April', //
  'May', 'June', 'July', 'August',
  'September', 'October', 'November', 'December',
];

/// Youngest and oldest players the app is for, as year offsets from now.
///
/// Carried from the v1 sheet: ages 3 through 20. The product is for 8-18, and
/// the range is deliberately wider - a parent whose child sits just outside
/// should be able to enter the truth rather than be forced to a wrong year.
const int _kYoungestOffset = 3;
const int _kOldestOffset = 20;

/// Opens the sheet and returns the chosen (year, month), or null.
Future<DateTime?> presentBirthDateSheet(
  BuildContext context, {
  DateTime? current,
}) {
  FocusScope.of(context).unfocus();
  return showCiSheet<DateTime>(
    context,
    child: BirthDateSheet(current: current),
  );
}

class BirthDateSheet extends StatefulWidget {
  const BirthDateSheet({super.key, this.current, this.today});

  final DateTime? current;

  /// Injectable so the year list is testable without depending on the clock.
  final DateTime? today;

  @override
  State<BirthDateSheet> createState() => _BirthDateSheetState();
}

class _BirthDateSheetState extends State<BirthDateSheet> {
  late final DateTime _now = widget.today ?? DateTime.now();

  /// Newest first, so the youngest eligible year sits at the top.
  late final List<int> _years = [
    for (var i = _kYoungestOffset; i <= _kOldestOffset; i++) _now.year - i,
  ];

  late int _monthIndex = (widget.current?.month ?? 1) - 1;
  late int _yearIndex = _initialYearIndex();

  int _initialYearIndex() {
    final y = widget.current?.year;
    if (y == null) return 0;
    final i = _years.indexOf(y);
    // A stored year outside the range still has to open somewhere sensible
    // rather than throwing or silently snapping to the newest.
    return i < 0 ? 0 : i;
  }

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);

    return CiSheet(
      title: 'Birth date',
      cta: 'Save',
      onCta: () => Navigator.of(context).pop(
        // Day 1: the app stores a month and a year, and 1 is the honest
        // placeholder for a day it never asked about.
        DateTime(_years[_yearIndex], _monthIndex + 1, 1),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            CiSpace.screen, CiSpace.s5, CiSpace.screen, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CiWheelBand(
              child: Row(
                children: [
                  Expanded(
                    child: CiWheelPicker<String>(
                      items: _months,
                      labelOf: (m) => m,
                      index: _monthIndex,
                      semanticLabel: 'Birth month',
                      onChanged: (i) => setState(() => _monthIndex = i),
                    ),
                  ),
                  Expanded(
                    child: CiWheelPicker<int>(
                      items: _years,
                      labelOf: (y) => '$y',
                      index: _yearIndex,
                      semanticLabel: 'Birth year',
                      onChanged: (i) => setState(() => _yearIndex = i),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: CiSpace.s6),
            Text(
              // Says WHY, at the moment of asking. A birth date is the most
              // personal thing the app collects about a child, and a parent
              // should not have to guess what it is for.
              "We use this to calibrate ratings for your player's age band.",
              textAlign: TextAlign.center,
              style: CiType.bodySm.copyWith(color: c.textSoft, height: 1.43),
            ),
          ],
        ),
      ),
    );
  }
}
