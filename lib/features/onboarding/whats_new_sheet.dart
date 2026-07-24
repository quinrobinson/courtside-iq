// "What's new in 2.0" upgrade sheet — Phase 4.19c
//
// A one-time dark takeover for EXISTING v1 users landing on 2.0 for the first
// time. Reassurance leads (nothing you logged is lost), then the four features
// worth opening the app for. Authored in Figma on the Screens page (892:3184).
//
// A PURE RENDERER. It shows and dismisses itself; remembering that it was seen
// is the gate's job (whats_new_gate.dart), so this widget carries no storage
// and no policy. Dismissing any way - "Got it" or a swipe down - completes the
// showWhatsNew2 future, and the gate marks it seen either way.
//
// REUSES THE REAL MARKS, never a lookalike. The hero is the actual DotBurst +
// CiLogoMark (the Splash/paywall brand moment), the development-story row wears
// the CiSpark that means "Claude read this" everywhere else, and the tracker
// row wears the Games nav glyph a parent taps in the bar. Only the shield and
// gauge are drawn here, inline, in the same 1.75 monochrome language.

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '/courtside_iq/design/ci_theme.dart';
import '/courtside_iq/design/components/ci_button.dart';
import '/courtside_iq/design/components/ci_logo_mark.dart';
import '/courtside_iq/design/components/ci_nav_icon.dart';
import '/courtside_iq/design/components/ci_sheet.dart';
import '/courtside_iq/design/components/ci_spark.dart';
import '/courtside_iq/design/components/dot_burst.dart';
import '/courtside_iq/design/tokens/ci_colors.dart';
import '/courtside_iq/design/tokens/ci_metrics.dart';
import '/courtside_iq/design/tokens/ci_type.dart';

/// Presents the upgrade sheet. Completes when it is dismissed, however that
/// happens - the caller (the gate) marks it seen on completion.
Future<void> showWhatsNew2(BuildContext context) {
  return showCiSheet<void>(context, child: const CiWhatsNewSheet());
}

class CiWhatsNewSheet extends StatelessWidget {
  const CiWhatsNewSheet({super.key});

  @override
  Widget build(BuildContext context) {
    // Capped so the tall content scrolls on a small phone instead of running
    // off the top, while the "Got it" button stays pinned and reachable.
    final maxHeight = MediaQuery.sizeOf(context).height * 0.92;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: CiSurface.ink(
        child: Builder(builder: (context) {
          final c = CiColors.of(context);
          return SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                        CiSpace.screen, 0, CiSpace.screen, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const CiSheetHandle(),
                        const SizedBox(height: CiSpace.s2),
                        // The brand hero: real burst geometry, logo mark centred,
                        // its own soft haze behind the dots.
                        const SizedBox(
                          height: 184,
                          child: Center(
                            child: DotBurst(
                              size: 184,
                              markSize: 46,
                              child: CiLogoMark(size: 46),
                            ),
                          ),
                        ),
                        const SizedBox(height: CiSpace.s6),
                        Text(
                          'The new Courtside IQ',
                          textAlign: TextAlign.center,
                          style: CiType.sectionTitle
                              .copyWith(color: c.text, fontWeight: CiWeight.bold),
                        ),
                        const SizedBox(height: CiSpace.s2),
                        Text(
                          'Fresh look and new ways to track player growth.',
                          textAlign: TextAlign.center,
                          style: CiType.bodySm.copyWith(color: c.textMuted),
                        ),
                        const SizedBox(height: CiSpace.s7),
                        _Feature(
                          glyph: _svgGlyph(_shield, c.text),
                          title: "Everything's safe",
                          body: "Every player, game, and stat you've logged is "
                              "right where you left it.",
                        ),
                        const SizedBox(height: CiSpace.s5),
                        _Feature(
                          glyph: _svgGlyph(_gauge, c.text),
                          title: 'Growth IQ',
                          body: 'One age-adjusted score for how each player is '
                              'developing.',
                        ),
                        const SizedBox(height: CiSpace.s5),
                        _Feature(
                          // The AI mark, kept to the AI feature.
                          glyph: CiSpark(size: 24, color: c.text),
                          title: 'Development story',
                          body: 'After a few games, a written read on how your '
                              'player is growing.',
                        ),
                        const SizedBox(height: CiSpace.s5),
                        _Feature(
                          glyph: CiNavIconGlyph(
                              icon: CiNavIcon.games, color: c.text, size: 24),
                          title: 'A faster live tracker',
                          body: 'Log a game quickly, with just the stats that '
                              'matter.',
                        ),
                        const SizedBox(height: CiSpace.s7),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    CiSpace.screen,
                    CiSpace.s2,
                    CiSpace.screen,
                    CiSpace.s6,
                  ),
                  child: CiButton(
                    label: 'Got it',
                    style: CiButtonStyle.lime,
                    expand: true,
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

/// A tinted 24pt glyph centred in the 48 sunk tile the rows share.
Widget _svgGlyph(String svg, Color color) => SizedBox(
      width: 24,
      height: 24,
      child: SvgPicture.string(
        svg,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      ),
    );

class _Feature extends StatelessWidget {
  const _Feature({required this.glyph, required this.title, required this.body});

  final Widget glyph;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: c.surfaceSunk,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: c.border),
          ),
          child: glyph,
        ),
        const SizedBox(width: CiSpace.s4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 2),
              Text(title, style: CiType.rowTitle.copyWith(color: c.text)),
              const SizedBox(height: 3),
              Text(body, style: CiType.bodyXs.copyWith(color: c.textMuted)),
            ],
          ),
        ),
      ],
    );
  }
}

// Drawn here because they are not part of the nav set: the same 24-box, 1.75
// stroke, rounded-join language as CiNavIcon so they sit beside it cleanly.
const String _shield =
    '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" '
    'xmlns="http://www.w3.org/2000/svg">'
    '<path d="M12 3L19 5.4V11C19 15.4 16.1 18.8 12 20.2C7.9 18.8 5 15.4 5 11V5.4L12 3Z" '
    'stroke="#FFFFFF" stroke-width="1.75" stroke-linejoin="round"/>'
    '<path d="M9 11.6L11.1 13.7L15 9.4" stroke="#FFFFFF" stroke-width="1.75" '
    'stroke-linecap="round" stroke-linejoin="round"/></svg>';

const String _gauge =
    '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" '
    'xmlns="http://www.w3.org/2000/svg">'
    '<path d="M4 16A8 8 0 0 1 20 16" stroke="#FFFFFF" stroke-width="1.75" '
    'stroke-linecap="round"/>'
    '<path d="M12 16L16 10.6" stroke="#FFFFFF" stroke-width="1.75" '
    'stroke-linecap="round"/>'
    '<circle cx="12" cy="16" r="1.5" fill="#FFFFFF"/></svg>';
