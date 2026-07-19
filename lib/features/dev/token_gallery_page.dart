// Token gallery — Phase 4.7 verification surface.
//
// Renders every design token at real size so they can be judged visually
// before components are built on top of them. Dev-only: not routed from any
// user-facing screen.
//
// The mode toggle rebuilds the subtree under a full CiTheme, so what you see
// is exactly what a real screen would get - not a preview approximation.

import 'package:flutter/material.dart';

import '/courtside_iq/design/ci_theme.dart';
import '/courtside_iq/design/tokens/ci_colors.dart';
import '/courtside_iq/design/tokens/ci_metrics.dart';
import '/courtside_iq/design/tokens/ci_type.dart';
import '/courtside_iq/design/components/dot_burst.dart';
import '/courtside_iq/design/components/dot_gauge.dart';

class TokenGalleryPage extends StatefulWidget {
  const TokenGalleryPage({super.key});

  @override
  State<TokenGalleryPage> createState() => _TokenGalleryPageState();
}

class _TokenGalleryPageState extends State<TokenGalleryPage> {
  bool _dark = true;

  @override
  Widget build(BuildContext context) {
    final theme = _dark ? CiTheme.dark() : CiTheme.light();

    return Theme(
      data: theme,
      child: Builder(
        builder: (context) {
          final c = CiColors.of(context);
          return Scaffold(
            backgroundColor: c.bg,
            body: SafeArea(
              child: Column(
                children: [
                  _Header(
                    dark: _dark,
                    onToggle: () => setState(() => _dark = !_dark),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.only(bottom: CiSpace.s16),
                      children: const [
                        _ComponentSection(),
                        _ColorSection(),
                        _TypeSection(),
                        _RadiusSection(),
                        _SpacingSection(),
                        _RuleSection(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.dark, required this.onToggle});

  final bool dark;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          CiSpace.screen, CiSpace.s5, CiSpace.screen, CiSpace.s4),
      child: Row(
        children: [
          Expanded(
            child: Text('Design tokens',
                style: CiType.h2.copyWith(color: c.text)),
          ),
          GestureDetector(
            onTap: onToggle,
            child: Container(
              height: CiSpace.hitMin,
              padding: const EdgeInsets.symmetric(horizontal: CiSpace.s4),
              decoration: BoxDecoration(
                color: c.surfaceSunk,
                borderRadius: CiRadius.pillR,
                border: Border.all(color: c.border),
              ),
              alignment: Alignment.center,
              child: Text(dark ? 'Dark' : 'Light',
                  style: CiType.rowLabel.copyWith(color: c.text)),
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-bleed hairline. Never inset — this is the locked treatment.
class _Hairline extends StatelessWidget {
  const _Hairline();

  @override
  Widget build(BuildContext context) => Container(
        height: CiSpace.hairline,
        color: CiColors.of(context).hairline,
      );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          CiSpace.screen, CiSpace.s8, CiSpace.screen, CiSpace.s3),
      child: Text(label.toUpperCase(),
          style: CiType.label.copyWith(color: c.textMuted)),
    );
  }
}

// --- Colors ------------------------------------------------------------------

class _ColorSection extends StatelessWidget {
  const _ColorSection();

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionTitle('Semantic colors'),
        const _Hairline(),
        _Swatch('bg', c.bg, c),
        _Swatch('surface', c.surface, c),
        _Swatch('surface-sunk', c.surfaceSunk, c),
        _Swatch('surface-invert', c.surfaceInvert, c),
        _Swatch('surface-deep', c.surfaceDeep, c,
            note: 'dark inputs + premium banners only'),
        const _Hairline(),
        _Swatch('text', c.text, c),
        _Swatch('text-muted', c.textMuted, c),
        _Swatch('text-faint', c.textFaint, c),
        const _Hairline(),
        _Swatch('border', c.border, c),
        _Swatch('border-strong', c.borderStrong, c),
        _Swatch('hairline', c.hairline, c),
        const _Hairline(),
        _Swatch('accent-good', c.accentGood, c, note: 'lime'),
        _Swatch('accent-good-wash', c.accentGoodWash, c),
        _Swatch('accent-energy', c.accentEnergy, c, note: 'orange'),
        _Swatch('accent-energy-wash', c.accentEnergyWash, c),
        const _Hairline(),
        const _OnAccentProof(),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch(this.name, this.color, this.c, {this.note});

  final String name;
  final Color color;
  final CiColors c;
  final String? note;

  String get _hex =>
      '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: CiSpace.screen, vertical: CiSpace.s2),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color,
              borderRadius: CiRadius.controlR,
              // Bordered so white-on-white and ink-on-ink stay visible.
              border: Border.all(color: c.border),
            ),
          ),
          const SizedBox(width: CiSpace.s4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: CiType.rowTitle.copyWith(color: c.text)),
                if (note != null)
                  Text(note!,
                      style: CiType.caption.copyWith(color: c.textFaint)),
              ],
            ),
          ),
          Text(_hex, style: CiType.caption.copyWith(color: c.textMuted)),
        ],
      ),
    );
  }
}

/// Proves the locked rule: content on an accent is ALWAYS ink, never white.
class _OnAccentProof extends StatelessWidget {
  const _OnAccentProof();

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    Widget pill(Color bg, String label) => Container(
          padding: const EdgeInsets.symmetric(
              horizontal: CiSpace.s4, vertical: CiSpace.s2),
          decoration:
              BoxDecoration(color: bg, borderRadius: CiRadius.pillR),
          child: Text(label,
              style: CiType.rowLabel.copyWith(color: c.onAccent)),
        );

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          CiSpace.screen, CiSpace.s4, CiSpace.screen, CiSpace.s2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('on-accent is ink on BOTH accents',
              style: CiType.caption.copyWith(color: c.textFaint)),
          const SizedBox(height: CiSpace.s2),
          Row(children: [
            pill(c.accentGood, 'Rising +5'),
            const SizedBox(width: CiSpace.s2),
            pill(c.accentEnergy, 'Room to grow'),
          ]),
        ],
      ),
    );
  }
}

// --- Type --------------------------------------------------------------------

class _TypeSection extends StatelessWidget {
  const _TypeSection();

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);

    Widget row(String name, TextStyle style, {String sample = 'Jada White'}) {
      return Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: CiSpace.screen, vertical: CiSpace.s2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$name · ${style.fontSize?.toStringAsFixed(style.fontSize! % 1 == 0 ? 0 : 1)}'
              '/${_weightName(style.fontWeight)}',
              style: CiType.caption.copyWith(color: c.textFaint),
            ),
            const SizedBox(height: 2),
            Text(sample, style: style.copyWith(color: c.text)),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionTitle('Type · canonical'),
        const _Hairline(),
        row('statXl', CiType.statXl, sample: '72'),
        row('statLg', CiType.statLg, sample: '72'),
        row('statMd', CiType.statMd, sample: '72'),
        row('statSm', CiType.statSm, sample: '72'),
        row('display', CiType.display, sample: 'See how they grow'),
        row('name', CiType.name),
        row('h1', CiType.h1, sample: 'Development'),
        row('h2', CiType.h2, sample: 'Development'),
        row('h3', CiType.h3, sample: "What's working"),
        row('h4', CiType.h4, sample: "What's working"),
        row('body', CiType.body,
            sample: 'Jada is finishing better inside and getting to the line.'),
        row('bodySm', CiType.bodySm,
            sample: 'Jada is finishing better inside and getting to the line.'),
        row('bodyXs', CiType.bodyXs,
            sample: 'Jada is finishing better inside and getting to the line.'),
        row('label', CiType.label, sample: 'SCORING EFFICIENCY'),
        row('unit', CiType.unit, sample: 'pts'),
        const _SectionTitle('Type · in use on screens'),
        const _Hairline(),
        row('micro', CiType.micro, sample: 'Players'),
        row('chipLabel', CiType.chipLabel, sample: 'Last 5'),
        row('caption', CiType.caption, sample: 'vs Bears Elite'),
        row('labelTight', CiType.labelTight, sample: 'Guard · U14'),
        row('rowTitle', CiType.rowTitle),
        row('rowLabel', CiType.rowLabel, sample: 'See plans'),
        row('labelStrong', CiType.labelStrong, sample: 'PREMIUM'),
        row('statInline', CiType.statInline, sample: '0.95'),
        row('statInlineLg', CiType.statInlineLg, sample: '0.95'),
        row('sectionTitle', CiType.sectionTitle, sample: 'Averages'),
        row('badge', CiType.badge, sample: 'NEW'),
      ],
    );
  }

  static String _weightName(FontWeight? w) => switch (w) {
        FontWeight.w300 => 'Light',
        FontWeight.w400 => 'Regular',
        FontWeight.w500 => 'Medium',
        FontWeight.w600 => 'SemiBold',
        FontWeight.w700 => 'Bold',
        FontWeight.w800 => 'ExtraBold',
        _ => '?',
      };
}

// --- Radius ------------------------------------------------------------------

class _RadiusSection extends StatelessWidget {
  const _RadiusSection();

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    Widget box(String name, double r) => Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: c.surfaceSunk,
                borderRadius: BorderRadius.circular(r),
                border: Border.all(color: c.border),
              ),
            ),
            const SizedBox(height: CiSpace.s1),
            Text(name, style: CiType.caption.copyWith(color: c.textMuted)),
            Text(r >= 999 ? 'pill' : r.toStringAsFixed(0),
                style: CiType.caption.copyWith(color: c.textFaint)),
          ],
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionTitle('Radius'),
        const _Hairline(),
        Padding(
          padding: const EdgeInsets.all(CiSpace.screen),
          child: Wrap(
            spacing: CiSpace.s4,
            runSpacing: CiSpace.s4,
            children: [
              box('chip', CiRadius.chip),
              box('control', CiRadius.control),
              box('sheet', CiRadius.sheet),
              box('dialog', CiRadius.dialog),
              box('pill', CiRadius.pill),
            ],
          ),
        ),
      ],
    );
  }
}

// --- Spacing -----------------------------------------------------------------

class _SpacingSection extends StatelessWidget {
  const _SpacingSection();

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    Widget bar(String name, double v) => Padding(
          padding: const EdgeInsets.symmetric(vertical: CiSpace.s1),
          child: Row(
            children: [
              SizedBox(
                width: 92,
                child: Text(name,
                    style: CiType.caption.copyWith(color: c.textMuted)),
              ),
              Container(height: 12, width: v, color: c.accentGood),
              const SizedBox(width: CiSpace.s2),
              Text(v.toStringAsFixed(0),
                  style: CiType.caption.copyWith(color: c.textFaint)),
            ],
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionTitle('Spacing'),
        const _Hairline(),
        Padding(
          padding: const EdgeInsets.all(CiSpace.screen),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              bar('s1', CiSpace.s1),
              bar('s2', CiSpace.s2),
              bar('s3', CiSpace.s3),
              bar('s4 / cardSm', CiSpace.s4),
              bar('s5', CiSpace.s5),
              bar('s6 / screen', CiSpace.s6),
              bar('s7 / cardLg', CiSpace.s7),
              bar('s8', CiSpace.s8),
              bar('hitMin', CiSpace.hitMin),
              bar('s9', CiSpace.s9),
              bar('s10', CiSpace.s10),
              bar('s12', CiSpace.s12),
              bar('tabBar', CiSpace.tabBar),
            ],
          ),
        ),
      ],
    );
  }
}

// --- Locked rules ------------------------------------------------------------

/// Renders the rules that are easy to violate, so a break is visible.
class _RuleSection extends StatelessWidget {
  const _RuleSection();

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionTitle('Locked rules'),
        const _Hairline(),
        Padding(
          padding: const EdgeInsets.fromLTRB(
              CiSpace.screen, CiSpace.s4, CiSpace.screen, CiSpace.s2),
          child: Text('Hairlines are full-bleed. The lines above and below this '
              'block touch both edges; content sits on the 24px gutter.',
              style: CiType.bodySm.copyWith(color: c.textMuted)),
        ),
        const _Hairline(),
        Padding(
          padding: const EdgeInsets.all(CiSpace.screen),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('surface-deep vs bg',
                  style: CiType.h4.copyWith(color: c.text)),
              const SizedBox(height: CiSpace.s2),
              Text('The band below is surface-deep (#000000) on the screen '
                  'background. In dark mode it should read as deeper, not '
                  'identical. If you cannot tell them apart, that is the '
                  'finding.',
                  style: CiType.bodySm.copyWith(color: c.textMuted)),
              const SizedBox(height: CiSpace.s3),
              Container(
                height: 72,
                decoration: BoxDecoration(
                  color: c.surfaceDeep,
                  borderRadius: CiRadius.controlR,
                ),
                alignment: Alignment.center,
                child: Text('Unlock Premium',
                    style: CiType.rowLabel.copyWith(color: CiPalette.white)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}


// --- Components --------------------------------------------------------------

class _ComponentSection extends StatefulWidget {
  const _ComponentSection();

  @override
  State<_ComponentSection> createState() => _ComponentSectionState();
}

class _ComponentSectionState extends State<_ComponentSection> {
  double _v = 0.833; // the value the Figma component renders: 25/30 and 20/24

  @override
  Widget build(BuildContext context) {
    final c = CiColors.of(context);
    final score = (40 + _v * 59).round(); // Growth IQ display scale

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionTitle('DotGauge'),
        const _Hairline(),
        Padding(
          padding: const EdgeInsets.all(CiSpace.screen),
          child: Column(
            children: [
              Center(
                child: DotGauge(
                  value: _v,
                  size: 168,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('$score',
                          style: CiType.statMd.copyWith(color: c.text)),
                      Text('GROWTH IQ',
                          style: CiType.label.copyWith(color: c.textMuted)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: CiSpace.s5),
              Row(children: [
                Text('${(_v * 100).round()}%',
                    style: CiType.caption.copyWith(color: c.textMuted)),
                Expanded(
                  child: Slider(
                    value: _v,
                    activeColor: c.accentGood,
                    onChanged: (x) => setState(() => _v = x),
                  ),
                ),
              ]),
              const SizedBox(height: CiSpace.s4),
              // Small inline sizes, to check it still reads when shrunk.
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  DotGauge(value: _v, size: 72),
                  DotGauge(
                      value: _v, size: 56, rings: DotGaugeRings.compact),
                  DotGauge(
                      value: _v, size: 44, rings: DotGaugeRings.compact),
                ],
              ),
            ],
          ),
        ),
        const _SectionTitle('DotBurst'),
        const _Hairline(),
        Container(
          height: 300,
          color: c.bg,
          alignment: Alignment.center,
          child: DotBurst(
            size: 300,
            innerRadius: 52,
            ringGap: 26,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: c.surfaceDeep,
                borderRadius: CiRadius.pillR,
              ),
              alignment: Alignment.center,
              child: Text('CIQ',
                  style: CiType.labelStrong.copyWith(color: c.accentGood)),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
              CiSpace.screen, CiSpace.s3, CiSpace.screen, CiSpace.s2),
          child: Text(
              'Ring sizes and opacities are measured from Splash and exact. '
              'Ring RADII are tuned by eye - compare against the Figma frame '
              'and adjust innerRadius / ringGap if the spread looks wrong.',
              style: CiType.bodyXs.copyWith(color: c.textFaint)),
        ),
      ],
    );
  }
}
