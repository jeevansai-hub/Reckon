import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// The Reckon mark: an "R" built from a satellite arc and a ground track,
/// drawn progressively by [progress] (0 -> fully formed) and a radar sweep
/// that fades out once the signal "locks" (progress reaches 1).
class SignalLockLogo extends StatelessWidget {
  const SignalLockLogo({super.key, required this.progress, required this.sweepAngle});

  /// 0..1 — how much of the mark has been drawn / how converged the rings are.
  final double progress;

  /// 0..2π — current angle of the radar sweep, active while progress < 1.
  final double sweepAngle;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(180, 180),
      painter: _SignalLockPainter(progress: progress, sweepAngle: sweepAngle),
    );
  }
}

class _SignalLockPainter extends CustomPainter {
  _SignalLockPainter({required this.progress, required this.sweepAngle});

  final double progress;
  final double sweepAngle;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final maxRadius = size.shortestSide / 2;

    // Converging radar rings: start wide and far apart, close in as progress -> 1.
    final ringFade = (1 - progress).clamp(0.0, 1.0);
    if (ringFade > 0.01) {
      for (var i = 0; i < 3; i++) {
        final t = (progress * 3 - i).clamp(0.0, 1.0);
        final radius = maxRadius * (1.4 - t * 0.5) - i * 14;
        if (radius <= 0) continue;
        final paint = Paint()
          ..color = AppColors.gps.withValues(alpha: (0.5 - i * 0.12) * ringFade)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4;
        canvas.drawCircle(center, radius, paint);
      }

      // Radar sweep wedge.
      final sweepPaint = Paint()
        ..shader = SweepGradient(
          startAngle: sweepAngle,
          endAngle: sweepAngle + pi / 2.2,
          colors: [AppColors.gps.withValues(alpha: 0.28 * ringFade), Colors.transparent],
        ).createShader(Rect.fromCircle(center: center, radius: maxRadius));
      canvas.drawCircle(center, maxRadius, sweepPaint);
    }

    // The Reckon mark itself: a stylised "R" — vertical stroke + bowl + kicking leg —
    // stroked progressively, and a glow that intensifies as it locks in.
    final markPaint = Paint()
      ..color = AppColors.textPrimary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final glowPaint = Paint()
      ..color = AppColors.gps.withValues(alpha: 0.6 * progress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    final path = _markPath(center, maxRadius);
    final metric = path.computeMetrics().first;
    final drawLength = metric.length * progress.clamp(0.0, 1.0);
    final partial = metric.extractPath(0, drawLength);

    canvas.drawPath(partial, glowPaint);
    canvas.drawPath(partial, markPaint);

    // Lock dot: appears once fully formed.
    if (progress > 0.96) {
      final dotPaint = Paint()..color = AppColors.gps;
      canvas.drawCircle(center + Offset(maxRadius * 0.02, -maxRadius * 0.62), 5, dotPaint);
    }
  }

  Path _markPath(Offset center, double r) {
    // A compact "R" traced as one continuous stroke, centred roughly on [center].
    final path = Path();
    final left = center.dx - r * 0.42;
    final top = center.dy - r * 0.62;
    final bottom = center.dy + r * 0.62;
    final midY = center.dy - r * 0.02;
    final right = center.dx + r * 0.4;

    path.moveTo(left, bottom);
    path.lineTo(left, top);
    path.lineTo(center.dx + r * 0.05, top);
    path.quadraticBezierTo(right, top, right, top + r * 0.32);
    path.quadraticBezierTo(right, midY, center.dx + r * 0.05, midY);
    path.lineTo(left, midY);
    path.moveTo(center.dx - r * 0.02, midY);
    path.lineTo(right, bottom);

    return path;
  }

  @override
  bool shouldRepaint(covariant _SignalLockPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.sweepAngle != sweepAngle;
  }
}
