// CiOfflineBanner — the connectivity bar. Phase 4.18
//
// Measured from offline-banner (654:2378): ink #0f0f0f, 8pt orange dot, one
// line of gray 13 Medium, 24 gutter, 10 vertical.
//
// FIXED DARK, GROUND-INDEPENDENT, like the toast. It reads on any screen and
// does not follow the ground beneath it. The ink extends UNDER the status bar
// (the SafeArea insets only the content), so the bar is one solid strip rather
// than a floating band with a gap above it - the caller pairs it with a light
// status-bar overlay so the icons stay visible on the ink.
//
// ONE VISUAL, TWO MESSAGES: the general "reconnect to use the app" while
// browsing, and the live tracker's "stats are saved, sync when you reconnect".

import 'package:flutter/material.dart';

import '../tokens/ci_colors.dart';
import '../tokens/ci_metrics.dart';
import '../tokens/ci_type.dart';

class CiOfflineBanner extends StatelessWidget {
  const CiOfflineBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: CiPalette.inkDefault,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: CiSpace.screen, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                    color: CiPalette.orange, shape: BoxShape.circle),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: CiType.bodyXs.copyWith(
                      color: CiPalette.gray300, fontWeight: CiWeight.medium),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
