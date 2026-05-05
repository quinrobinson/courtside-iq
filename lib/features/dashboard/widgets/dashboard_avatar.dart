import '/courtside_iq/design_tokens.dart';
import 'package:flutter/material.dart';

/// Reusable avatar for the dashboard — shows a network photo if [profilePic]
/// is non-null, otherwise falls back to a person icon placeholder.
class DashboardAvatar extends StatelessWidget {
  const DashboardAvatar({
    super.key,
    required this.size,
    this.profilePic,
  });

  final String? profilePic;
  final double size;

  @override
  Widget build(BuildContext context) {
    const bg = CIColors.canvasSunk;
    const fg = CIColors.ink3;

    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: profilePic != null && profilePic!.isNotEmpty
            ? Image.network(
                profilePic!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _Placeholder(size: size, bg: bg, fg: fg),
              )
            : _Placeholder(size: size, bg: bg, fg: fg),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({
    required this.size,
    required this.bg,
    required this.fg,
  });

  final double size;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      color: bg,
      alignment: Alignment.center,
      child: Icon(
        Icons.person_rounded,
        size: size * 0.6,
        color: fg,
      ),
    );
  }
}
