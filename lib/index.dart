// Route names and paths — the v1 registry, kept after the v1 screens died.
//
// Until 4.24 this file exported the FlutterFlow widgets, and the app read
// `routeName`/`routePath` off those classes. The screens are gone, but the
// NAMES are load-bearing: they are the route table's identity, every
// `goNamed` in the app, and the deep-link paths a shipped build already
// responds to. So the classes survive as empty holders carrying the same
// constants under the same class names - every call site compiles unchanged,
// and the URLs a v1 install knows keep working in 2.0.
//
// These are not widgets and must never be constructed; `abstract final`
// enforces that at compile time.

abstract final class HomeWidget {
  static const String routeName = 'Home';
  static const String routePath = '/home';
}

abstract final class PlayersListWidget {
  static const String routeName = 'PlayersList';
  static const String routePath = '/playerList';
}

abstract final class PlayersProfileWidget {
  static const String routeName = 'PlayersProfile';
  static const String routePath = '/playersProfile';
}

abstract final class AllGamesWidget {
  static const String routeName = 'AllGames';
  static const String routePath = '/allGames';
}

abstract final class MenuWidget {
  static const String routeName = 'Menu';
  static const String routePath = '/menu';
}

abstract final class OnBoardWidget {
  static const String routeName = 'OnBoard';
  static const String routePath = '/onBoard';
}

abstract final class UserAuthWidget {
  static const String routeName = 'UserAuth';
  static const String routePath = '/userAuth';
}

abstract final class UserAuthEmailWidget {
  static const String routeName = 'UserAuthEmail';
  static const String routePath = '/userAuthEmail';
}

abstract final class ForgotPasswordWidget {
  static const String routeName = 'ForgotPassword';
  static const String routePath = '/forgotpassword';
}

abstract final class ResetPasswordWidget {
  static const String routeName = 'ResetPassword';
  static const String routePath = '/resetPassword';
}

abstract final class ResetSuccesfulWidget {
  static const String routeName = 'ResetSuccesful';
  static const String routePath = '/resetSuccesful';
}

abstract final class NewGameWidget {
  static const String routeName = 'NewGame';
  static const String routePath = '/newGame';
}

abstract final class GameStatsWidget {
  static const String routeName = 'GameStats';
  static const String routePath = '/gameStats';
}

abstract final class YourProfileWidget {
  static const String routeName = 'YourProfile';
  static const String routePath = '/yourProfile';
}

abstract final class EditNameWidget {
  static const String routeName = 'EditName';
  static const String routePath = '/editName';
}

abstract final class EditEmailWidget {
  static const String routeName = 'EditEmail';
  static const String routePath = '/editEmail';
}

abstract final class HelpCenterWidget {
  static const String routeName = 'HelpCenter';
  static const String routePath = '/helpCenter';
}

abstract final class SendFeedbackWidget {
  static const String routeName = 'SendFeedback';
  static const String routePath = '/sendFeedback';
}
