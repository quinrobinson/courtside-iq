import 'package:provider/provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'auth/supabase_auth/supabase_user_provider.dart';
import 'auth/supabase_auth/auth_util.dart';

import '/backend/supabase/supabase.dart';
import '/courtside_iq/game_sync/supabase_game_uploader.dart';
import '/features/auth/password_recovery_listener.dart';
import '/features/auth/signup_confirmation_listener.dart';
import '/features/dev/token_gallery_page.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'flutter_flow/flutter_flow_util.dart';
import 'flutter_flow/internationalization.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'flutter_flow/nav/nav.dart';
import 'index.dart';
import 'flutter_flow/revenue_cat_util.dart' as revenue_cat;

/// App is a light-mode design: status bar must always show dark (black) icons.
/// FF-generated AppBars flip the overlay style based on their own background,
/// causing time/battery/signal icons to toggle. Setting this at startup and
/// wrapping MaterialApp with AnnotatedRegion pins it globally.
const _lightModeStatusBar = SystemUiOverlayStyle(
  statusBarColor: Colors.transparent,
  statusBarIconBrightness: Brightness.dark, // Android
  statusBarBrightness: Brightness.light,    // iOS
);

/// Dev-only: boot into the design-token gallery instead of the app.
/// Never commit this as true.
const bool kShowTokenGallery = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(_lightModeStatusBar);
  GoRouter.optionURLReflectsImperativeAPIs = true;
  usePathUrlStrategy();

  final environmentValues = FFDevEnvironmentValues();
  await environmentValues.initialize();

  await SupaFlow.initialize();

  final appState = FFAppState(); // Initialize FFAppState
  await appState.initializePersistedState();

  // Phase 4.5: drain any game queued offline, and keep draining whenever
  // connectivity returns. Flushes once immediately so a game saved in a gym
  // last night syncs on launch rather than waiting for a connectivity change.
  gameSyncQueue.startAutoFlush();

  // Phase 4.9: a recovery email opens courtsideiq://reset-password. The
  // Supabase SDK establishes the session; this routes to the reset screen.
  // Started before runApp so a COLD start from the email link is caught.
  PasswordRecoveryListener.instance.start();

  // Phase 4.18: a signup confirmation email opens courtsideiq://login-callback.
  // The SDK would sign the parent straight in; this instead lands them on the
  // sign-in screen (consistent with confirming on another device) with a
  // success toast. Started before runApp so a COLD start from the link is
  // caught.
  SignupConfirmationListener.instance.start();

  await revenue_cat.initialize(
    "appl_qUqQLfzwGyGbActDYFmZwkLAcsP",
    "goog_spQjbEAFjEqPtbbDzXlBbaypJCn",
    debugLogEnabled: false,
    loadDataAfterLaunch: true,
  );

  // Phase 4.7 dev switch: boot straight into the design-token gallery to
  // review tokens visually. MUST be false for any real build - it replaces
  // the entire app. Delete this block once 4B is signed off.
  if (kShowTokenGallery) {
    runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const TokenGalleryPage(),
    ));
    return;
  }

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (context) => appState,
      ),
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class MyAppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  ThemeMode _themeMode = ThemeMode.system;

  late AppStateNotifier _appStateNotifier;
  late GoRouter _router;
  String getRoute([RouteMatch? routeMatch]) {
    final RouteMatch lastMatch =
        routeMatch ?? _router.routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : _router.routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }

  List<String> getRouteStack() =>
      _router.routerDelegate.currentConfiguration.matches
          .map((e) => getRoute(e))
          .toList();
  late Stream<BaseAuthUser> userStream;

  @override
  void initState() {
    super.initState();

    _appStateNotifier = AppStateNotifier.instance;
    _router = createRouter(_appStateNotifier);
    userStream = courtsideIQSupabaseUserStream()
      ..listen((user) {
        _appStateNotifier.update(user);
      });
    jwtTokenStream.listen((_) {});
    Future.delayed(
      Duration(milliseconds: 2500),
      () => _appStateNotifier.stopShowingSplashImage(),
    );
  }

  void setLocale(String language) {
    safeSetState(() => _locale = createLocale(language));
  }

  void setThemeMode(ThemeMode mode) => safeSetState(() {
        _themeMode = mode;
      });

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _lightModeStatusBar,
      child: MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Courtside IQ',
      scrollBehavior: MyAppScrollBehavior(),
      localizationsDelegates: [
        FFLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FallbackMaterialLocalizationDelegate(),
        FallbackCupertinoLocalizationDelegate(),
      ],
      locale: _locale,
      supportedLocales: const [
        Locale('en'),
      ],
      theme: ThemeData(
        brightness: Brightness.light,
        // Pin dark status-bar icons for every AppBar in the app.
        // FF-generated AppBars override the AnnotatedRegion approach, so this
        // ThemeData default is the only reliable place to set it globally.
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark, // Android
            statusBarBrightness: Brightness.light,    // iOS
          ),
        ),
        scrollbarTheme: ScrollbarThemeData(
          thumbVisibility: MaterialStateProperty.all(false),
        ),
      ),
      themeMode: _themeMode,
      routerConfig: _router,
      ),
    );
  }
}
