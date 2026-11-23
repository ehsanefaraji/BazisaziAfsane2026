/// نقاش موجودات و آیتم‌های نسخهٔ ۵
/// شامل: سکه چرخان، دشمن خاری، در خروجی، گل، سپر، آهنربا، سرعت، جان اضافه
import 'dart:math';
import 'package:flutter/material.dart';

/// سکهٔ چرخان با گرادیان و درخشش متحرک
class CoinPainter extends CustomPainter {
  final double spinPhase;
  const CoinPainter({this.spinPhase = 0});

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 40;
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(s);

    // هالهٔ نوسانی
    final glowAlpha = 0.4 + 0.2 * sin(spinPhase * 2);
    final glowPaint = Paint()
      ..color = const Color(0xFFFFF59D).withValues(alpha: glowAlpha);
    canvas.drawCircle(Offset.zero, 16, glowPaint);

    // چرخش ۳بعدی با squash افقی
    final sx = cos(spinPhase).abs();
    canvas.save();
    canvas.scale(sx, 1);

    // گرادیان طلایی شعاعی
    final coinPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFFFFF59D), Color(0xFFFFD54F), Color(0xFFFF8F00)],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: 12));
    canvas.drawCircle(Offset.zero, 12, coinPaint);

    // ستاره مرکزی
    final starPaint = Paint()..color = const Color(0xFFFF6F00);
    final starPath = Path();
    for (int i = 0; i < 5; i++) {
      final outerA = -pi / 2 + i * 2 * pi / 5;
      final innerA = outerA + pi / 5;
      final ox = 6 * cos(outerA);
      final oy = 6 * sin(outerA);
      final ix = 2.5 * cos(innerA);
      final iy = 2.5 * sin(innerA);
      if (i == 0) {
        starPath.moveTo(ox, oy);
      } else {
        starPath.lineTo(ox, oy);
      }
      starPath.lineTo(ix, iy);
    }
    starPath.close();
    canvas.drawPath(starPath, starPaint);

    // لبهٔ برجسته
    final edgePaint = Paint()
      ..color = const Color(0xFFFF6F00)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    canvas.drawCircle(Offset.zero, 12, edgePaint);

    canvas.restore();

    // درخشش متحرک روی لبه
    final glintPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawArc(
      Rect.fromCircle(center: Offset.zero, radius: 11),
      spinPhase * 2,
      0.7,
      false,
      glintPaint,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CoinPainter old) => old.spinPhase != spinPhase;
}

/// دشمن خاری متحرک
class EnemyPainter extends CustomPainter {
  final double walkPhase;
  const EnemyPainter({this.walkPhase = 0});

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 40;
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(s);

    // هاله تاریک
    final darkPaint = Paint()
      ..color = const Color(0xFFB71C1C).withValues(alpha: 0.5);
    canvas.drawCircle(Offset.zero, 16, darkPaint);

    // نوسان عمودی
    final bounce = sin(walkPhase * 2) * 1.5;
    canvas.translate(0, bounce);

    // بدن با گرادیان
    final bodyPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFFFF5252), Color(0xFFEF5350), Color(0xFFB71C1C)],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: 12));
    canvas.drawCircle(Offset.zero, 12, bodyPaint);

    // خارها
    final spikePaint = Paint()..color = const Color(0xFFB71C1C);
    for (int i = 0; i < 12; i++) {
      final a = i * pi / 6 + sin(walkPhase) * 0.05;
      final x1 = 11 * cos(a);
      final y1 = 11 * sin(a);
      final x2 = 18 * cos(a);
      final y2 = 18 * sin(a);
      final px = 14 * cos(a + 0.2);
      final py = 14 * sin(a + 0.2);
      final path = Path()
        ..moveTo(x1, y1)
        ..lineTo(x2, y2)
        ..lineTo(px, py)
        ..close();
      canvas.drawPath(path, spikePaint);
    }

    // چشم‌های خشمگین
    canvas.drawCircle(const Offset(-4, -2), 4.5, Paint()..color = Colors.white);
    canvas.drawCircle(const Offset(4, -2), 4.5, Paint()..color = Colors.white);
    canvas.drawCircle(const Offset(-4, -1), 2.5, Paint()..color = const Color(0xFF2E1840));
    canvas.drawCircle(const Offset(4, -1), 2.5, Paint()..color = const Color(0xFF2E1840));
    // ابروها
    final browPaint = Paint()
      ..color = const Color(0xFF2E1840)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    canvas.drawLine(const Offset(-8, -7), const Offset(-1, -4), browPaint);
    canvas.drawLine(const Offset(8, -7), const Offset(1, -4), browPaint);

    // دندان‌های تیز
    final toothPaint = Paint()..color = Colors.white;
    for (int i = -2; i <= 2; i++) {
      final path = Path()
        ..moveTo(i * 3, 5)
        ..lineTo(i * 3 + 1.5, 9)
        ..lineTo(i * 3 + 3, 5)
        ..close();
      canvas.drawPath(path, toothPaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepant(covariant EnemyPainter old) => old.walkPhase != walkPhase;

  @override
  bool shouldRepaint(covariant EnemyPainter old) => old.walkPhase != walkPhase;
}

/// در خروجی با هالهٔ پالس و ستارهٔ چرخان
class ExitDoorPainter extends CustomPainter {
  final double pulse;
  const ExitDoorPainter({this.pulse = 0});

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 40;
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(s);

    // هالهٔ پالس‌دار چندلایه
    final glow1 = Paint()
      ..color = const Color(0xFFB9F6CA).withValues(alpha: 0.3 + pulse * 0.2);
    canvas.drawCircle(Offset.zero, 22, glow1);
    final glow2 = Paint()
      ..color = const Color(0xFFB9F6CA).withValues(alpha: 0.5 + pulse * 0.3);
    canvas.drawCircle(Offset.zero, 16, glow2);

    // قاب در با گرادیان
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(-11, -15, 22, 30), const Radius.circular(5)),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
        ).createShader(const Rect.fromLTWH(-11, -15, 22, 30)),
    );

    // خود در با گرادیان
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(-9, -13, 18, 26), const Radius.circular(3)),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF66BB6A), Color(0xFF2E7D32)],
        ).createShader(const Rect.fromLTWH(-9, -13, 18, 26)),
    );

    // دستگیره
    canvas.drawCircle(const Offset(5, 0), 1.8, Paint()..color = const Color(0xFFFFD54F));

    // ستارهٔ چرخان بالای در
    canvas.save();
    canvas.translate(0, -22);
    canvas.rotate(pulse * 0.8);
    final starPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFFFFF59D), Color(0xFFFFD54F), Color(0xFFFF8F00)],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: 5));
    final starPath = Path();
    for (int i = 0; i < 5; i++) {
      final outerA = -pi / 2 + i * 2 * pi / 5;
      final innerA = outerA + pi / 5;
      final ox = 5 * cos(outerA);
      final oy = 5 * sin(outerA);
      final ix = 2 * cos(innerA);
      final iy = 2 * sin(innerA);
      if (i == 0) {
        starPath.moveTo(ox, oy);
      } else {
        starPath.lineTo(ox, oy);
      }
      starPath.lineTo(ix, iy);
    }
    starPath.close();
    canvas.drawPath(starPath, starPaint);
    canvas.restore();

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant ExitDoorPainter old) => old.pulse != pulse;
}

/// گل تزئینی با ساقه و تکان خوردن
class FlowerPainter extends CustomPainter {
  final double swayPhase;
  const FlowerPainter({this.swayPhase = 0});

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 40;
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(s);

    canvas.translate(sin(swayPhase) * 1.5, 0);

    // ساقه
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(-1, 0, 2, 14), const Radius.circular(1)),
      Paint()..color = const Color(0xFF558B2F),
    );

    // گلبرگ‌ها با گرادیان
    final petalPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFFCE93D8), Color(0xFFAB47BC)],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: 8));
    for (int i = 0; i < 6; i++) {
      final a = i * pi / 3;
      final cx = 8 * cos(a);
      final cy = -2 + 8 * sin(a);
      canvas.drawCircle(Offset(cx, cy), 5, petalPaint);
    }

    // مرکز زرد
    canvas.drawCircle(const Offset(0, -2), 4, Paint()..color = const Color(0xFFFFD54F));

    // برگ
    canvas.drawPath(
      Path()
        ..moveTo(0, 8)
        ..quadraticBezierTo(8, 6, 6, 12)
        ..quadraticBezierTo(2, 10, 0, 8)
        ..close(),
      Paint()..color = const Color(0xFF66BB6A),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant FlowerPainter old) => old.swayPhase != swayPhase;
}

/// سپر — دایرهٔ آبی با علامت قفل
class ShieldPainter extends CustomPainter {
  final double pulse;
  const ShieldPainter({this.pulse = 0});

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 40;
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(s);

    // هاله
    final glow = Paint()
      ..color = const Color(0xFF42A5F5).withValues(alpha: 0.4 + pulse * 0.3);
    canvas.drawCircle(Offset.zero, 16, glow);

    // بدنهٔ سپر (شکل سپر کلاسیک)
    final shieldPath = Path()
      ..moveTo(0, -12)
      ..lineTo(10, -8)
      ..lineTo(10, 4)
      ..quadraticBezierTo(10, 12, 0, 14)
      ..quadraticBezierTo(-10, 12, -10, 4)
      ..lineTo(-10, -8)
      ..close();
    final shieldPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF64B5F6), Color(0xFF1976D2)],
      ).createShader(const Rect.fromLTWH(-10, -12, 20, 26));
    canvas.drawPath(shieldPath, shieldPaint);
    // خط عمودی مرکزی
    canvas.drawLine(const Offset(0, -10), const Offset(0, 12),
        Paint()..color = const Color(0xFF0D47A1)..strokeWidth = 1.5);
    // خط افقی
    canvas.drawLine(const Offset(-7, 0), const Offset(7, 0),
        Paint()..color = const Color(0xFF0D47A1)..strokeWidth = 1.5);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant ShieldPainter old) => old.pulse != pulse;
}

/// آهنربا — U قرمز با نقطه‌های قطبی
class MagnetPainter extends CustomPainter {
  final double pulse;
  const MagnetPainter({this.pulse = 0});

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 40;
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(s);

    // هاله
    final glow = Paint()
      ..color = const Color(0xFFFF7043).withValues(alpha: 0.3 + pulse * 0.2);
    canvas.drawCircle(Offset.zero, 16, glow);

    // شکل U آهنربا
    final path = Path()
      ..moveTo(-10, -12)
      ..lineTo(-10, 4)
      ..quadraticBezierTo(-10, 12, 0, 12)
      ..quadraticBezierTo(10, 12, 10, 4)
      ..lineTo(10, -12)
      ..lineTo(5, -12)
      ..lineTo(5, 4)
      ..quadraticBezierTo(5, 7, 0, 7)
      ..quadraticBezierTo(-5, 7, -5, 4)
      ..lineTo(-5, -12)
      ..close();
    canvas.drawPath(path, Paint()..color = const Color(0xFFEF5350));
    // نقاط قطبی
    canvas.drawRect(Rect.fromLTWH(-10, -12, 5, 4), Paint()..color = Colors.white);
    canvas.drawRect(Rect.fromLTWH(5, -12, 5, 4), Paint()..color = Colors.white);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant MagnetPainter old) => old.pulse != pulse;
}

/// سرعت — صاعقه
class SpeedBoostPainter extends CustomPainter {
  final double pulse;
  const SpeedBoostPainter({this.pulse = 0});

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 40;
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(s);

    // هاله
    final glow = Paint()
      ..color = const Color(0xFFAB47BC).withValues(alpha: 0.4 + pulse * 0.3);
    canvas.drawCircle(Offset.zero, 16, glow);

    // صاعقه با گرادیان
    final boltPath = Path()
      ..moveTo(2, -14)
      ..lineTo(-6, 2)
      ..lineTo(-1, 2)
      ..lineTo(-3, 14)
      ..lineTo(7, -2)
      ..lineTo(2, -2)
      ..close();
    final boltPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFE1BEE7), Color(0xFFAB47BC), Color(0xFF6A1B9A)],
      ).createShader(const Rect.fromLTWH(-6, -14, 13, 28));
    canvas.drawPath(boltPath, boltPaint);
    // لبهٔ روشن
    canvas.drawPath(boltPath,
        Paint()..color = Colors.white.withValues(alpha: 0.4)..style = PaintingStyle.stroke..strokeWidth = 0.8);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant SpeedBoostPainter old) => old.pulse != pulse;
}

/// جان اضافه — قلب
class ExtraLifePainter extends CustomPainter {
  final double pulse;
  const ExtraLifePainter({this.pulse = 0});

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 40;
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(s);
    // نوسان اندازه
    final sz = 1 + pulse * 0.1;
    canvas.scale(sz, sz);

    // هاله
    final glow = Paint()
      ..color = const Color(0xFFEC407A).withValues(alpha: 0.4 + pulse * 0.2);
    canvas.drawCircle(Offset.zero, 16, glow);

    // قلب با گرادیان
    final heartPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFFF48FB1), Color(0xFFEC407A), Color(0xFFAD1457)],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: 14));
    final path = Path()
      ..moveTo(0, 10)
      ..quadraticBezierTo(-14, 0, -14, -4)
      ..quadraticBezierTo(-14, -12, -7, -12)
      ..quadraticBezierTo(-2, -12, 0, -6)
      ..quadraticBezierTo(2, -12, 7, -12)
      ..quadraticBezierTo(14, -12, 14, -4)
      ..quadraticBezierTo(14, 0, 0, 10)
      ..close();
    canvas.drawPath(path, heartPaint);
    // درخشش
    canvas.drawCircle(const Offset(-5, -7), 2.5, Paint()..color = Colors.white.withValues(alpha: 0.6));

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant ExtraLifePainter old) => old.pulse != pulse;
}

/// تابع کمکی برای ساخت نقاش بر اساس ItemRole
CustomPainter painterForRole(dynamic role, double t) {
  final phase = t * 6.28;
  // رشته‌ای برای پشتیبانی از هر دو enum یا string
  final name = role is String ? role : (role as dynamic).name as String;
  switch (name) {
    case 'coin':        return CoinPainter(spinPhase: phase);
    case 'enemy':       return EnemyPainter(walkPhase: phase);
    case 'exit':        return ExitDoorPainter(pulse: (sin(phase) + 1) / 2);
    case 'decoration':  return FlowerPainter(swayPhase: phase);
    case 'shield':      return ShieldPainter(pulse: (sin(phase) + 1) / 2);
    case 'magnet':      return MagnetPainter(pulse: (sin(phase) + 1) / 2);
    case 'speedBoost':  return SpeedBoostPainter(pulse: (sin(phase) + 1) / 2);
    case 'extraLife':   return ExtraLifePainter(pulse: (sin(phase) + 1) / 2);
    default:            return FlowerPainter(swayPhase: phase);
  }
}
