import 'package:flutter/material.dart';

class TrendPill extends StatelessWidget {
  const TrendPill({super.key, required this.direction});

  final String? direction;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (direction) {
      'improving' => ('↑ Improving', const Color(0xFF2BC18C)),
      'declining' => ('↓ Cooling', const Color(0xFFD9005C)),
      _ => ('Active', const Color(0xFF8A8A8A)),
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
          fontFamily: 'Inter',
        ),
      ),
    );
  }
}
