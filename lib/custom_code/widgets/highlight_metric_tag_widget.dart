// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/custom_icons.dart';

const Map<String, String> _kHighlightMetricLabels = {
  'ppsa': 'Scoring',
  'ast_tov': 'Playmaking',
  'disrupt': 'Defense',
  'effort': 'Hustle',
  'consistency': 'Consistency',
};

class HighlightMetricTagWidget extends StatelessWidget {
  const HighlightMetricTagWidget({
    super.key,
    this.width,
    this.height,
    this.highlightMetric,
  });

  final double? width;
  final double? height;
  final String? highlightMetric;

  @override
  Widget build(BuildContext context) {
    final label = _kHighlightMetricLabels[highlightMetric];
    if (label == null) return const SizedBox.shrink();

    return Container(
      height: 24,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEDE9FE),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            FFIcons.kaiSpark,
            size: 14,
            color: Color(0xFF6D28D9),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: GoogleFonts.ibmPlexSans().fontFamily,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
              color: const Color(0xFF5B21B6),
            ),
          ),
        ],
      ),
    );
  }
}
