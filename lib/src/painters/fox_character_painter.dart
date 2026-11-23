/// نقاش روباه — با جزئیات کامل، همه اعداد double
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
    this.breathPhase = 0.0,
    this.runPhase = 0.0,
    this.hasShield = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 100.0;
    canvas.save();
    canvas.translate(size.width / 2.0, size.height / 2.0);
    canvas.scale(s);

    if (hasShield) {
      final shieldGlow = Paint()
        ..color = const Color(0xFF42A5F5).withValues(alpha: 0.4 + 0.2 * sin(breathPhase * 2.0));
      canvas.drawCircle(Offset.zero, 36.0, shieldGlow);
      final shieldRing = Paint()
        ..color = const Color(0xFF42A5F5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawCircle(Offset.zero, 32.0, shieldRing);
    }

    double squash = 1.0;
    if (pose == FoxPose.idle) {
      canvas.translate(0.0, sin(breathPhase) * 1.5);
    } else if (pose == FoxPose.jump) {
      squash = 1.18;
      canvas.scale(1.0 / squash, squash);
    } else if (pose == FoxPose.fall) {
      squash = 0.85;
      canvas.scale(1.0 / squash, squash);
    } else if (pose == FoxPose.hurt) {
      canvas.rotate(sin(breathPhase * 8.0) * 0.15);
    }

    // شنل
    final double capeSway = (pose == FoxPose.run ? sin(runPhase * 2.0) * 4.0 : 0.0);
    final capePaint = Paint()..color = const Color(0xFF7E57C2);
    final capePath = Path()
      ..moveTo(-22.0, -10.0)
      ..quadraticBezierTo(-32.0 - capeSway, 14.0, -28.0 - capeSway, 40.0)
      ..quadraticBezierTo(-15.0 - capeSway, 34.0, -8.0, 25.0)
      ..quadraticBezierTo(-12.0, 5.0, -22.0, -10.0)
      ..close();
    canvas.drawPath(capePath, capePaint);
    final capeEdgePath = Path()
      ..moveTo(-28.0 - capeSway, 32.0)
      ..quadraticBezierTo(-22.0 - capeSway, 24.0, -14.0, 26.0)
      ..lineTo(-16.0, 32.0)
      ..close();
    canvas.drawPath(capeEdgePath, Paint()..color = const Color(0xFFB388FF));
    final sparklePaint = Paint()..color = const Color(0xFFFFF59D);
    for (int i = 0; i < 3; i++) {
      final sy = (-5.0 + i * 15.0);
      final sx = -20.0 - capeSway * (i + 1) * 0.3;
      canvas.drawCircle(Offset(sx, sy), 1.0, sparklePaint);
    }

    // دم
    final double tailY = pose == FoxPose.run ? -8.0 : 0.0;
    final double tailSway = sin(breathPhase * 1.5) * 3.0;
    final tailPaint = Paint()..color = const Color(0xFFFF7043);
    final tailPath = Path()
      ..moveTo(-18.0, 15.0 + tailY)
      ..quadraticBezierTo(-40.0 - tailSway, -2.0 + tailY, -34.0 - tailSway, -22.0 + tailY)
      ..quadraticBezierTo(-22.0, -10.0 + tailY, -16.0, 5.0 + tailY)
      ..close();
    canvas.drawPath(tailPath, tailPaint);
    final tailTipPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(-32.0 - tailSway, -16.0 + tailY), 7.0, tailTipPaint);
    canvas.drawCircle(Offset(-29.0 - tailSway, -13.0 + tailY), 3.0, Paint()..color = const Color(0xFFFFCCBC));

    // بدن
    final bodyPaint = Paint()..color = const Color(0xFFFF7043);
    final bodyPath = Path()
      ..moveTo(-18.0, -8.0)
      ..quadraticBezierTo(-22.0, 15.0, -10.0, 22.0)
      ..lineTo(10.0, 22.0)
      ..quadraticBezierTo(22.0, 15.0, 18.0, -8.0)
      ..close();
    canvas.drawPath(bodyPath, bodyPaint);
    canvas.drawPath(
      Path()
        ..moveTo(-8.0, -2.0)
        ..quadraticBezierTo(-10.0, 18.0, 0.0, 22.0)
        ..quadraticBezierTo(10.0, 18.0, 8.0, -2.0)
        ..close(),
      Paint()..color = const Color(0xFFFFF3E0),
    );
    final bodyShadePaint = Paint()..color = const Color(0xFFE64A19).withValues(alpha: 0.3);
    canvas.drawPath(
      Path()
        ..moveTo(8.0, -5.0)
        ..quadraticBezierTo(15.0, 5.0, 12.0, 18.0)
        ..lineTo(18.0, 18.0)
        ..quadraticBezierTo(22.0, 10.0, 18.0, -8.0)
        ..close(),
      bodyShadePaint,
    );

    // پاها
    final legPaint = Paint()..color = const Color(0xFFE64A19);
    if (pose == FoxPose.run) {
      final phase1 = sin(runPhase);
      final phase2 = sin(runPhase + 3.14);
      canvas.save();
      canvas.translate(-6.0, 20.0);
      canvas.rotate(phase1 * 0.5);
      canvas.drawRect(Rect.fromLTWH(-3.0, 0.0, 7.0, 14.0), legPaint);
      canvas.restore();
      canvas.save();
      canvas.translate(6.0, 20.0);
      canvas.rotate(phase2 * 0.5);
      canvas.drawRect(Rect.fromLTWH(-4.0, 0.0, 7.0, 14.0), legPaint);
      canvas.restore();
    } else if (pose == FoxPose.jump || pose == FoxPose.fall) {
      canvas.drawRect(Rect.fromLTWH(-10.0, 17.0, 7.0, 9.0), legPaint);
      canvas.drawRect(Rect.fromLTWH(3.0, 17.0, 7.0, 9.0), legPaint);
    } else {
      canvas.drawRect(Rect.fromLTWH(-9.0, 20.0, 6.0, 10.0), legPaint);
      canvas.drawRect(Rect.fromLTWH(3.0, 20.0, 6.0, 10.0), legPaint);
    }

    // سر
    canvas.drawCircle(Offset.zero, 22.0, bodyPaint);

    // گوش‌ها
    final earPaint = Paint()..color = const Color(0xFFFF7043);
    canvas.drawPath(
      Path()
        ..moveTo(-20.0, -18.0)
        ..lineTo(-14.0, -34.0)
        ..lineTo(-8.0, -18.0)
        ..close(),
      earPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(20.0, -18.0)
        ..lineTo(14.0, -34.0)
        ..lineTo(8.0, -18.0)
        ..close(),
      earPaint,
    );
    final innerEarPaint = Paint()..color = const Color(0xFFF8BBD0);
    canvas.drawPath(
      Path()
        ..moveTo(-17.0, -19.0)
        ..lineTo(-14.0, -29.0)
        ..lineTo(-11.0, -19.0)
        ..close(),
      innerEarPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(17.0, -19.0)
        ..lineTo(14.0, -29.0)
        ..lineTo(11.0, -19.0)
        ..close(),
      innerEarPaint,
    );

    // پوزه
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0.0, 6.0), width: 18.0, height: 14.0),
      Paint()..color = const Color(0xFFFFF3E0),
    );
    // بینی
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0.0, 2.0), width: 6.0, height: 5.0),
      Paint()..color = const Color(0xFF2E1840),
    );
    canvas.drawCircle(const Offset(-1.0, 1.0), 1.0, Paint()..color = Colors.white.withValues(alpha: 0.6));

    // چشم‌ها
    final eyeWhitePaint = Paint()..color = Colors.white;
    canvas.drawCircle(const Offset(-9.0, -4.0), 7.0, eyeWhitePaint);
    canvas.drawCircle(const Offset(9.0, -4.0), 7.0, eyeWhitePaint);
    final pupilColor = pose == FoxPose.hurt ? const Color(0xFFFF5252) : const Color(0xFF2E1840);
    canvas.drawCircle(const Offset(-9.0, -4.0), 4.2, Paint()..color = pupilColor);
    canvas.drawCircle(const Offset(9.0, -4.0), 4.2, Paint()..color = pupilColor);
    canvas.drawCircle(const Offset(-7.5, -5.5), 1.8, eyeWhitePaint);
    canvas.drawCircle(const Offset(10.5, -5.5), 1.8, eyeWhitePaint);

    if (pose == FoxPose.hurt) {
      final browPaint = Paint()
        ..color = const Color(0xFF2E1840)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6;
      canvas.drawLine(const Offset(-13.0, -12.0), const Offset(-5.0, -10.0), browPaint);
      canvas.drawLine(const Offset(13.0, -12.0), const Offset(5.0, -10.0), browPaint);
    }

    // لبخند
    final smilePaint = Paint()
      ..color = const Color(0xFF2E1840)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    if (pose == FoxPose.hurt) {
      canvas.drawPath(
        Path()
          ..moveTo(-5.0, 11.0)
          ..quadraticBezierTo(0.0, 8.0, 5.0, 11.0),
        smilePaint,
      );
    } else {
      canvas.drawPath(
        Path()
          ..moveTo(-5.0, 9.0)
          ..quadraticBezierTo(0.0, 12.0, 5.0, 9.0),
        smilePaint,
      );
    }

    // گونه‌ها
    final cheekPaint = Paint()..color = const Color(0xFFF8BBD0).withValues(alpha: 0.75);
    canvas.drawCircle(const Offset(-13.0, 6.0), 3.5, cheekPaint);
    canvas.drawCircle(const Offset(13.0, 6.0), 3.5, cheekPaint);

    // دست‌ها
    final armPaint = Paint()..color = const Color(0xFFFF7043);
    if (pose == FoxPose.run) {
      final armPhase1 = sin(runPhase + 0.5);
      final armPhase2 = sin(runPhase + 0.5 + 3.14);
      canvas.save();
      canvas.translate(15.0, 5.0);
      canvas.rotate(armPhase1 * 0.6);
      canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(0.0, -3.0, 14.0, 7.0), const Radius.circular(3.0)), armPaint);
      canvas.restore();
      canvas.save();
      canvas.translate(-12.0, 5.0);
      canvas.rotate(armPhase2 * 0.6);
      canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-14.0, -3.0, 14.0, 7.0), const Radius.circular(3.0)), armPaint);
      canvas.restore();
    } else if (pose == FoxPose.jump) {
      canvas.save();
      canvas.translate(15.0, 0.0);
      canvas.rotate(-1.3);
      canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(0.0, -3.0, 14.0, 7.0), const Radius.circular(3.0)), armPaint);
      canvas.restore();
      canvas.save();
      canvas.translate(-15.0, 0.0);
      canvas.rotate(1.3);
      canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-14.0, -3.0, 14.0, 7.0), const Radius.circular(3.0)), armPaint);
      canvas.restore();
    } else if (pose == FoxPose.hurt) {
      canvas.save();
      canvas.translate(15.0, -10.0);
      canvas.rotate(-1.8);
      canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(0.0, -3.0, 12.0, 6.0), const Radius.circular(3.0)), armPaint);
      canvas.restore();
      canvas.save();
      canvas.translate(-15.0, -10.0);
      canvas.rotate(1.8);
      canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-12.0, -3.0, 12.0, 6.0), const Radius.circular(3.0)), armPaint);
      canvas.restore();
    } else {
      final wave = sin(breathPhase * 1.5) * 0.12;
      canvas.save();
      canvas.translate(15.0, 5.0);
      canvas.rotate(-0.2 + wave);
      canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(0.0, -3.0, 12.0, 6.0), const Radius.circular(3.0)), armPaint);
      canvas.restore();
      canvas.save();
      canvas.translate(-15.0, 5.0);
      canvas.rotate(0.2 - wave);
      canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-12.0, -3.0, 12.0, 6.0), const Radius.circular(3.0)), armPaint);
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
