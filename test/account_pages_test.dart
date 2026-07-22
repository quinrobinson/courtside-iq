// Account screens — Phase 4.15b
//
// The three things worth guarding here are all places where the frame and the
// backend disagree about what happened:
//
//   the name is ONE field on screen and two columns in the table
//   an email change is a REQUEST, not a change
//   Supabase never checks the old password, so this screen must

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/courtside_iq/design/ci_theme.dart';
import 'package:courtside_i_q/features/menu/account_repository.dart';
import 'package:courtside_i_q/features/menu/change_password_page.dart';
import 'package:courtside_i_q/features/menu/edit_email_page.dart';
import 'package:courtside_i_q/features/menu/edit_name_page.dart';

class _FakeAccount implements AccountRepository {
  _FakeAccount({
    this.emailOutcome = EmailChangeOutcome.confirmationSent,
    this.passwordOk = true,
  });

  static const profile = AccountProfile(
      firstName: 'Alex', lastName: 'Rivera', email: 'alex@example.com');
  final EmailChangeOutcome emailOutcome;
  final bool passwordOk;

  final names = <List<String>>[];
  final emails = <String>[];
  final passwords = <List<String>>[];

  @override
  Future<AccountProfile> load() async => profile;

  @override
  Future<void> updateName({
    required String firstName,
    required String lastName,
  }) async =>
      names.add([firstName, lastName]);

  @override
  Future<EmailChangeOutcome> requestEmailChange(String email) async {
    emails.add(email);
    return emailOutcome;
  }

  @override
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    passwords.add([currentPassword, newPassword]);
    return passwordOk;
  }
}

/// After a SAVE, not pumpAndSettle.
///
/// The success snackbar animates and the screen pops underneath it, so
/// settling never completes. Fixed pumps are the same workaround the tracker
/// tests use for the busy spinner.
Future<void> _pumpSave(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

Future<void> _pump(WidgetTester tester, Widget page) async {
  tester.view.physicalSize = const Size(1080, 4000);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
  await tester.pumpWidget(MaterialApp(theme: CiTheme.base(), home: page));
  await tester.pumpAndSettle();
}

void main() {
  group('Edit name', () {
    testWidgets('loads the name that exists', (tester) async {
      await _pump(tester, EditNamePage(repository: _FakeAccount()));
      expect(find.text('Alex Rivera'), findsOneWidget);
    });

    testWidgets('saving is off until something changes', (tester) async {
      // A button that saves an unchanged name is noise.
      final repo = _FakeAccount();
      await _pump(tester, EditNamePage(repository: repo));

      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();
      expect(repo.names, isEmpty);
    });

    testWidgets('splits one field into two columns at the LAST space',
        (tester) async {
      final repo = _FakeAccount();
      await _pump(tester, EditNamePage(repository: repo));

      await tester.enterText(find.byType(TextField), 'Ana Maria Diaz Lopez');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save changes'));
      await _pumpSave(tester);

      // Lossy by design, and it round-trips: nothing displays the halves
      // separately, so "Ana Maria Diaz" + "Lopez" reassembles exactly.
      expect(repo.names.single, ['Ana Maria Diaz', 'Lopez']);
    });

    testWidgets('a single word saves with an empty last name', (tester) async {
      final repo = _FakeAccount();
      await _pump(tester, EditNamePage(repository: repo));
      await tester.enterText(find.byType(TextField), 'Cher');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save changes'));
      await _pumpSave(tester);
      expect(repo.names.single, ['Cher', '']);
    });

    testWidgets('an emptied name cannot be saved', (tester) async {
      final repo = _FakeAccount();
      await _pump(tester, EditNamePage(repository: repo));
      await tester.enterText(find.byType(TextField), '   ');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();
      expect(repo.names, isEmpty);
    });
  });

  group('Edit email', () {
    testWidgets('warns BEFORE the tap that nothing changes yet',
        (tester) async {
      // The frame says nothing about this. A parent deciding whether to move
      // the address they sign in with should know a confirmation is involved
      // before they commit, not after.
      await _pump(tester, EditEmailPage(repository: _FakeAccount()));
      expect(
          find.textContaining('keep signing in with your current one'),
          findsOneWidget);
    });

    testWidgets('rejects a malformed address without calling the server',
        (tester) async {
      final repo = _FakeAccount();
      await _pump(tester, EditEmailPage(repository: repo));
      await tester.enterText(find.byType(TextField), 'not-an-email');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();
      expect(repo.emails, isEmpty);
    });

    testWidgets('a rejected address explains itself and stays put',
        (tester) async {
      final repo =
          _FakeAccount(emailOutcome: EmailChangeOutcome.failed);
      await _pump(tester, EditEmailPage(repository: repo));
      await tester.enterText(find.byType(TextField), 'taken@example.com');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();

      expect(find.textContaining('may already have an account'), findsOneWidget);
      // Still on the screen, with what they typed.
      expect(find.text('Save changes'), findsOneWidget);
    });
  });

  group('Change password', () {
    testWidgets('will not submit until all three are filled', (tester) async {
      final repo = _FakeAccount();
      await _pump(tester, ChangePasswordPage(repository: repo));
      await tester.tap(find.text('Update password'));
      await tester.pumpAndSettle();
      expect(repo.passwords, isEmpty);
    });

    testWidgets('a mismatch is caught before the server', (tester) async {
      final repo = _FakeAccount();
      await _pump(tester, ChangePasswordPage(repository: repo));
      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), 'oldpassword');
      await tester.enterText(fields.at(1), 'newpassword1');
      await tester.enterText(fields.at(2), 'newpassword2');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Update password'));
      await tester.pumpAndSettle();
      expect(repo.passwords, isEmpty);
    });

    testWidgets('a wrong current password lands on ITS OWN field',
        (tester) async {
      // Not a general banner. It is the only one of the three a parent cannot
      // check by looking, and a vague error means retyping all of them.
      final repo = _FakeAccount(passwordOk: false);
      await _pump(tester, ChangePasswordPage(repository: repo));
      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), 'wrongpassword');
      await tester.enterText(fields.at(1), 'newpassword1');
      await tester.enterText(fields.at(2), 'newpassword1');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Update password'));
      await tester.pumpAndSettle();

      expect(find.text("That's not your current password."), findsOneWidget);
    });

    testWidgets('sends the current password so it can be verified',
        (tester) async {
      // Supabase's updateUser never checks it. If this stopped being sent,
      // the field would be decoration and anyone holding an unlocked phone
      // could lock the owner out.
      final repo = _FakeAccount();
      await _pump(tester, ChangePasswordPage(repository: repo));
      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), 'oldpassword');
      await tester.enterText(fields.at(1), 'newpassword1');
      await tester.enterText(fields.at(2), 'newpassword1');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Update password'));
      await _pumpSave(tester);

      expect(repo.passwords.single, ['oldpassword', 'newpassword1']);
    });
  });
}
