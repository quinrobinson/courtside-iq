import '/courtside_iq/design_tokens.dart';
import 'package:flutter/material.dart';

class TrendPill extends StatelessWidget {
  const TrendPill({super.key, required this.direction});

  final String? direction;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (direction) {
      'improving' => ('↑ Improving', CIColors.jade500),
      'declining' => ('↓ Cooling', CIColors.rose500),
      _ => ('Active', CIColors.ink3),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          fontFamily: CIType.fontFamily,
        ),
      ),
    );
  }
}
