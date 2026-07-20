// AuthScaffold — Phase 4.9
//
// The layout shared by Forgot Password, Reset Password and Reset Successful:
// ink ground, a back button, left-aligned title and subhead, content, and a
// primary action PINNED TO THE BOTTOM with an optional text link beneath it.
//
// The bottom pin is the part worth extracting. On these three frames the CTA
// sits at the bottom of the screen rather than flowing directly after the
// fields, so it stays reachable one-handed no matter how little content is
// above it. Reproducing that by hand three times is how three screens end up
// with three slightly different bottom paddings.
//
// Still scrolls: with a keyboard open on a small device the content must not
// overflow, and the action must not be stranded behind the keyboard.

import 'package:flutter/material.dart';

import '/courtside_iq/design/ci_theme.dart';
import '/courtside_iq/design/components/ci_avatar.dart';
import '/courtside_iq/design/components/ci_button.dart';
import '/courtside_iq/design/tokens/ci_colors.dart';
import '/courtside_iq/design/tokens/ci_metrics.dart';
import '/courtside_iq/design/tokens/ci_type.dart';

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    this.title,
    this.subtitle,
    this.header,
    this.centerText = false,
    required this.children,
    required this.actionLabel,
    required this.onAction,
    this.actionBusy = false,
    this.linkLabel,
    this.onLink,
    this.onBack,
  });

  /// Rendered as h1. Null on screens whose header carries the message.
  final String? title;
  final String? subtitle;

  /// Sits above the title, e.g. the dot burst on Reset Successful.
  final Widget? header;

  /// Reset Successful centres its text; the form screens are left-aligned.
  final bool centerText;

  final List<Widget> children;

  final String actionLabel;

  /// Null disables the action. There is no separate enabled flag.
  final VoidCallback? onAction;
  final bool actionBusy;

  /// Optional text link under the action, e.g. "Back to sign in".
  final String? linkLabel;
  final VoidCallback? onLink;

  /// Defaults to popping. Pass one when back means something specific.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return CiSurface.ink(
      statusBar: true,
      child: Builder(builder: (context) {
        final c = CiColors.of(context);
        final align =
            centerText ? CrossAxisAlignment.center : CrossAxisAlignment.start;
        final textAlign = centerText ? TextAlign.center : TextAlign.start;

        return Scaffold(
          backgroundColor: c.bg,
          body: SafeArea(
            child: LayoutBuilder(builder: (context, constraints) {
              return SingleChildScrollView(
                // Fills the viewport so the action can sit at the bottom, but
                // still scrolls once the keyboard shrinks it.
                child: ConstrainedBox(
                  constraints:
                      BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(CiSpace.screen,
                          CiSpace.s3, CiSpace.screen, CiSpace.s6),
                      child: Column(
                        crossAxisAlignment: align,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: CiIconButton(
                              icon: Icons.chevron_left,
                              onDark: true,
                              semanticLabel: 'Back',
                              onPressed:
                                  onBack ?? () => Navigator.of(context).maybePop(),
                            ),
                          ),
                          if (header != null) ...[
                            const SizedBox(height: CiSpace.s6),
                            header!,
                          ],
                          const SizedBox(height: CiSpace.s8),
                          if (title != null)
                            Text(title!,
                                textAlign: textAlign,
                                style: CiType.h1.copyWith(color: c.text)),
                          if (subtitle != null) ...[
                            const SizedBox(height: CiSpace.s2),
                            Text(subtitle!,
                                textAlign: textAlign,
                                style:
                                    CiType.body.copyWith(color: c.textMuted)),
                          ],
                          const SizedBox(height: CiSpace.s7),
                          ...children,

                          // Pushes the action to the bottom when there is room
                          // and collapses to nothing when there is not.
                          const Spacer(),
                          const SizedBox(height: CiSpace.s6),
                          CiButton(
                            label: actionLabel,
                            style: CiButtonStyle.lime,
                            expand: true,
                            busy: actionBusy,
                            onPressed: onAction,
                          ),
                          if (linkLabel != null) ...[
                            const SizedBox(height: CiSpace.s2),
                            Center(
                              child: GestureDetector(
                                onTap: onLink,
                                behavior: HitTestBehavior.opaque,
                                child: Semantics(
                                  button: true,
                                  child: Padding(
                                    // Padded to a real touch target; the label
                                    // alone is well under 44pt tall.
                                    padding: const EdgeInsets.symmetric(
                                        vertical: CiSpace.s3,
                                        horizontal: CiSpace.s4),
                                    child: Text(linkLabel!,
                                        style: CiType.body
                                            .copyWith(color: c.textMuted)),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }
}
