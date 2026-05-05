import 'package:flutter/material.dart';

/// Cool-toned skeleton placeholder block.
/// Colour: #DADBDE — same undertone as the app canvas (#F2F3F5), ~10% darker.
/// Use for loading states in place of spinners.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.radius = 12.0,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFDADBDE),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
