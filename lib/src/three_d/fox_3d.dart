/// روباه سه‌بعدی ساخته‌شده با Zflutter — اشکال واقعی ۳بعدی
/// بدن: کره نارنجی، سر: کره، گوش‌ها: مخروط، دم: استوانه + کره،
/// پاها: استوانه، شنل: نیمکره بنفش
import 'package:flutter/material.dart';
import 'package:zflutter/zflutter.dart';

class Fox3D extends StatelessWidget {
  final double rotationY;
  final double rotationX;
  final double breath;
  final bool waving;

  const Fox3D({
    super.key,
    this.rotationY = 0,
    this.rotationX = 0,
    this.breath = 0,
    this.waving = true,
  });

  @override
  Widget build(BuildContext context) {
    final breathOffset = breath * 0.08;
    return ZIllustration(
      zoom: 5,
      center: ZVector.of(0, 0, 0),
      children: [
        ZGroup(
          rotation: ZVector.of(rotationX, rotationY, 0),
          children: [
            // شنل بنفش (پشت سر)
            ZPositioned(
              translate: ZVector.of(0, breathOffset, -1.2),
              child: ZShape(
                path: [
                  ZVector.of(-1.2, 0.5, 0),
                  ZVector.of(-1.4, -0.5, 0),
                  ZVector.of(-1.4, -1.5, 0.3),
                  ZVector.of(-0.6, -1.0, 0),
                ],
                color: const Color(0xFF7E57C2),
                fill: true,
                closed: true,
              ),
            ),

            // دم پف‌دار
            ZPositioned(
              translate: ZVector.of(-1.0, 0.2 + breathOffset, 0),
              rotate: ZVector.of(0, 0, 0.4 + breath * 0.3),
              child: ZCylinder(
                diameter: 0.6,
                length: 1.2,
                color: const Color(0xFFFF7043),
              ),
            ),
            ZPositioned(
              translate: ZVector.of(-1.7, 0.7 + breathOffset, 0),
              child: ZSphere(diameter: 0.7, color: Colors.white),
            ),

            // بدن
            ZPositioned(
              translate: ZVector.of(0, breathOffset, 0),
              child: ZSphere(diameter: 1.6, color: const Color(0xFFFF7043)),
            ),
            // شکم سفید
            ZPositioned(
              translate: ZVector.of(0, -0.3 + breathOffset, 0.6),
              child: ZSphere(diameter: 1.0, color: const Color(0xFFFFF3E0)),
            ),

            // پاها
            ZPositioned(
              translate: ZVector.of(-0.4, -1.0 + breathOffset, 0.3),
              child: ZCylinder(diameter: 0.3, length: 0.6, color: const Color(0xFFE64A19)),
            ),
            ZPositioned(
              translate: ZVector.of(0.4, -1.0 + breathOffset, 0.3),
              child: ZCylinder(diameter: 0.3, length: 0.6, color: const Color(0xFFE64A19)),
            ),

            // سر
            ZPositioned(
              translate: ZVector.of(0, 1.0 + breathOffset, 0),
              child: ZSphere(diameter: 1.2, color: const Color(0xFFFF7043)),
            ),

            // پوزه
            ZPositioned(
              translate: ZVector.of(0, 0.85 + breathOffset, 0.6),
              child: ZSphere(diameter: 0.6, color: const Color(0xFFFFF3E0)),
            ),
            // بینی
            ZPositioned(
              translate: ZVector.of(0, 0.95 + breathOffset, 0.85),
              child: ZSphere(diameter: 0.15, color: const Color(0xFF2E1840)),
            ),

            // گوش‌ها (مخروط)
            ZPositioned(
              translate: ZVector.of(-0.45, 1.7 + breathOffset, 0),
              rotate: ZVector.of(0, 0, -0.3),
              child: ZCone(diameter: 0.5, length: 0.7, color: const Color(0xFFFF7043)),
            ),
            ZPositioned(
              translate: ZVector.of(0.45, 1.7 + breathOffset, 0),
              rotate: ZVector.of(0, 0, 0.3),
              child: ZCone(diameter: 0.5, length: 0.7, color: const Color(0xFFFF7043)),
            ),

            // چشم‌ها
            ZPositioned(
              translate: ZVector.of(-0.3, 1.1 + breathOffset, 0.5),
              child: ZSphere(diameter: 0.25, color: Colors.white),
            ),
            ZPositioned(
              translate: ZVector.of(-0.3, 1.1 + breathOffset, 0.6),
              child: ZSphere(diameter: 0.15, color: const Color(0xFF2E1840)),
            ),
            ZPositioned(
              translate: ZVector.of(0.3, 1.1 + breathOffset, 0.5),
              child: ZSphere(diameter: 0.25, color: Colors.white),
            ),
            ZPositioned(
              translate: ZVector.of(0.3, 1.1 + breathOffset, 0.6),
              child: ZSphere(diameter: 0.15, color: const Color(0xFF2E1840)),
            ),

            // دست‌ها
            if (waving)
              ZPositioned(
                translate: ZVector.of(0.8, 0.2 + breathOffset, 0.3),
                rotate: ZVector.of(0, 0, -0.8 + breath * 0.5),
                child: ZCylinder(diameter: 0.25, length: 0.7, color: const Color(0xFFFF7043)),
              )
            else
              ZPositioned(
                translate: ZVector.of(0.8, -0.1 + breathOffset, 0.3),
                child: ZCylinder(diameter: 0.25, length: 0.6, color: const Color(0xFFFF7043)),
              ),
            ZPositioned(
              translate: ZVector.of(-0.8, -0.1 + breathOffset, 0.3),
              child: ZCylinder(diameter: 0.25, length: 0.6, color: const Color(0xFFFF7043)),
            ),
          ],
        ),
      ],
    );
  }
}
