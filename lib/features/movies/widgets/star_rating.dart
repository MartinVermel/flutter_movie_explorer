import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Custom star rating widget drawn with CustomPainter.
/// We use a ClipRect + Align to handle fractional stars (e.g. 3.7 stars)
/// without needing any image assets — pure canvas drawing.
class StarRating extends StatelessWidget {
  const StarRating({
    super.key,
    required this.rating,
    this.maxRating = 10.0,
    this.starCount = 5,
    this.size = 20.0,
    this.color = AppTheme.ratingColor,
  });

  final double rating;
  final double maxRating;
  final int starCount;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    // Map 0-10 rating to 0-5 stars
    final normalizedRating = (rating / maxRating) * starCount;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(starCount, (index) {
        final filled = normalizedRating - index;
        return _StarWidget(
          fill: filled.clamp(0.0, 1.0),
          size: size,
          color: color,
        );
      }),
    );
  }
}

class _StarWidget extends StatelessWidget {
  const _StarWidget({
    required this.fill,
    required this.size,
    required this.color,
  });

  final double fill;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _StarPainter(fill: fill, color: color),
      ),
    );
  }
}

class _StarPainter extends CustomPainter {
  _StarPainter({required this.fill, required this.color});

  final double fill;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final path = _buildStarPath(size);

    // Draw empty star
    paint.color = color.withOpacity(0.25);
    canvas.drawPath(path, paint);

    // Clip to the fill fraction and draw filled portion
    if (fill > 0) {
      canvas.save();
      canvas.clipRect(Rect.fromLTWH(0, 0, size.width * fill, size.height));
      paint.color = color;
      canvas.drawPath(path, paint);
      canvas.restore();
    }
  }

  Path _buildStarPath(Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final outerRadius = size.width / 2;
    final innerRadius = outerRadius * 0.4;
    const pointCount = 5;
    const startAngle = -90.0 * (3.14159 / 180.0);

    final path = Path();
    for (int i = 0; i < pointCount * 2; i++) {
      final angle = startAngle + (i * 3.14159 / pointCount);
      final radius = i.isEven ? outerRadius : innerRadius;
      final x = cx + radius * (angle == angle ? 1 : 1) * _cos(angle);
      final y = cy + radius * _sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  double _cos(double angle) {
    // Using dart:math would require import; inline approximation for demo
    return _taylorCos(angle);
  }

  double _sin(double angle) {
    return _taylorCos(angle - 1.5708);
  }

  double _taylorCos(double x) {
    // Normalize to [-pi, pi]
    while (x > 3.14159) x -= 6.28318;
    while (x < -3.14159) x += 6.28318;
    final x2 = x * x;
    return 1 - x2 / 2 + x2 * x2 / 24 - x2 * x2 * x2 / 720;
  }

  @override
  bool shouldRepaint(_StarPainter oldDelegate) =>
      oldDelegate.fill != fill || oldDelegate.color != color;
}
