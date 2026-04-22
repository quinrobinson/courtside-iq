import 'package:flutter/material.dart';

/// Reusable avatar for the dashboard — shows a network photo if [profilePic]
/// is non-null, otherwise falls back to a circle with [initials].
class DashboardAvatar extends StatelessWidget {
  const DashboardAvatar({
    super.key,
    required this.initials,
    required this.size,
    this.profilePic,
  });

  final String? profilePic;
  final String initials;
  final double size;

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFE8E8E8);
    const fg = Color(0xFF6A6A6A);

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
                errorBuilder: (_, __, ___) => _Initials(
                  initials: initials,
                  size: size,
                  bg: bg,
                  fg: fg,
                ),
              )
            : _Initials(initials: initials, size: size, bg: bg, fg: fg),
      ),
    );
  }
}

class _Initials extends StatelessWidget {
  const _Initials({
    required this.initials,
    required this.size,
    required this.bg,
    required this.fg,
  });

  final String initials;
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
      child: Text(
        initials.isEmpty ? '?' : initials,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: size * 0.35,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}
