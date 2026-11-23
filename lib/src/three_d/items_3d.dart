/// آیتم‌های سه‌بعدی: سکه، دشمن، در خروجی، گل، سپر، آهنربا، سرعت، جان
import 'package:flutter/material.dart';
import 'package:zflutter/zflutter.dart';

/// سکهٔ ۳بعدی — استوانه طلایی نازک که می‌چرخد
class Coin3D extends StatelessWidget {
  final double spinY;
  const Coin3D({super.key, this.spinY = 0});

  @override
  Widget build(BuildContext context) {
    return ZIllustration(
      zoom: 6,
      children: [
        ZPositioned(
          rotate: ZVector.of(0, spinY, 0),
          child: ZCylinder(
            diameter: 1.2,
            length: 0.15,
            color: const Color(0xFFFFD54F),
            front: const Color(0xFFFFF59D),
            back: const Color(0xFFFF8F00),
          ),
        ),
      ],
    );
  }
}

/// دشمن ۳بعدی — کره قرمز با خارهای مخروطی
class Enemy3D extends StatelessWidget {
  final double rotation;
  const Enemy3D({super.key, this.rotation = 0});

  @override
  Widget build(BuildContext context) {
    final spikes = <Widget>[];
    for (int i = 0; i < 8; i++) {
      final angle = i * 3.14159 / 4;
      final x = 0.6 * cos(angle);
      final y = 0.6 * sin(angle);
      spikes.add(
        ZPositioned(
          translate: ZVector.of(x, y, 0),
          rotate: ZVector.of(0, 0, angle),
          child: ZCone(
            diameter: 0.2,
            length: 0.4,
            color: const Color(0xFFB71C1C),
          ),
        ),
      );
    }
    for (int i = 0; i < 4; i++) {
      final angle = i * 3.14159 / 2 + 0.4;
      spikes.add(
        ZPositioned(
          translate: ZVector.of(0.6 * cos(angle), 0.6 * sin(angle), 0),
          rotate: ZVector.of(angle, 0, 0),
          child: ZCone(
            diameter: 0.2,
            length: 0.4,
            color: const Color(0xFFB71C1C),
          ),
        ),
      );
    }
    return ZIllustration(
      zoom: 5,
      children: [
        ZPositioned(
          rotate: ZVector.of(0, rotation, 0),
          child: ZGroup(
            children: [
              ZSphere(diameter: 1.2, color: const Color(0xFFEF5350)),
              ...spikes,
              // چشم‌ها
              ZPositioned(
                translate: ZVector.of(-0.3, 0.1, 0.5),
                child: ZSphere(diameter: 0.2, color: Colors.white),
              ),
              ZPositioned(
                translate: ZVector.of(0.3, 0.1, 0.5),
                child: ZSphere(diameter: 0.2, color: Colors.white),
              ),
              ZPositioned(
                translate: ZVector.of(-0.3, 0.1, 0.6),
                child: ZSphere(diameter: 0.1, color: const Color(0xFF2E1840)),
              ),
              ZPositioned(
                translate: ZVector.of(0.3, 0.1, 0.6),
                child: ZSphere(diameter: 0.1, color: const Color(0xFF2E1840)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// در خروجی ۳بعدی — مکعب سبز با ستارهٔ کره‌ای بالای آن
class ExitDoor3D extends StatelessWidget {
  final double pulse;
  const ExitDoor3D({super.key, this.pulse = 0});

  @override
  Widget build(BuildContext context) {
    return ZIllustration(
      zoom: 4,
      children: [
        ZGroup(
          children: [
            // قاب در
            ZPositioned(
              translate: ZVector.of(0, 0, 0),
              child: ZBox(
                width: 1.4,
                height: 2.0,
                depth: 0.2,
                color: const Color(0xFF2E7D32),
              ),
            ),
            // خود در
            ZPositioned(
              translate: ZVector.of(0, 0, 0.15),
              child: ZBox(
                width: 1.1,
                height: 1.7,
                depth: 0.05,
                color: const Color(0xFF66BB6A),
              ),
            ),
            // ستارهٔ بالای در
            ZPositioned(
              translate: ZVector.of(0, 1.3 + pulse * 0.1, 0.2),
              child: ZSphere(diameter: 0.3, color: const Color(0xFFFFD54F)),
            ),
          ],
        ),
      ],
    );
  }
}

/// سپر ۳بعدی — دو نیمکره آبی
class Shield3D extends StatelessWidget {
  final double pulse;
  const Shield3D({super.key, this.pulse = 0});

  @override
  Widget build(BuildContext context) {
    return ZIllustration(
      zoom: 5,
      children: [
        ZGroup(
          children: [
            ZSphere(
              diameter: 1.2 + pulse * 0.1,
              color: const Color(0xFF42A5F5).withValues(alpha: 0.6),
            ),
            ZSphere(
              diameter: 0.9,
              color: const Color(0xFF1976D2),
            ),
          ],
        ),
      ],
    );
  }
}

/// آهنربا ۳بعدی — U قرمز با قطب‌های سفید
class Magnet3D extends StatelessWidget {
  const Magnet3D({super.key});

  @override
  Widget build(BuildContext context) {
    return ZIllustration(
      zoom: 5,
      children: [
        ZGroup(
          children: [
            // بازوی چپ
            ZPositioned(
              translate: ZVector.of(-0.5, 0, 0),
              child: ZBox(
                width: 0.4,
                height: 1.6,
                depth: 0.4,
                color: const Color(0xFFEF5350),
              ),
            ),
            // بازوی راست
            ZPositioned(
              translate: ZVector.of(0.5, 0, 0),
              child: ZBox(
                width: 0.4,
                height: 1.6,
                depth: 0.4,
                color: const Color(0xFFEF5350),
              ),
            ),
            // پایین
            ZPositioned(
              translate: ZVector.of(0, -0.7, 0),
              child: ZBox(
                width: 1.4,
                height: 0.4,
                depth: 0.4,
                color: const Color(0xFFEF5350),
              ),
            ),
            // قطب چپ سفید
            ZPositioned(
              translate: ZVector.of(-0.5, 0.8, 0),
              child: ZBox(
                width: 0.4,
                height: 0.3,
                depth: 0.4,
                color: Colors.white,
              ),
            ),
            // قطب راست سفید
            ZPositioned(
              translate: ZVector.of(0.5, 0.8, 0),
              child: ZBox(
                width: 0.4,
                height: 0.3,
                depth: 0.4,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// صاعقه سرعت ۳بعدی — هرم بنفش
class SpeedBoost3D extends StatelessWidget {
  const SpeedBoost3D({super.key});

  @override
  Widget build(BuildContext context) {
    return ZIllustration(
      zoom: 5,
      children: [
        ZCone(
          diameter: 1.2,
          length: 2.0,
          color: const Color(0xFFAB47BC),
        ),
      ],
    );
  }
}

/// جان اضافه ۳بعدی — قلب از دو کره + یک مخروط
class ExtraLife3D extends StatelessWidget {
  const ExtraLife3D({super.key});

  @override
  Widget build(BuildContext context) {
    return ZIllustration(
      zoom: 5,
      children: [
        ZGroup(
          children: [
            ZPositioned(
              translate: ZVector.of(-0.4, 0.2, 0),
              child: ZSphere(diameter: 0.8, color: const Color(0xFFEC407A)),
            ),
            ZPositioned(
              translate: ZVector.of(0.4, 0.2, 0),
              child: ZSphere(diameter: 0.8, color: const Color(0xFFEC407A)),
            ),
            ZPositioned(
              translate: ZVector.of(0, -0.6, 0),
              rotate: ZVector.of(0, 0, 3.14159),
              child: ZCone(
                diameter: 0.9,
                length: 1.0,
                color: const Color(0xFFEC407A),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// تابع کمکی برای ساخت ویجت ۳بعدی بر اساس نوع آیتم
Widget item3DForType(String type, double t) {
  final phase = t * 6.28;
  switch (type) {
    case 'coin':        return Coin3D(spinY: phase);
    case 'enemy':       return Enemy3D(rotation: phase * 0.5);
    case 'exit':        return ExitDoor3D(pulse: (sin(phase) + 1) / 2);
    case 'shield':      return Shield3D(pulse: (sin(phase) + 1) / 2);
    case 'magnet':      return const Magnet3D();
    case 'speedBoost':  return const SpeedBoost3D();
    case 'extraLife':   return const ExtraLife3D();
    default:            return const Coin3D();
  }
}
