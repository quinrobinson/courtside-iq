import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

import '/backend/supabase/supabase.dart';

import '/auth/base_auth_user_provider.dart';

import '/main.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:ff_commons/flutter_flow/lat_lng.dart';
import 'package:ff_commons/flutter_flow/place.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'serialization_util.dart';

import '/index.dart';
import '/features/player_insight/player_profile_page.dart';
import '/features/dashboard/dashboard_page.dart';
import '/features/home/today_page.dart';
import '/features/onboarding/first_run_gate.dart';
import '/features/onboarding/whats_new_gate.dart';
import '/features/nav/ci_nav_shell.dart';
import '/features/players/players_list_page.dart';
import '/features/players/player_profile_page.dart';
import '/features/auth/auth_landing_page.dart';
import '/features/auth/email_auth_page.dart';
import '/features/auth/forgot_password_page.dart';
import '/features/auth/reset_password_page.dart';
import '/features/auth/reset_successful_page.dart';
import '/features/flags.dart';
import '/features/games/games_list_page.dart';
import '/features/games/game_detail_page.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/custom_code/actions/index.dart' as actions;
import '/features/menu/change_password_page.dart';
import '/features/menu/delete_account_page.dart';
import '/features/menu/edit_email_page.dart';
import '/features/menu/edit_name_page.dart';
import '/features/menu/help_center_page.dart';
import '/features/menu/menu_page.dart';
import '/features/premium/paywall_launcher.dart';
import '/features/premium/paywall_page.dart';
import '/features/menu/send_feedback_page.dart';
import '/features/menu/your_profile_page.dart';
import '/features/games/live_game_flow.dart';
import '/features/games/new_game_setup_page.dart';
import '/features/onboarding/onboarding_page.dart';
import '/features/onboarding/splash_view.dart';
import 'package:lock_orientation_library_opafp4/index.dart'
    as $lock_orientation_library_opafp4;

export 'package:go_router/go_router.dart';
export 'serialization_util.dart';

const kTransitionInfoKey = '__transition_info__';

GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

class AppStateNotifier extends ChangeNotifier {
  AppStateNotifier._();

  static AppStateNotifier? _instance;
  static AppStateNotifier get instance => _instance ??= AppStateNotifier._();

  BaseAuthUser? initialUser;
  BaseAuthUser? user;
  bool showSplashImage = true;
  String? _redirectLocation;

  /// Determines whether the app will refresh and build again when a sign
  /// in or sign out happens. This is useful when the app is launched or
  /// on an unexpected logout. However, this must be turned off when we
  /// intend to sign in/out and then navigate or perform any actions after.
  /// Otherwise, this will trigger a refresh and interrupt the action(s).
  bool notifyOnAuthChange = true;

  bool get loading => user == null || showSplashImage;
  bool get loggedIn => user?.loggedIn ?? false;
  bool get initiallyLoggedIn => initialUser?.loggedIn ?? false;
  bool get shouldRedirect => loggedIn && _redirectLocation != null;

  String getRedirectLocation() => _redirectLocation!;
  bool hasRedirect() => _redirectLocation != null;
  void setRedirectLocationIfUnset(String loc) => _redirectLocation ??= loc;
  void clearRedirectLocation() => _redirectLocation = null;

  /// Mark as not needing to notify on a sign in / out when we intend
  /// to perform subsequent actions (such as navigation) afterwards.
  void updateNotifyOnAuthChange(bool notify) => notifyOnAuthChange = notify;

  void update(BaseAuthUser newUser) {
    final shouldUpdate =
        user?.uid == null || newUser.uid == null || user?.uid != newUser.uid;
    initialUser ??= newUser;
    user = newUser;
    // Refresh the app on auth change unless explicitly marked otherwise.
    // No need to update unless the user has changed.
    if (notifyOnAuthChange && shouldUpdate) {
      notifyListeners();
    }
    // Once again mark the notifier as needing to update on auth change
    // (in order to catch sign in / out events).
    updateNotifyOnAuthChange(true);
  }

  void stopShowingSplashImage() {
    showSplashImage = false;
    notifyListeners();
  }
}

/// The screen a session starts on, flags applied.
///
/// This exists because the flags were applied in three places and one of them
/// was missed: the signed-OUT branch here still built the v1 OnBoardWidget
/// directly, so the 2.0 onboarding was routed correctly and never actually
/// seen. `_initialize` and `errorBuilder` both bypass the route table, so a
/// flag added only to the route table does nothing for a cold start.
///
/// Every entry point calls this. Adding a screen flag means changing one line.
Widget _entryScreen(AppStateNotifier appStateNotifier) {
  if (appStateNotifier.loggedIn) {
    return _homeScreen();
  }
  return kUseEntry2 ? const OnboardingPage() : OnBoardWidget();
}

/// Home, flags applied. 4.10a's TodayPage supersedes DashboardPage, which
/// itself superseded HomeWidget - so the newest wins and each older one stays
/// reachable by turning its successor off.
Widget _homeScreen() {
  if (kUseToday2) {
    // The two one-time landing gates: FirstRunGate welcomes a brand-new parent
    // BEFORE they see Today; WhatsNewGate floats the 2.0 upgrade sheet OVER
    // Today for an existing v1 user. They are mutually exclusive (first-run
    // marks the upgrade sheet seen), so at most one fires.
    //
    // UNDER THE SHELL THEY WRAP THE SHELL INSTEAD (see ci_nav_shell.dart):
    // first-run has to cover the nav bar, and a gate applied here would sit
    // inside the Home branch and render underneath it. Applying them in both
    // places would also mount each gate twice and fire its query twice.
    Widget home = const TodayPage();
    if (!kUseNavShell) {
      if (kUseWhatsNew2) home = WhatsNewGate(child: home);
      if (kUseFirstRun) home = FirstRunGate(child: home);
    }
    return home;
  }
  return kUseDashboardV2 ? const DashboardPage() : HomeWidget();
}

/// Where a signed-in parent at `/` has to be sent, and WHY (4.19f).
///
/// `/` builds the home screen INLINE through [_entryScreen]. That was fine
/// when Today drew its own nav bar, but the shell owns the bar now and the
/// shell is not in that subtree at all - so a cold start landed on Today with
/// NO BOTTOM NAV. The route table's `/home` is the one inside the shell, so
/// `/` has to hand over to it rather than render home itself.
///
/// Only when LOGGED IN: while auth is still resolving, `/` must stay put and
/// show the splash, and a signed-out parent belongs on onboarding.
String? shellEntryRedirect({required bool loggedIn, required String path}) {
  if (!kUseNavShell || !loggedIn) return null;
  return path == '/' ? HomeWidget.routePath : null;
}

GoRouter createRouter(AppStateNotifier appStateNotifier) {
  $lock_orientation_library_opafp4.initializeRoutes(
    homePageWidgetName: 'lock_orientation_library_opafp4.HomePage',
    homePageWidgetPath: '/homePage',
  );

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: false,
    refreshListenable: appStateNotifier,
    navigatorKey: appNavigatorKey,
    redirect: (context, state) => shellEntryRedirect(
      loggedIn: appStateNotifier.loggedIn,
      path: state.uri.path,
    ),
    errorBuilder: (context, state) => _entryScreen(appStateNotifier),
    routes: _buildRoutes([
      FFRoute(
        name: '_initialize',
        path: '/',
        builder: (context, _) => _entryScreen(appStateNotifier),
      ),
      FFRoute(
        name: PlayersListWidget.routeName,
        path: PlayersListWidget.routePath,
        requireAuth: true,
        // 4.11a: keeps the v1 route name and path so existing navigation
        // reaches it unchanged; the flag is a one-line revert.
        builder: (context, params) =>
            kUsePlayers2 ? const PlayersListPage() : PlayersListWidget(),
      ),
      FFRoute(
        name: MenuWidget.routeName,
        path: MenuWidget.routePath,
        requireAuth: true,
        builder: (context, params) => kUseMenu2
            ? MenuPage(
                // MIRRORS v1's SIGN-OUT EXACTLY, including the RevenueCat
                // logout. Dropping that would leave the next account signed
                // in on this device carrying the previous one's entitlement -
                // the bug that once handed everyone premium.
                onSignOut: () async {
                  GoRouter.of(context).prepareAuthEvent();
                  await authManager.signOut();
                  GoRouter.of(context).clearRedirectLocation();
                  final router = GoRouter.of(context);
                  await actions.logoutOfRevenueCat();
                  router.goNamed(UserAuthWidget.routeName);
                },
                onOpenProfile: () =>
                    context.pushNamed(YourProfileWidget.routeName),
                onOpenHelp: () => context.pushNamed(HelpCenterWidget.routeName),
                onOpenFeedback: () =>
                    context.pushNamed(SendFeedbackWidget.routeName),
                onOpenSubscription: () => showPaywall(context),
              )
            : MenuWidget(),
      ),
      FFRoute(
        name: UserAuthWidget.routeName,
        path: UserAuthWidget.routePath,
        // 4.9: keeps the v1 route name and path so existing navigation calls
        // reach it unchanged and the flag is a one-line revert.
        builder: (context, params) =>
            kUseAuthLanding2 ? const AuthLandingPage() : UserAuthWidget(),
      ),
      FFRoute(
        name: GameStatTrackerWidget.routeName,
        path: GameStatTrackerWidget.routePath,
        requireAuth: true,
        builder: (context, params) => GameStatTrackerWidget(
          playerName: params.getParam('playerName', ParamType.String),
          oppName: params.getParam('oppName', ParamType.String),
          playerID: params.getParam('playerID', ParamType.String),
          eventSelected: params.getParam('eventSelected', ParamType.String),
          playerTeam: params.getParam('playerTeam', ParamType.String),
        ),
      ),
      FFRoute(
        name: AllGamesWidget.routeName,
        path: AllGamesWidget.routePath,
        requireAuth: true,
        builder: (context, params) =>
            kUseGames2 ? const GamesListPage() : AllGamesWidget(),
      ),
      FFRoute(
        name: EditPlayerWidget.routeName,
        path: EditPlayerWidget.routePath,
        requireAuth: true,
        builder: (context, params) => EditPlayerWidget(
          playerID: params.getParam('playerID', ParamType.String),
        ),
      ),
      FFRoute(
        name: OnBoardWidget.routeName,
        path: OnBoardWidget.routePath,
        // 4.9: keeps the v1 route name and path so existing navigation calls
        // reach it unchanged and the flag is a one-line revert.
        //
        // NOT the only way onboarding is reached - _initialize and
        // errorBuilder bypass the route table entirely, which is why they go
        // through _entryScreen. Flagging only here left the v1 screen showing
        // on every cold start.
        builder: (context, params) =>
            kUseEntry2 ? const OnboardingPage() : OnBoardWidget(),
      ),
      FFRoute(
        name: HomeWidget.routeName,
        path: HomeWidget.routePath,
        requireAuth: true,
        builder: (context, params) => _homeScreen(),
      ),
      FFRoute(
        name: EditNameWidget.routeName,
        path: EditNameWidget.routePath,
        requireAuth: true,
        builder: (context, params) => kUseMenu2
            ? const EditNamePage()
            : EditNameWidget(
                userFirstName: params.getParam(
                  'userFirstName',
                  ParamType.String,
                ),
                userLastName: params.getParam('userLastName', ParamType.String),
                userEmail: params.getParam('userEmail', ParamType.String),
                userID: params.getParam('userID', ParamType.String),
              ),
      ),
      FFRoute(
        name: YourProfileWidget.routeName,
        path: YourProfileWidget.routePath,
        requireAuth: true,
        builder: (context, params) => kUseMenu2
            ? YourProfilePage(
                onEditName: () => context.pushNamed(EditNameWidget.routeName, extra: slideInExtra()),
                onEditEmail: () => context.pushNamed(EditEmailWidget.routeName, extra: slideInExtra()),
                onChangePassword: () =>
                    context.pushNamed(ChangePasswordPage.routeName, extra: slideInExtra()),
                onDeleteAccount: () =>
                    context.pushNamed(DeleteAccountPage.routeName, extra: slideInExtra()),
                // onEditPhoto stays null: there is no column to store one.
              )
            : YourProfileWidget(
                userFirstName: params.getParam(
                  'userFirstName',
                  ParamType.String,
                ),
                userLastName: params.getParam('userLastName', ParamType.String),
                userEmail: params.getParam('userEmail', ParamType.String),
                userID: params.getParam('userID', ParamType.String),
              ),
      ),
      FFRoute(
        name: EditEmailWidget.routeName,
        path: EditEmailWidget.routePath,
        requireAuth: true,
        builder: (context, params) => kUseMenu2
            ? const EditEmailPage()
            : EditEmailWidget(
                userEmail: params.getParam('userEmail', ParamType.String),
                userFirstName: params.getParam(
                  'userFirstName',
                  ParamType.String,
                ),
                userLastName: params.getParam('userLastName', ParamType.String),
                userID: params.getParam('userID', ParamType.double),
              ),
      ),
      FFRoute(
        name: ResetPasswordWidget.routeName,
        path: ResetPasswordWidget.routePath,
        // requireAuth stays: the recovery link establishes a session first,
        // and updateUser applies to that session.
        requireAuth: true,
        builder: (context, params) => kUsePasswordReset2
            ? const ResetPasswordPage()
            : ResetPasswordWidget(),
      ),
      FFRoute(
        name: ForgotPasswordWidget.routeName,
        path: ForgotPasswordWidget.routePath,
        // 4.9: keeps the v1 route name and path so existing navigation calls
        // reach it unchanged and the flag is a one-line revert.
        builder: (context, params) => kUsePasswordReset2
            ? const ForgotPasswordPage()
            : ForgotPasswordWidget(),
      ),
      FFRoute(
        name: PlayersProfileWidget.routeName,
        path: PlayersProfileWidget.routePath,
        requireAuth: true,
        // 4.11b: keeps the v1 route name and path so every existing
        // navigation call reaches it unchanged.
        builder: (context, params) {
          final id = params.getParam('playerID', ParamType.String) ?? '';
          return kUseProfile2
              ? PlayerProfilePage(playerId: id)
              : PlayerProfilePageV2(playerId: id);
        },
      ),
      FFRoute(
        name: HelpCenterWidget.routeName,
        path: HelpCenterWidget.routePath,
        builder: (context, params) => kUseMenu2
            ? HelpCenterPage(
                onSendFeedback: () =>
                    context.pushNamed(SendFeedbackWidget.routeName),
              )
            : HelpCenterWidget(),
      ),
      FFRoute(
        name: ResetSuccesfulWidget.routeName,
        path: ResetSuccesfulWidget.routePath,
        // requireAuth stays: the recovery link establishes a session first,
        // and updateUser applies to that session.
        requireAuth: true,
        builder: (context, params) => kUsePasswordReset2
            ? const ResetSuccessfulPage()
            : ResetSuccesfulWidget(),
      ),
      FFRoute(
        name: EditPlayerPositionWidget.routeName,
        path: EditPlayerPositionWidget.routePath,
        requireAuth: true,
        builder: (context, params) => EditPlayerPositionWidget(
          playerID: params.getParam('playerID', ParamType.String),
          playerPosition: params.getParam('playerPosition', ParamType.String),
        ),
      ),
      FFRoute(
        name: NewGameWidget.routeName,
        path: NewGameWidget.routePath,
        requireAuth: true,
        builder: (context, params) =>
            kUseNewGame2 ? const _NewGameSetupRoute() : NewGameWidget(),
      ),
      FFRoute(
        name: AppAppearanceWidget.routeName,
        path: AppAppearanceWidget.routePath,
        requireAuth: true,
        builder: (context, params) => AppAppearanceWidget(),
      ),
      FFRoute(
        name: UserAuthEmailWidget.routeName,
        path: UserAuthEmailWidget.routePath,
        // 4.9: the 2.0 screen keeps the v1 route name and path, so every
        // existing navigation call reaches it unchanged and flipping the flag
        // back is a one-line revert rather than a routing change.
        builder: (context, params) =>
            kUseAuth2 ? const EmailAuthPage() : UserAuthEmailWidget(),
      ),
      FFRoute(
        name: DeleteAccountPage.routeName,
        path: DeleteAccountPage.routePath,
        requireAuth: true,
        builder: (context, params) => DeleteAccountPage(
          // The account is gone, so there is no session to route with.
          // Same teardown as Log out, including the RevenueCat logout:
          // without it the next account on this device inherits the
          // entitlement of the one just deleted.
          onDeleted: () async {
            GoRouter.of(context).prepareAuthEvent();
            await authManager.signOut();
            GoRouter.of(context).clearRedirectLocation();
            final router = GoRouter.of(context);
            await actions.logoutOfRevenueCat();
            router.goNamed(UserAuthWidget.routeName);
          },
        ),
      ),
      FFRoute(
        name: PaywallPage.routeName,
        path: PaywallPage.routePath,
        requireAuth: true,
        builder: (context, params) => PaywallPage(
          onClose: () => context.pop(false),
          onPurchased: () => context.pop(true),
          onOpenTerms: () => launchURL('https://www.courtsideiq.app/terms'),
          onOpenPrivacy: () => launchURL('https://www.courtsideiq.app/policy'),
        ),
      ),
      FFRoute(
        name: ChangePasswordPage.routeName,
        path: ChangePasswordPage.routePath,
        requireAuth: true,
        builder: (context, params) => const ChangePasswordPage(),
      ),
      FFRoute(
        name: SendFeedbackWidget.routeName,
        path: SendFeedbackWidget.routePath,
        requireAuth: true,
        builder: (context, params) =>
            kUseMenu2 ? const SendFeedbackPage() : SendFeedbackWidget(),
      ),
      FFRoute(
        name: GameStatsWidget.routeName,
        path: GameStatsWidget.routePath,
        builder: (context, params) {
          final gameId = params.getParam('gameID', ParamType.String) ?? '';
          // Switched HERE, not at the five call sites that push this route.
          // One flag, every entry point - the games list, Today, the profile
          // Games tab and the profile's own row cannot drift apart.
          if (kUseGameDetail2) {
            return GameDetailPage(gameId: gameId);
          }
          return GameStatsWidget(
            playerID: params.getParam('playerID', ParamType.String),
            gameID: gameId,
          );
        },
      ),
      FFRoute(
        name: $lock_orientation_library_opafp4.HomePageWidget.routeName,
        path: $lock_orientation_library_opafp4.HomePageWidget.routePath,
        builder: (context, params) =>
            $lock_orientation_library_opafp4.HomePageWidget(),
      ),
    ], appStateNotifier),
  );
}

/// The four tabs the shell owns, in branch order, plus the pushed screens that
/// belong to a tab and KEEP the bar.
///
/// Player Profile rides in the Players branch: it is pushed, it shows the bar
/// today, and putting it in the branch means it inherits the shell's bar
/// instead of drawing a second one. Game Detail is deliberately NOT here - it
/// renders no bar today, so leaving it top-level keeps it identical.
final _shellBranchRouteNames = <List<String>>[
  [HomeWidget.routeName],
  [PlayersListWidget.routeName, PlayersProfileWidget.routeName],
  [AllGamesWidget.routeName],
  [MenuWidget.routeName],
];

/// Wraps the tab routes in a [StatefulShellRoute] so one nav bar survives a
/// tab change. See [kUseNavShell] and `ci_nav_shell.dart`.
///
/// ROUTE NAMES AND PATHS ARE UNCHANGED. The branches reuse the very same
/// [FFRoute] definitions, so every `goNamed`/`pushNamed` in the app keeps
/// working and turning the flag off restores the previous flat table exactly.
List<RouteBase> _buildRoutes(
  List<FFRoute> routes,
  AppStateNotifier appStateNotifier,
) {
  if (!kUseNavShell) {
    return routes.map((r) => r.toRoute(appStateNotifier)).toList();
  }

  final inShell = _shellBranchRouteNames.expand((b) => b).toSet();
  GoRoute build(String name) =>
      routes.firstWhere((r) => r.name == name).toRoute(appStateNotifier);

  return [
    // Everything the shell does not own stays top-level, so pushing it covers
    // the shell and its bar - which is what these screens already did.
    ...routes
        .where((r) => !inShell.contains(r.name))
        .map((r) => r.toRoute(appStateNotifier)),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          CiNavShell(navigationShell: navigationShell),
      branches: [
        for (final names in _shellBranchRouteNames)
          StatefulShellBranch(routes: [for (final n in names) build(n)]),
      ],
    ),
  ];
}

extension NavParamExtensions on Map<String, String?> {
  Map<String, String> get withoutNulls => Map.fromEntries(
    entries.where((e) => e.value != null).map((e) => MapEntry(e.key, e.value!)),
  );
}

extension NavigationExtensions on BuildContext {
  void goNamedAuth(
    String name,
    bool mounted, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
    Object? extra,
    bool ignoreRedirect = false,
  }) => !mounted || GoRouter.of(this).shouldRedirect(ignoreRedirect)
      ? null
      : goNamed(
          name,
          pathParameters: pathParameters,
          queryParameters: queryParameters,
          extra: extra,
        );

  void pushNamedAuth(
    String name,
    bool mounted, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
    Object? extra,
    bool ignoreRedirect = false,
  }) => !mounted || GoRouter.of(this).shouldRedirect(ignoreRedirect)
      ? null
      : pushNamed(
          name,
          pathParameters: pathParameters,
          queryParameters: queryParameters,
          extra: extra,
        );

  void safePop() {
    // If there is only one route on the stack, navigate to the initial
    // page instead of popping.
    if (canPop()) {
      pop();
    } else {
      go('/');
    }
  }
}

extension GoRouterExtensions on GoRouter {
  AppStateNotifier get appState => AppStateNotifier.instance;
  void prepareAuthEvent([bool ignoreRedirect = false]) =>
      appState.hasRedirect() && !ignoreRedirect
      ? null
      : appState.updateNotifyOnAuthChange(false);
  bool shouldRedirect(bool ignoreRedirect) =>
      !ignoreRedirect && appState.hasRedirect();
  void clearRedirectLocation() => appState.clearRedirectLocation();
  void setRedirectLocationIfUnset(String location) =>
      appState.updateNotifyOnAuthChange(false);
}

extension _GoRouterStateExtensions on GoRouterState {
  Map<String, dynamic> get extraMap =>
      extra != null ? extra as Map<String, dynamic> : {};
  Map<String, dynamic> get allParams => <String, dynamic>{}
    ..addAll(pathParameters)
    ..addAll(uri.queryParameters)
    ..addAll(extraMap);
  TransitionInfo get transitionInfo {
    final possibleKeys = [
      '__transition_info__',
      '__transition_info__lock_orientation_library_opafp4',
    ];
    for (final key in possibleKeys) {
      if (extraMap.containsKey(key)) {
        return extraMap[key] as TransitionInfo;
      }
    }
    return TransitionInfo.appDefault();
  }
}

class FFParameters {
  FFParameters(this.state, [this.asyncParams = const {}]);

  final GoRouterState state;
  final Map<String, Future<dynamic> Function(String)> asyncParams;

  Map<String, dynamic> futureParamValues = {};

  // Parameters are empty if the params map is empty or if the only parameter
  // present is the special extra parameter reserved for the transition info.
  bool get isEmpty =>
      state.allParams.isEmpty ||
      (state.allParams.length == 1 &&
          state.extraMap.containsKey(kTransitionInfoKey));
  bool isAsyncParam(MapEntry<String, dynamic> param) =>
      asyncParams.containsKey(param.key) && param.value is String;
  bool get hasFutures => state.allParams.entries.any(isAsyncParam);
  Future<bool> completeFutures() => Future.wait(
    state.allParams.entries.where(isAsyncParam).map((param) async {
      final doc = await asyncParams[param.key]!(
        param.value,
      ).onError((_, __) => null);
      if (doc != null) {
        futureParamValues[param.key] = doc;
        return true;
      }
      return false;
    }),
  ).onError((_, __) => [false]).then((v) => v.every((e) => e));

  dynamic getParam<T>(String paramName, ParamType type, {bool isList = false}) {
    if (futureParamValues.containsKey(paramName)) {
      return futureParamValues[paramName];
    }
    if (!state.allParams.containsKey(paramName)) {
      return null;
    }
    final param = state.allParams[paramName];
    // Got parameter from `extras`, so just directly return it.
    if (param is! String) {
      return param;
    }
    // Return serialized value.
    return deserializeParam<T>(param, type, isList);
  }
}

class FFRoute {
  const FFRoute({
    required this.name,
    required this.path,
    required this.builder,
    this.requireAuth = false,
    this.asyncParams = const {},
    this.routes = const [],
  });

  final String name;
  final String path;
  final bool requireAuth;
  final Map<String, Future<dynamic> Function(String)> asyncParams;
  final Widget Function(BuildContext, FFParameters) builder;
  final List<GoRoute> routes;

  GoRoute toRoute(AppStateNotifier appStateNotifier) => GoRoute(
    name: name,
    path: path,
    redirect: (context, state) {
      if (appStateNotifier.shouldRedirect) {
        final redirectLocation = appStateNotifier.getRedirectLocation();
        appStateNotifier.clearRedirectLocation();
        return redirectLocation;
      }

      if (requireAuth && !appStateNotifier.loggedIn) {
        appStateNotifier.setRedirectLocationIfUnset(state.uri.toString());
        return '/onBoard';
      }
      return null;
    },
    pageBuilder: (context, state) {
      fixStatusBarOniOS16AndBelow(context);
      final ffParams = FFParameters(state, asyncParams);
      final page = ffParams.hasFutures
          ? FutureBuilder(
              future: ffParams.completeFutures(),
              builder: (context, _) => builder(context, ffParams),
            )
          : builder(context, ffParams);
      // 4.9: the 2.0 splash is painted, so it fits any aspect ratio. The
      // v1 asset was a fixed bitmap stretched with BoxFit.cover, which
      // distorted on anything it was not drawn for.
      final child = appStateNotifier.loading
          ? (kUseEntry2
                ? const SplashView()
                : Container(
                    color: Colors.transparent,
                    child: Image.asset(
                      'assets/images/App_Load_d.png',
                      fit: BoxFit.cover,
                    ),
                  ))
          : page;

      final transitionInfo = state.transitionInfo;
      return transitionInfo.hasTransition
          ? CustomTransitionPage(
              key: state.pageKey,
              name: state.name,
              child: child,
              transitionDuration: transitionInfo.duration,
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) =>
                      PageTransition(
                        type: transitionInfo.transitionType,
                        duration: transitionInfo.duration,
                        reverseDuration: transitionInfo.duration,
                        alignment: transitionInfo.alignment,
                        child: child,
                      ).buildTransitions(
                        context,
                        animation,
                        secondaryAnimation,
                        child,
                      ),
            )
          : MaterialPage(key: state.pageKey, name: state.name, child: child);
    },
    routes: routes,
  );
}

class TransitionInfo {
  const TransitionInfo({
    required this.hasTransition,
    this.transitionType = PageTransitionType.fade,
    this.duration = const Duration(milliseconds: 300),
    this.alignment,
  });

  final bool hasTransition;
  final PageTransitionType transitionType;
  final Duration duration;
  final Alignment? alignment;

  /// A QUICK CROSSFADE, and this is the whole transition policy (4.19f).
  ///
  /// It used to be `hasTransition: false`, which falls through to MaterialPage
  /// - and on iOS that IS the Cupertino push slide. So every screen in the app
  /// flew in from the right by inheritance, not by choice, and screens that
  /// wanted a fade had to hand-roll one (the auth screens all did).
  ///
  /// Fading is right for the default because most navigation here REPLACES
  /// rather than pushes: tab destinations, sign-out, the end of a flow. A
  /// slide implies "you can come back from this", and lying about that is what
  /// made the app feel like a website moving between pages.
  static TransitionInfo appDefault() => const TransitionInfo(
        hasTransition: true,
        transitionType: PageTransitionType.fade,
        duration: Duration(milliseconds: 200),
      );

  /// Slide in from the right. RESERVED for a push with a back affordance and a
  /// parent to return to - the edit screens. Opt in per call site with
  /// [slideInExtra]; anything that does not is a crossfade.
  static TransitionInfo push() => const TransitionInfo(
        hasTransition: true,
        transitionType: PageTransitionType.rightToLeft,
        duration: Duration(milliseconds: 280),
      );
}

/// `extra` that asks a push for the slide instead of the default crossfade.
Map<String, dynamic> slideInExtra() =>
    <String, dynamic>{kTransitionInfoKey: TransitionInfo.push()};

class RootPageContext {
  const RootPageContext(this.isRootPage, [this.errorRoute]);
  final bool isRootPage;
  final String? errorRoute;

  static bool isInactiveRootPage(BuildContext context) {
    final rootPageContext = context.read<RootPageContext?>();
    final isRootPage = rootPageContext?.isRootPage ?? false;
    final location = GoRouterState.of(context).uri.toString();
    return isRootPage &&
        location != '/' &&
        location != rootPageContext?.errorRoute;
  }

  static Widget wrap(Widget child, {String? errorRoute}) =>
      Provider.value(value: RootPageContext(true, errorRoute), child: child);
}

extension GoRouterLocationExtension on GoRouter {
  String getCurrentLocation() {
    final RouteMatch lastMatch = routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }
}

/// Setup into the 2.0 live game flow.
///
/// The flow is pushed rather than replacing this route, so backing out of the
/// tracker returns to setup rather than dumping the parent on the games list
/// with a half-started game.
class _NewGameSetupRoute extends StatelessWidget {
  const _NewGameSetupRoute();

  @override
  Widget build(BuildContext context) {
    return NewGameSetupPage(
      onStart: (setup) => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => LiveGameFlow(
            setup: setup,
            // Finishing leaves the whole flow, setup included: the game is
            // over, and the games list is where it now lives.
            onFinished: () => context.goNamed(AllGamesWidget.routeName),
          ),
        ),
      ),
    );
  }
}
