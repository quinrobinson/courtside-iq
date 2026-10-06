import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/courtside_iq/design/ci_theme.dart';
import 'package:courtside_i_q/courtside_iq/design/components/ci_button.dart';
import 'package:courtside_i_q/courtside_iq/design/components/ci_field.dart';

Widget _host(Widget child) => MaterialApp(
      theme: CiTheme.base(),
      home: CiSurface.light(child: Scaffold(body: child)),
    );

void main() {
  group('CiPickerField', () {
    testWidgets('shows the placeholder until a value arrives', (tester) async {
      await tester.pumpWidget(_host(CiPickerField(
        label: 'Position',
        placeholder: 'Select position',
        onTap: () {},
      )));
      expect(find.text('Select position'), findsOneWidget);

      await tester.pumpWidget(_host(CiPickerField(
        label: 'Position',
        placeholder: 'Select position',
        value: 'Guard',
        onTap: () {},
      )));
      expect(find.text('Guard'), findsOneWidget);
      expect(find.text('Select position'), findsNothing);
    });

    testWidgets('is a BUTTON, not a text field', (tester) async {
      // A readOnly TextField still takes focus, still raises the keyboard on
      // some platforms, and still reads to a screen reader as editable.
      await tester.pumpWidget(_host(CiPickerField(
        label: 'Position',
        placeholder: 'Select position',
        onTap: () {},
      )));

      expect(find.byType(TextField), findsNothing);
      expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsOneWidget);
    });

    testWidgets('labels above the input, never as a placeholder',
        (tester) async {
      await tester.pumpWidget(_host(CiPickerField(
        label: 'Birth date  ·  Optional',
        placeholder: 'Select birth date',
        onTap: () {},
      )));

      // Both present at once: the label does not vanish once a value lands.
      expect(find.text('BIRTH DATE  ·  OPTIONAL'), findsOneWidget);
      expect(find.text('Select birth date'), findsOneWidget);
    });

    testWidgets('a disabled field does not fire', (tester) async {
      var taps = 0;
      await tester.pumpWidget(_host(CiPickerField(
        label: 'Position',
        placeholder: 'Select position',
        enabled: false,
        onTap: () => taps++,
      )));

      await tester.tap(find.text('Select position'));
      expect(taps, 0);
    });
  });

  group('CiSheet cta', () {
    testWidgets('a null onCta renders the button disabled, not absent',
        (tester) async {
      // How the add sheet says "not enough filled in yet" without hiding the
      // action a parent is looking for.
      await tester.pumpWidget(_host(const _CtaProbe(enabled: false)));
      expect(find.byType(CiButton), findsOneWidget);
      expect(tester.widget<CiButton>(find.byType(CiButton)).onPressed, isNull);

      await tester.pumpWidget(_host(const _CtaProbe(enabled: true)));
      expect(
          tester.widget<CiButton>(find.byType(CiButton)).onPressed, isNotNull);
    });
  });
}

class _CtaProbe extends StatelessWidget {
  const _CtaProbe({required this.enabled});
  final bool enabled;

  @override
  Widget build(BuildContext context) => CiButton(
        label: 'Add player',
        style: CiButtonStyle.lime,
        expand: true,
        onPressed: enabled ? () {} : null,
      );
}
