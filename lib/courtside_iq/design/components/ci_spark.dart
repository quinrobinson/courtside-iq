// The insight spark — the mark that means "Claude read this game".
//
// A four-point star, drawn rather than shipped as an SVG. Every other mark in
// this system is a painter (dot gauge, dot burst, logo mark), and the reason
// holds here: it takes its colour from the caller, scales to any size without
// a second asset, and cannot go missing from a build.
//
// IT ALWAYS MEANS THE SAME THING. This is the AI insight and nothing else -
// not "new", not "featured". It appears on the Game Complete promise, and on
// games that carry an insight. If it starts decorating anything else it stops
// telling a parent anything.

import 'package:flutter/material.dart';

class CiSpark extends StatelessWidget {
  const CiSpark({super.key, this.size = 22, this.color});

  final double size;

  /// Defaults to the surrounding text colour, so it sits on any ground.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tint = color ?? DefaultTextStyle.of(context).style.color;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _SparkPainter(tint ?? Colors.black),
      ),
    );
  }
}

class _SparkPainter extends CustomPainter {
  const _SparkPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Four points, with each edge curving back toward the centre. Pulling the
    // control points all the way in is what makes the lobes taper instead of
    // reading as a plain diamond.
    final path = Path()
      ..moveTo(cx, 0)
      ..quadraticBezierTo(cx, cy, size.width, cy)
      ..quadraticBezierTo(cx, cy, cx, size.height)
      ..quadraticBezierTo(cx, cy, 0, cy)
      ..quadraticBezierTo(cx, cy, cx, 0)
      ..close();

    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_SparkPainter old) => old.color != color;
}
