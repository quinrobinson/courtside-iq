// Help Center — Phase 4.15c
//
// Measured from 507:1964: sub-page header, an accordion of questions at
// SemiBold 17 in 56pt rows, the open one showing its answer at Regular 15
// beneath, then "Still need help? Send us a note." centred at Medium 15.
//
// ONE OPEN AT A TIME. The frame draws exactly one expanded, and with answers
// this long a screen where every row is open is a wall of text with no shape.
// Opening a second closes the first.
//
// NOTHING IS OPEN ON ARRIVAL, which differs from the frame. The frame has to
// show an expanded state to communicate the pattern; a real parent arriving
// with a question wants to see the LIST, and an answer already open pushes
// five of the eight questions off screen.

import 'package:flutter/material.dart';

import '/courtside_iq/design/ci_theme.dart';
import '/courtside_iq/design/components/ci_segmented_tabs.dart';
import '/courtside_iq/design/components/ci_sub_page_header.dart';
import '/courtside_iq/design/tokens/ci_colors.dart';
import '/courtside_iq/design/tokens/ci_metrics.dart';
import '/courtside_iq/design/tokens/ci_type.dart';
import '/courtside_iq/help_content.dart';

class HelpCenterPage extends StatefulWidget {
  const HelpCenterPage({super.key, this.onSendFeedback});

  final VoidCallback? onSendFeedback;

  @override
  State<HelpCenterPage> createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends State<HelpCenterPage> {
  int? _open;

  @override
  Widget build(BuildContext context) {
    return CiSurface.light(
      child: Builder(builder: (context) {
        final c = CiColors.of(context);
        return Scaffold(
          backgroundColor: c.bg,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                const CiSubPageHeader(title: 'Help Center'),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      for (var i = 0; i < kHelpTopics.length; i++) ...[
                        _TopicRow(
                          topic: kHelpTopics[i],
                          open: _open == i,
                          onTap: () =>
                              setState(() => _open = _open == i ? null : i),
                        ),
                        const CiHairline(),
                      ],
                      const SizedBox(height: CiSpace.s6),
                      Semantics(
                        button: true,
                        label: 'Send us a note',
                        container: true,
                        excludeSemantics: true,
                        child: InkWell(
                          onTap: widget.onSendFeedback,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: CiSpace.s3),
                            child: Text(
                              kHelpFooterPrompt,
                              textAlign: TextAlign.center,
                              style: CiType.body.copyWith(color: c.textMuted),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: CiSpace.s8),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _TopicRow extends StatelessWidget {
  const _TopicRow({
    required this.topic,
    required this.open,
    required this.onTap,
  });

  final HelpTopic topic;
  final bool open;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return Semantics(
      button: true,
      // The whole row is one target, and a screen reader should hear the
      // question plus its state rather than the answer's first words.
      label: '${topic.question}, ${open ? 'expanded' : 'collapsed'}',
      container: true,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: CiSpace.screen),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 56,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        topic.question,
                        style: CiType.rowTitle.copyWith(
                            color: c.text, fontWeight: CiWeight.semiBold),
                      ),
                    ),
                    const SizedBox(width: CiSpace.s3),
                    // Rotates rather than swapping glyphs, so the control
                    // reads as the same thing in two states.
                    AnimatedRotation(
                      turns: open ? 0.25 : 0,
                      duration: const Duration(milliseconds: 160),
                      child: Icon(Icons.chevron_right,
                          size: 18, color: c.textMuted),
                    ),
                  ],
                ),
              ),
              if (open)
                Padding(
                  padding: const EdgeInsets.only(bottom: CiSpace.s5),
                  child: Text(
                    topic.answer,
                    style: CiType.body.copyWith(color: c.textSoft, height: 1.5),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
