// Delete Account — Phase 4.15d
//
// The most destructive screen in the app. What these guard is that it cannot
// fire without two deliberate answers, and that the one sentence describing
// something the PARENT still has to do is actually on screen.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:courtside_i_q/courtside_iq/design/ci_theme.dart';
import 'package:courtside_i_q/features/menu/account_repository.dart';
import 'package:courtside_i_q/features/menu/delete_account_page.dart';

class _FakeAccount implements AccountRepository {
  _FakeAccount({this.succeeds = true});
  final bool succeeds;
  int deleteCalls = 0;

  @override
  Future<bool> deleteAccount() async {
    deleteCalls++;
    return succeeds;
  }

  @override
  Future<AccountProfile> load() async => const AccountProfile();
  @override
  Future<void> updateName({
    required String firstName,
    required String lastName,
  }) async {}
  @override
  Future<EmailChangeOutcome> requestEmailChange(String email) async =>
      EmailChangeOutcome.confirmationSent;
  @override
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async =>
      true;
}

Future<void> _pump(
  WidgetTester tester,
  _FakeAccount repo, {
  Future<void> Function()? onDeleted,
}) async {
  tester.view.physicalSize = const Size(1080, 4000);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
  await tester.pumpWidget(MaterialApp(
    theme: CiTheme.base(),
    home: DeleteAccountPage(repository: repo, onDeleted: onDeleted),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('says the subscription will NOT stop on its own', (tester) async {
    // The frame said "Your subscription will also stop renewing." It does
    // not: an app store subscription is owned by Apple or Google and nothing
    // we delete touches it. A parent believing otherwise gets charged again
    // for an app they cannot sign into.
    await _pump(tester, _FakeAccount());
    expect(find.textContaining('will not stop on its own'), findsOneWidget);
    expect(find.textContaining('may be charged again'), findsOneWidget);
    expect(find.textContaining('will also stop renewing'), findsNothing);
  });

  testWidgets('one tap is not enough', (tester) async {
    final repo = _FakeAccount();
    await _pump(tester, repo);

    await tester.tap(find.text('Delete my account'));
    await tester.pumpAndSettle();

    expect(find.text('Delete your account?'), findsOneWidget);
    expect(repo.deleteCalls, 0, reason: 'nothing until the second answer');
  });

  testWidgets('the second step restates what is lost', (tester) async {
    // A confirmation that says less than the screen behind it is a speed
    // bump, not a safeguard.
    await _pump(tester, _FakeAccount());
    await tester.tap(find.text('Delete my account'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Every player, every game'), findsOneWidget);
    expect(find.text('Keep my account'), findsOneWidget);
  });

  testWidgets('backing out of the second step deletes nothing', (tester) async {
    final repo = _FakeAccount();
    await _pump(tester, repo);
    await tester.tap(find.text('Delete my account'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Keep my account'));
    await tester.pumpAndSettle();
    expect(repo.deleteCalls, 0);
  });

  testWidgets('confirming twice deletes, then hands off', (tester) async {
    var signedOut = false;
    final repo = _FakeAccount();
    await _pump(tester, repo, onDeleted: () async => signedOut = true);

    await tester.tap(find.text('Delete my account'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete forever'));
    // Fixed pumps, not pumpAndSettle. The button stays busy until the caller
    // has signed out and the screen is gone, which is right - the work is
    // not finished when the row is deleted - but it means nothing settles.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(repo.deleteCalls, 1);
    // The account is gone, so there is no session to route with. The caller
    // has to tear down and leave.
    expect(signedOut, isTrue);
  });

  testWidgets('a failure says so and leaves them signed in', (tester) async {
    var signedOut = false;
    final repo = _FakeAccount(succeeds: false);
    await _pump(tester, repo, onDeleted: () async => signedOut = true);

    await tester.tap(find.text('Delete my account'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete forever'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.textContaining("didn't work"), findsOneWidget);
    // Signing them out of an account that still exists would look exactly
    // like the deletion having worked.
    expect(signedOut, isFalse);
  });
}
