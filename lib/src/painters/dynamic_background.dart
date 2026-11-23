/// پس‌زمینهٔ دینامیک بر اساس محیط — نسخهٔ ۵
/// برای محیط‌های forest, sky, underwater, cave, castle از تصویر AI استفاده می‌کند
/// اما به‌علاوه چندلایهٔ پارالاکس زنده روی آن می‌کشد.
import 'dart:math';
import 'package:flutter/material.dart';
import '../theme.dart';

class DynamicBackground extends CustomPainter {
  final Environment env;
  final double scrollOffset;
  final double time;

  DynamicBackground({required this.env, this.scrollOffset = 0, this.time = 0});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // گرادیان پایه بر اساس محیط
    final basePaint = Paint()..shader = env.gradient.createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), basePaint);

    // جزئیات محیط‌های مختلف
    switch (env) {
      case Environment.forest:
        _drawStars(canvas, size, count: 60);
        _drawMoon(canvas, size);
        _drawMountains(canvas, size, h * 0.55, h * 0.18, 4, Paint()..color = const Color(0xFF311B92).withValues(alpha: 0.7), scrollOffset * 0.15);
        _drawMountains(canvas, size, h * 0.7, h * 0.22, 5, Paint()..color = const Color(0xFF1B5E20).withValues(alpha: 0.85), scrollOffset * 0.35);
        _drawTrees(canvas, size, h * 0.88, 7, Paint()..color = const Color(0xFF1B5E20), scrollOffset * 0.85);
        _drawSparkles(canvas, size, count: 30);
        break;
      case Environment.sky:
        // خورشید غروب
        final sunCenter = Offset(w * 0.5, h * 0.3);
        for (int i = 5; i > 0; i--) {
          final glow = Paint()..color = const Color(0xFFFFAB91).withValues(alpha: 0.1 * i);
          canvas.drawCircle(sunCenter, 80 + i * 15, glow);
        }
        canvas.drawCircle(sunCenter, 50, Paint()..color = const Color(0xFFFFCC80));
        // رنگین‌کمان
        final rainbowPaint = Paint()..style = PaintingStyle.stroke..strokeWidth = 4;
        for (int i = 0; i < 7; i++) {
          rainbowPaint.color = [
            const Color(0xFFFF5252), const Color(0xFFFF9800), const Color(0xFFFFEB3B),
            const Color(0xFF4CAF50), const Color(0xFF03A9F4), const Color(0xFF3F51B5),
            const Color(0xFF9C27B0),
          ][i].withValues(alpha: 0.4);
          canvas.drawArc(
            Rect.fromCircle(center: Offset(w * 0.5, h * 0.8), radius: 200 + i * 8),
            pi, pi, false, rainbowPaint,
          );
        }
        // ابرهای متحرک
        _drawClouds(canvas, size, count: 8, scrollOffset: scrollOffset * 0.4);
        _drawSparkles(canvas, size, count: 20, color: const Color(0xFFFFF59D));
        break;
      case Environment.underwater:
        // اشعهٔ نور از بالا
        for (int i = 0; i < 6; i++) {
          final x = w * (0.15 + i * 0.15);
          final rayPaint = Paint()
            ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.08 + 0.05 * sin(time + i));
          final path = Path()
            ..moveTo(x - 20, 0)
            ..lineTo(x + 20, 0)
            ..lineTo(x + 60, h)
            ..lineTo(x - 60, h)
            ..close();
          canvas.drawPath(path, rayPaint);
        }
        // حباب‌ها
        _drawBubbles(canvas, size, count: 25);
        // مرجان‌های پایین
        for (int i = 0; i < 8; i++) {
          final x = ((i * 50 + scrollOffset * 0.3) % w);
          final y = h - 30;
          final col = [const Color(0xFFFF6F61), const Color(0xFFFFD54F), const Color(0xFFEC407A)][i % 3];
          canvas.drawCircle(Offset(x, y), 8, Paint()..color = col);
          canvas.drawCircle(Offset(x - 5, y - 5), 6, Paint()..color = col);
          canvas.drawCircle(Offset(x + 5, y - 5), 6, Paint()..color = col);
        }
        break;
      case Environment.cave:
        // ستاره‌ها در بالا (بیرون غار)
        _drawStars(canvas, size, count: 30);
        // کریستال‌های درخشان
        for (int i = 0; i < 12; i++) {
          final x = (i * w / 12 + scrollOffset * 0.3) % w;
          final y = h * (0.6 + (i % 3) * 0.1);
          final pulse = 0.5 + 0.5 * sin(time + i);
          final crystalPaint = Paint()
            ..color = const Color(0xFFB388FF).withValues(alpha: 0.4 + pulse * 0.5);
          canvas.drawCircle(Offset(x, y), 8, crystalPaint);
          // شکل کریستال (لوزی)
          final path = Path()
            ..moveTo(x, y - 12)
            ..lineTo(x + 6, y)
            ..lineTo(x, y + 12)
            ..lineTo(x - 6, y)
            ..close();
          canvas.drawPath(path, Paint()..color = const Color(0xFF7E57C2).withValues(alpha: 0.7));
        }
        // استالاگمیت‌ها
        for (int i = 0; i < 5; i++) {
          final x = i * w / 5;
          final path = Path()
            ..moveTo(x, h)
            ..lineTo(x + 20, h)
            ..lineTo(x + 10, h - 60 - (i * 10))
            ..close();
          canvas.drawPath(path, Paint()..color = const Color(0xFF1A237E));
        }
        break;
      case Environment.castle:
        // ستاره‌ها
        _drawStars(canvas, size, count: 80);
        // ماه
        _drawMoon(canvas, size);
        // برج‌های دور
        final towerPaint = Paint()..color = const Color(0xFF4527A0).withValues(alpha: 0.7);
        for (int i = 0; i < 5; i++) {
          final x = (i * w / 5 + scrollOffset * 0.2) % w;
          final towerH = (80 + i * 20).toDouble();
          canvas.drawRect(Rect.fromLTWH(x - 15, h - towerH, 30, towerH), towerPaint);
          // سقف مخروطی
          final roofPath = Path()
            ..moveTo(x - 18, h - towerH)
            ..lineTo(x, h - towerH - 25)
            ..lineTo(x + 18, h - towerH)
            ..close();
          canvas.drawPath(roofPath, Paint()..color = const Color(0xFF6A1B9A));
        }
        // پنجره‌های روشن برج
        for (int i = 0; i < 5; i++) {
          final x = i * w / 5 + 10;
          final y = h - 60;
          final winGlow = Paint()
            ..color = const Color(0xFFFFD54F).withValues(alpha: 0.6 + 0.3 * sin(time + i));
          canvas.drawRect(Rect.fromLTWH(x - 3, y, 6, 10), winGlow);
        }
        // جرقه‌های جادویی
        _drawSparkles(canvas, size, count: 40, color: const Color(0xFFFFF59D));
        break;
    }
  }

  void _drawStars(Canvas canvas, Size size, {int count = 50}) {
    final w = size.width;
    final h = size.height;
    final rng = Random(42);
    final starPaint = Paint()..color = Colors.white;
    for (int i = 0; i < count; i++) {
      final x = rng.nextDouble() * w;
      final y = rng.nextDouble() * (h * 0.5);
      final baseSz = rng.nextDouble() * 1.6 + 0.4;
      final twinkle = 0.6 + 0.4 * sin(time * 2 + i);
      final sz = baseSz * twinkle;
      starPaint.color = Colors.white.withValues(alpha: twinkle);
      canvas.drawCircle(Offset(x, y), sz, starPaint);
    }
  }

  void _drawMoon(Canvas canvas, Size size) {
    final moonCenter = Offset(size.width * 0.78, size.height * 0.16);
    for (int i = 3; i > 0; i--) {
      canvas.drawCircle(moonCenter, 40 + i * 20,
          Paint()..color = const Color(0xFFFFF59D).withValues(alpha: 0.1 * i));
    }
    canvas.drawCircle(moonCenter, 38, Paint()..color = const Color(0xFFFFF9C4));
  }

  void _drawMountains(Canvas canvas, Size size, double baseY, double height,
                      int count, Paint paint, double offset) {
    final w = size.width;
    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, baseY);
    for (int i = 0; i <= count; i++) {
      final x = (i / count) * w + (offset % (w / count));
      final y = baseY - height * (0.5 + 0.5 * sin(i * 1.3));
      path.lineTo(x, y);
    }
    path.lineTo(w, baseY);
    path.lineTo(w, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawTrees(Canvas canvas, Size size, double baseY, int count, Paint paint, double offset) {
    final w = size.width;
    final step = w / count;
    for (int i = 0; i < count + 2; i++) {
      final cx = (i * step - (offset % step));
      final treeH = step * 0.9;
      canvas.drawRect(
        Rect.fromLTWH(cx - step * 0.05, baseY - treeH * 0.3, step * 0.1, treeH * 0.3),
        paint,
      );
      final path = Path()
        ..moveTo(cx, baseY - treeH)
        ..lineTo(cx - step * 0.35, baseY - treeH * 0.45)
        ..lineTo(cx + step * 0.35, baseY - treeH * 0.45)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  void _drawClouds(Canvas canvas, Size size, {int count = 6, double scrollOffset = 0}) {
    final w = size.width;
    final rng = Random(7);
    for (int i = 0; i < count; i++) {
      final x = ((rng.nextDouble() * w + scrollOffset + i * 80) % (w + 100)) - 50;
      final y = size.height * (0.15 + rng.nextDouble() * 0.3);
      final paint = Paint()..color = Colors.white.withValues(alpha: 0.7);
      canvas.drawCircle(Offset(x, y), 20, paint);
      canvas.drawCircle(Offset(x + 18, y + 5), 16, paint);
      canvas.drawCircle(Offset(x - 18, y + 5), 16, paint);
    }
  }

  void _drawSparkles(Canvas canvas, Size size, {int count = 30, Color color = const Color(0xFFFFF59D)}) {
    final w = size.width;
    final h = size.height;
    final rng = Random(11);
    for (int i = 0; i < count; i++) {
      final baseX = rng.nextDouble() * w;
      final baseY = rng.nextDouble() * h;
      final x = (baseX + scrollOffset * 1.1 + i * 13) % w;
      final y = baseY + sin(time * 0.8 + i * 0.5) * 8;
      final r = 1.5 + sin(time * 1.5 + i) * 0.5;
      final alpha = 0.6 + 0.4 * sin(time * 2 + i * 0.7);
      canvas.drawCircle(Offset(x, y), r * 3, Paint()..color = color.withValues(alpha: 0.3 * alpha));
      canvas.drawCircle(Offset(x, y), r, Paint()..color = color.withValues(alpha: alpha));
    }
  }

  void _drawBubbles(Canvas canvas, Size size, {int count = 20}) {
    final w = size.width;
    final h = size.height;
    final rng = Random(99);
    for (int i = 0; i < count; i++) {
      final baseX = rng.nextDouble() * w;
      final baseY = rng.nextDouble() * h;
      // حباب‌ها به‌آرامی بالا می‌روند
      final y = (baseY - time * 30 + i * 50) % h;
      final r = 3 + rng.nextDouble() * 5;
      canvas.drawCircle(Offset(baseX, y), r,
          Paint()..color = Colors.white.withValues(alpha: 0.3));
    }
  }

  @override
  bool shouldRepaint(covariant DynamicBackground old) =>
      old.scrollOffset != scrollOffset || old.time != time || old.env != env;
}
