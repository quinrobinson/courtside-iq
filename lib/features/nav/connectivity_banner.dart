// Connectivity banner wrapper — Phase 4.18
//
// Courtside IQ needs a connection, like most social apps: browsing games and
// players, and starting a game, all read the server. So when the phone goes
// offline this shows a persistent bar at the top telling the parent to
// reconnect - honest, rather than controls that fail silently.
//
// SCOPED TO THE SHELL DELIBERATELY. It wraps the shell body, so it shows over
// the browsing screens (Today, Players, Games, Menu, Player Profile) but NOT
// over the live tracker, which is pushed on the ROOT navigator over the shell.
// That is the one offline-tolerant flow - a game already in progress keeps
// tracking and saves locally - and its own "stats are saved" message would
// contradict a "reconnect to use the app" bar.

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '/courtside_iq/design/ci_theme.dart';
import '/courtside_iq/design/components/ci_offline_banner.dart';

/// The general copy, for the browsing case. The live tracker uses its own.
const String kOfflineBannerMessage =
    "You're offline. Reconnect to use Courtside IQ.";

class ConnectivityBanner extends StatefulWidget {
  const ConnectivityBanner({
    super.key,
    required this.child,
    this.message = kOfflineBannerMessage,
    this.connectivity,
  });

  final Widget child;
  final String message;

  /// Injectable so a test can drive it without a device.
  final Connectivity? connectivity;

  @override
  State<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends State<ConnectivityBanner> {
  bool _offline = false;
  StreamSubscription<List<ConnectivityResult>>? _sub;

  @override
  void initState() {
    super.initState();
    _watch();
  }

  Future<void> _watch() async {
    final conn = widget.connectivity ?? Connectivity();
    void apply(List<ConnectivityResult> results) {
      final off = results.every((r) => r == ConnectivityResult.none);
      if (mounted && off != _offline) setState(() => _offline = off);
    }

    try {
      apply(await conn.checkConnectivity());
      _sub = conn.onConnectivityChanged.listen(apply);
    } catch (_) {
      // No connectivity plugin on this platform is not a reason to block the
      // app: assume online, and let per-action failures speak for themselves.
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_offline) return widget.child;
    // Light status-bar icons over the ink bar; the bar pushes the screen down
    // rather than floating over it.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: CiSystemUi.onInk,
      child: Column(
        children: [
          CiOfflineBanner(message: widget.message),
          Expanded(child: widget.child),
        ],
      ),
    );
  }
}
