/// نقاش روباه نسخهٔ ۵ — با جزئیات بیشتر: دم متحرک، چشم‌های درخشان،
/// شنل با grain، حالت‌های idle/run/jump/fall/hurt
import 'dart:math';
import 'package:flutter/material.dart';

enum FoxPose { idle, run, jump, fall, hurt }

class FoxCharacterPainter extends CustomPainter {
  final FoxPose pose;
  final double breathPhase;
  final double runPhase;
  final bool hasShield;

  const FoxCharacterPainter({
    this.pose = FoxPose.idle,
    this.breathPhase = 0,
    this.runPhase = 0,
    this.hasShield = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 100;
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(s);

    // سپر (اگر فعال است)
    if (hasShield) {
      final shieldGlow = Paint()
        ..color = const Color(0xFF42A5F5).withValues(alpha: 0.4 + 0.2 * sin(breathPhase * 2));
      canvas.drawCircle(Offset.zero, 36, shieldGlow);
      final shieldRing = Paint()
        ..color = const Color(0xFF42A5F5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(Offset.zero, 32, shieldRing);
    }

    // اعمال pose-specific transforms
    double squash = 1;
    if (pose == FoxPose.idle) {
      canvas.translate(0, sin(breathPhase) * 1.5);
    } else if (pose == FoxPose.jump) {
      squash = 1.18;
      canvas.scale(1 / squash, squash);
    } else if (pose == FoxPose.fall) {
      squash = 0.85;
      canvas.scale(1 / squash, squash);
    } else if (pose == FoxPose.hurt) {
      canvas.rotate(sin(breathPhase * 8) * 0.15);
    }

    // شنل بنفش با sway هنگام run
    final capeSway = pose == FoxPose.run ? sin(runPhase * 2) * 4 : 0;
    final capePaint = Paint()..color = const Color(0xFF7E57C2);
    final capePath = Path()
      ..moveTo(-22, -10)
      ..quadraticBezierTo(-32 - capeSway, 14, -28 - capeSway, 40)
      ..quadraticBezierTo(-15 - capeSway, 34, -8, 25)
      ..quadraticBezierTo(-12, 5, -22, -10)
      ..close();
    canvas.drawPath(capePath, capePaint);
    // لبهٔ روشن شنل
    final capeEdgePath = Path()
      ..moveTo(-28 - capeSway, 32)
      ..quadraticBezierTo(-22 - capeSway, 24, -14, 26)
      ..lineTo(-16, 32)
      ..close();
    canvas.drawPath(capeEdgePath, Paint()..color = const Color(0xFFB388FF));
    // نقاط درخشان روی شنل
    final sparklePaint = Paint()..color = const Color(0xFFFFF59D);
    for (int i = 0; i < 3; i++) {
      final sy = -5 + i * 15;
      final sx = -20 - capeSway * (i + 1) * 0.3;
      canvas.drawCircle(Offset(sx, sy), 1, sparklePaint);
    }

    // دم پف‌دار با حرکت نوسانی شدیدتر
    final tailY = pose == FoxPose.run ? -8 : 0;
    final tailSway = sin(breathPhase * 1.5) * 3;
    final tailPaint = Paint()..color = const Color(0xFFFF7043);
    final tailPath = Path()
      ..moveTo(-18, 15 + tailY)
      ..quadraticBezierTo(-40 - tailSway, -2 + tailY, -34 - tailSway, -22 + tailY)
      ..quadraticBezierTo(-22, -10 + tailY, -16, 5 + tailY)
      ..close();
    canvas.drawPath(tailPath, tailPaint);
    // نوک سفید دم با گرادیان
    final tailTipPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(-32 - tailSway, -16 + tailY), 7, tailTipPaint);
    // سایه در نوک دم
    canvas.drawCircle(Offset(-29 - tailSway, -13 + tailY), 3, Paint()..color = const Color(0xFFFFCCBC));

    // بدن
    final bodyPaint = Paint()..color = const Color(0xFFFF7043);
    final bodyPath = Path()
      ..moveTo(-18, -8)
      ..quadraticBezierTo(-22, 15, -10, 22)
      ..lineTo(10, 22)
      ..quadraticBezierTo(22, 15, 18, -8)
      ..close();
    canvas.drawPath(bodyPath, bodyPaint);
    // شکم سفید
    canvas.drawPath(
      Path()
        ..moveTo(-8, -2)
        ..quadraticBezierTo(-10, 18, 0, 22)
        ..quadraticBezierTo(10, 18, 8, -2)
        ..close(),
      Paint()..color = const Color(0xFFFFF3E0),
    );
    // سایه روی بدن
    final bodyShadePaint = Paint()..color = const Color(0xFFE64A19).withValues(alpha: 0.3);
    canvas.drawPath(
      Path()
        ..moveTo(8, -5)
        ..quadraticBezierTo(15, 5, 12, 18)
        ..lineTo(18, 18)
        ..quadraticBezierTo(22, 10, 18, -8)
        ..close(),
      bodyShadePaint,
    );

    // پاها (انیمیشن دویدن پیشرفته)
    final legPaint = Paint()..color = const Color(0xFFE64A19);
    if (pose == FoxPose.run) {
      final phase1 = sin(runPhase);
      final phase2 = sin(runPhase + 3.14);
      canvas.save();
      canvas.translate(-6, 20);
      canvas.rotate(phase1 * 0.5);
      canvas.drawRect(Rect.fromLTWH(-3, 0, 7, 14), legPaint);
      canvas.restore();
      canvas.save();
      canvas.translate(6, 20);
      canvas.rotate(phase2 * 0.5);
      canvas.drawRect(Rect.fromLTWH(-4, 0, 7, 14), legPaint);
      canvas.restore();
    } else if (pose == FoxPose.jump || pose == FoxPose.fall) {
      canvas.drawRect(Rect.fromLTWH(-10, 17, 7, 9), legPaint);
      canvas.drawRect(Rect.fromLTWH(3, 17, 7, 9), legPaint);
    } else {
      canvas.drawRect(Rect.fromLTWH(-9, 20, 6, 10), legPaint);
      canvas.drawRect(Rect.fromLTWH(3, 20, 6, 10), legPaint);
    }

    // سر
    canvas.drawCircle(Offset.zero, 22, bodyPaint);

    // گوش‌ها
    final earPaint = Paint()..color = const Color(0xFFFF7043);
    canvas.drawPath(
      Path()
        ..moveTo(-20, -18)
        ..lineTo(-14, -34)
        ..lineTo(-8, -18)
        ..close(),
      earPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(20, -18)
        ..lineTo(14, -34)
        ..lineTo(8, -18)
        ..close(),
      earPaint,
    );
    final innerEarPaint = Paint()..color = const Color(0xFFF8BBD0);
    canvas.drawPath(
      Path()
        ..moveTo(-17, -19)
        ..lineTo(-14, -29)
        ..lineTo(-11, -19)
        ..close(),
      innerEarPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(17, -19)
        ..lineTo(14, -29)
        ..lineTo(11, -19)
        ..close(),
      innerEarPaint,
    );

    // پوزه سفید
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 6), width: 18, height: 14),
      Paint()..color = const Color(0xFFFFF3E0),
    );

    // بینی
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 2), width: 6, height: 5),
      Paint()..color = const Color(0xFF2E1840),
    );
    // درخشش بینی
    canvas.drawCircle(const Offset(-1, 1), 1, Paint()..color = Colors.white.withValues(alpha: 0.6));

    // چشم‌های درخشان بزرگتر
    final eyeWhitePaint = Paint()..color = Colors.white;
    canvas.drawCircle(const Offset(-9, -4), 7, eyeWhitePaint);
    canvas.drawCircle(const Offset(9, -4), 7, eyeWhitePaint);
    // مردمک
    final pupilColor = pose == FoxPose.hurt ? const Color(0xFFFF5252) : const Color(0xFF2E1840);
    canvas.drawCircle(const Offset(-9, -4), 4.2, Paint()..color = pupilColor);
    canvas.drawCircle(const Offset(9, -4), 4.2, Paint()..color = pupilColor);
    // درخشش چشم
    canvas.drawCircle(const Offset(-7.5, -5.5), 1.8, eyeWhitePaint);
    canvas.drawCircle(const Offset(10.5, -5.5), 1.8, eyeWhitePaint);
    // ابروها (در حالت hurt خشمگین)
    if (pose == FoxPose.hurt) {
      final browPaint = Paint()
        ..color = const Color(0xFF2E1840)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6;
      canvas.drawLine(const Offset(-13, -12), const Offset(-5, -10), browPaint);
      canvas.drawLine(const Offset(13, -12), const Offset(5, -10), browPaint);
    }

    // لبخند
    final smilePaint = Paint()
      ..color = const Color(0xFF2E1840)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    if (pose == FoxPose.hurt) {
      // لبخند معکوس
      canvas.drawPath(
        Path()
          ..moveTo(-5, 11)
          ..quadraticBezierTo(0, 8, 5, 11),
        smilePaint,
      );
    } else {
      canvas.drawPath(
        Path()
          ..moveTo(-5, 9)
          ..quadraticBezierTo(0, 12, 5, 9),
        smilePaint,
      );
    }

    // گونه‌های صورتی با gradient
    final cheekPaint = Paint()..color = const Color(0xFFF8BBD0).withValues(alpha: 0.75);
    canvas.drawCircle(const Offset(-13, 6), 3.5, cheekPaint);
    canvas.drawCircle(const Offset(13, 6), 3.5, cheekPaint);

    // دست‌ها با حالت‌های مختلف
    final armPaint = Paint()..color = const Color(0xFFFF7043);
    if (pose == FoxPose.run) {
      final armPhase1 = sin(runPhase + 0.5);
      final armPhase2 = sin(runPhase + 0.5 + 3.14);
      canvas.save();
      canvas.translate(15, 5);
      canvas.rotate(armPhase1 * 0.6);
      canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(0, -3, 14, 7), const Radius.circular(3)),
        armPaint,
      );
      canvas.restore();
      canvas.save();
      canvas.translate(-12, 5);
      canvas.rotate(armPhase2 * 0.6);
      canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(-14, -3, 14, 7), const Radius.circular(3)),
        armPaint,
      );
      canvas.restore();
    } else if (pose == FoxPose.jump) {
      canvas.save();
      canvas.translate(15, 0);
      canvas.rotate(-1.3);
      canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(0, -3, 14, 7), const Radius.circular(3)),
        armPaint,
      );
      canvas.restore();
      canvas.save();
      canvas.translate(-15, 0);
      canvas.rotate(1.3);
      canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(-14, -3, 14, 7), const Radius.circular(3)),
        armPaint,
      );
      canvas.restore();
    } else if (pose == FoxPose.hurt) {
      // دست‌ها کنار سر
      canvas.save();
      canvas.translate(15, -10);
      canvas.rotate(-1.8);
      canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(0, -3, 12, 6), const Radius.circular(3)),
        armPaint,
      );
      canvas.restore();
      canvas.save();
      canvas.translate(-15, -10);
      canvas.rotate(1.8);
      canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(-12, -3, 12, 6), const Radius.circular(3)),
        armPaint,
      );
      canvas.restore();
    } else {
      final wave = sin(breathPhase * 1.5) * 0.12;
      canvas.save();
      canvas.translate(15, 5);
      canvas.rotate(-0.2 + wave);
      canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(0, -3, 12, 6), const Radius.circular(3)),
        armPaint,
      );
      canvas.restore();
      canvas.save();
      canvas.translate(-15, 5);
      canvas.rotate(0.2 - wave);
      canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(-12, -3, 12, 6), const Radius.circular(3)),
        armPaint,
      );
      canvas.restore();
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant FoxCharacterPainter old) =>
      old.pose != pose ||
      old.breathPhase != breathPhase ||
      old.runPhase != runPhase ||
      old.hasShield != hasShield;
}
