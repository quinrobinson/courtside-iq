import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/courtside_iq/design/ci_theme.dart';
import 'package:courtside_i_q/courtside_iq/design/components/ci_sheet.dart';
import 'package:courtside_i_q/courtside_iq/design/tokens/ci_colors.dart';
import 'package:courtside_i_q/features/players/profile_photo_sheet.dart';

Widget _host(Widget child) => MaterialApp(
      theme: CiTheme.base(),
      home: CiSurface.light(child: Scaffold(body: child)),
    );

void main() {
  testWidgets('offers both sources', (tester) async {
    await tester.pumpWidget(_host(const ProfilePhotoSheet(canRemove: false)));

    expect(find.text('Profile photo'), findsOneWidget);
    expect(find.text('Take photo'), findsOneWidget);
    expect(find.text('Choose from library'), findsOneWidget);
  });

  testWidgets('remove is absent when there is no photo', (tester) async {
    // An action that cannot do anything should not be offered.
    await tester.pumpWidget(_host(const ProfilePhotoSheet(canRemove: false)));
    expect(find.text('Remove photo'), findsNothing);

    await tester.pumpWidget(_host(const ProfilePhotoSheet(canRemove: true)));
    expect(find.text('Remove photo'), findsOneWidget);
  });

  testWidgets('remove carries the energy accent, the others do not',
      (tester) async {
    await tester.pumpWidget(_host(const ProfilePhotoSheet(canRemove: true)));

    final remove = tester.widget<Text>(find.text('Remove photo'));
    expect(remove.style!.color, CiColors.onLight.accentEnergy);

    final take = tester.widget<Text>(find.text('Take photo'));
    expect(take.style!.color, CiColors.onLight.text);
  });

  testWidgets('has no CTA - the rows are the actions', (tester) async {
    await tester.pumpWidget(_host(const ProfilePhotoSheet(canRemove: true)));
    expect(find.text('Save'), findsNothing);
    expect(find.text('Got it'), findsNothing);
  });

  testWidgets('each row returns its own action', (tester) async {
    PhotoAction? action;
    await tester.pumpWidget(MaterialApp(
      theme: CiTheme.base(),
      home: Scaffold(
        body: Builder(builder: (context) {
          return TextButton(
            onPressed: () async {
              action = await showCiSheet<PhotoAction>(
                context,
                useRootNavigator: false,
                child: const ProfilePhotoSheet(canRemove: true),
              );
            },
            child: const Text('open'),
          );
        }),
      ),
    ));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove photo'));
    await tester.pumpAndSettle();
    expect(action, PhotoAction.remove);
  });
}
