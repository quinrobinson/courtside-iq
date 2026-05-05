import '/courtside_iq/design_tokens.dart';
import 'package:flutter/material.dart';

/// Cool-toned skeleton placeholder block. Uses CIColors.canvasSunk.
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
        color: CIColors.canvasSunk,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
