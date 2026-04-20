import 'package:flutter/material.dart';

/// Four-point rounded sparkle, matching assets/images/spark.svg.
/// Reference path is 14x14; scaled to [size].
class SparkIcon extends StatelessWidget {
  const SparkIcon({
    super.key,
    this.size = 14,
    this.color = const Color(0xFF7936FF),
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _SparkPainter(color)),
    );
  }
}

class _SparkPainter extends CustomPainter {
  _SparkPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 14.0;
    double x(double v) => v * s;
    double y(double v) => v * s;

    final path = Path()
      ..moveTo(x(6.21136), y(0))
      ..lineTo(x(7.78864), y(0))
      ..lineTo(x(9.04601), y(3.45079))
      ..cubicTo(
        x(9.30102), y(4.14898),
        x(9.85104), y(4.69898),
        x(10.5492), y(4.95399),
      )
      ..lineTo(x(14), y(6.21136))
      ..lineTo(x(14), y(7.78864))
      ..lineTo(x(10.5492), y(9.04601))
      ..cubicTo(
        x(9.85102), y(9.30102),
        x(9.30102), y(9.85104),
        x(9.04601), y(10.5492),
      )
      ..lineTo(x(7.78864), y(14))
      ..lineTo(x(6.21136), y(14))
      ..lineTo(x(4.95399), y(10.5492))
      ..cubicTo(
        x(4.69898), y(9.85103),
        x(4.14896), y(9.30102),
        x(3.45079), y(9.04601),
      )
      ..lineTo(x(0), y(7.78864))
      ..lineTo(x(0), y(6.21136))
      ..lineTo(x(3.45079), y(4.95399))
      ..cubicTo(
        x(4.14898), y(4.69898),
        x(4.69898), y(4.14896),
        x(4.95399), y(3.45079),
      )
      ..close();

    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _SparkPainter old) => old.color != color;
}
