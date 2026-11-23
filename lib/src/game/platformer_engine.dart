/// موتور پلتفرمر با فیزیک واقعی: گرانش، پرش، پرش دوم، برخورد با سکوها،
/// جمع‌کردن سکه، برخورد با دشمن، رسیدن به در خروجی.
import 'dart:math';
import 'package:flutter/material.dart';
import '../game_store.dart';

class PlatformEntity {
  final String id;
  final Offset position;       // مرکز در مختصات بازی
  final Size size;
  final EntityType type;
  PlatformEntity({
    required this.id,
    required this.position,
    required this.size,
    required this.type,
  });
}

enum EntityType { platform, coin, enemy, exit, decoration }

class PlatformerEngine {
  // مختصات بازی: y به پایین مثبت است. (0,0) گوشهٔ بالا-چپ است.
  // پلیر در playerX، playerY قرار دارد (مرکز پلیر).
  double playerX = 80;
  double playerY = 0;
  double playerVx = 0;
  double playerVy = 0;
  bool onGround = false;
  int jumpsLeft = 2;          // پرش + پرش دوم
  double facing = 1;          // 1 = راست، -1 = چپ
  bool alive = true;
  bool won = false;
  int score = 0;
  int lives = 3;

  // تنظیمات فیزیک
  static const double gravity = 1200;     // پیکسل بر ثانیه²
  static const double moveSpeed = 220;    // پیکسل بر ثانیه
  static const double jumpVelocity = 540; // پیکسل بر ثانیه
  static const double maxFallSpeed = 900;
  static const double friction = 0.85;

  // جهان
  final Size worldSize;
  final List<PlatformEntity> entities;
  final double groundY;                   // y بالای زمین

  // ذرات
  // (سیستم ذرات جداگانه مدیریت می‌شود)

  PlatformerEngine({
    required this.worldSize,
    required this.entities,
    required this.groundY,
    double startX = 80,
    double startY = 0,
  }) {
    playerX = startX;
    playerY = startY == 0 ? groundY - 30 : startY;
  }

  void setInput({double horizontal = 0, bool jumpPressed = false}) {
    if (!alive || won) return;
    playerVx = horizontal * moveSpeed;
    if (horizontal != 0) facing = horizontal > 0 ? 1 : -1;
    if (jumpPressed && jumpsLeft > 0) {
      playerVy = -jumpVelocity;
      jumpsLeft--;
      onGround = false;
    }
  }

  void update(double dt) {
    if (!alive || won) return;

    // گرانش
    playerVy += gravity * dt;
    if (playerVy > maxFallSpeed) playerVy = maxFallSpeed;

    // حرکت افقی
    final newX = playerX + playerVx * dt;
    // محدودیت افقی به جهان
    final playerHalfW = 16.0;
    final clampedX = newX.clamp(playerHalfW, worldSize.width - playerHalfW);
    playerX = clampedX;

    // حرکت عمودی + برخورد با سکوها
    final newY = playerY + playerVy * dt;
    final playerHalfH = 22.0;
    bool landed = false;
    double resolvedY = newY;

    // برخورد با زمین
    if (newY + playerHalfH >= groundY) {
      resolvedY = groundY - playerHalfH;
      if (playerVy > 0) {
        landed = true;
      }
      playerVy = 0;
    }

    // برخورد با سکوها (فقط از بالا)
    if (playerVy > 0) {
      for (final e in entities) {
        if (e.type != EntityType.platform) continue;
        final left = e.position.dx - e.size.width / 2;
        final right = e.position.dx + e.size.width / 2;
        final top = e.position.dy - e.size.height / 2;
        final bottom = e.position.dy + e.size.height / 2;
        // آیا پلیر از افقی با سکو هم‌خاب است؟
        if (playerX + playerHalfW > left && playerX - playerHalfW < right) {
          // آیا پلیر داشت از بالا می‌آمد؟
          if (playerY + playerHalfH <= top + 4 && resolvedY + playerHalfH >= top) {
            resolvedY = top - playerHalfH;
            landed = true;
            playerVy = 0;
          }
        }
      }
    }

    final wasOnGround = onGround;
    playerY = resolvedY;
    onGround = landed;
    if (onGround && !wasOnGround) {
      // فرود — ذرات گرد و غبار توسط caller اضافه می‌شود
    }
    if (onGround) {
      jumpsLeft = 2;  // ریست پرش‌ها
    }

    // جمع‌کردن سکه
    for (final e in entities) {
      if (e.type != EntityType.coin) continue;
      final dx = (e.position.dx - playerX).abs();
      final dy = (e.position.dy - playerY).abs();
      if (dx < 24 && dy < 24) {
        score += 10;
        e.id; // رفع warning
        // حذف با collectionmodifiable در caller
      }
    }

    // برخورد با دشمن
    for (final e in entities) {
      if (e.type != EntityType.enemy) continue;
      final dx = (e.position.dx - playerX).abs();
      final dy = (e.position.dy - playerY).abs();
      if (dx < 22 && dy < 22) {
        // اگر از بالا بیاید (stomp)، دشمن را بکش؛ وگرنه پلیر آسیب می‌بیند
        if (playerVy > 0 && playerY < e.position.dy) {
          // حذف دشمن (در caller)
          score += 20;
          playerVy = -jumpVelocity * 0.6; // پرش کوچک بعد از stomp
        } else {
          lives--;
          if (lives <= 0) {
            alive = false;
          } else {
            // ریست به شروع
            playerX = 80;
            playerY = groundY - 30;
            playerVy = 0;
          }
        }
      }
    }

    // رسیدن به در خروجی
    for (final e in entities) {
      if (e.type != EntityType.exit) continue;
      final dx = (e.position.dx - playerX).abs();
      final dy = (e.position.dy - playerY).abs();
      if (dx < 24 && dy < 30) {
        won = true;
      }
    }
  }

  // لیست سکه‌های جمع‌شده برای حذف از صفحه
  List<String> collectedCoins = [];
  List<String> stompedEnemies = [];
}

/// تبدیل یک GameProject به دنیای پلتفرمر
PlatformerEngine buildPlatformerFromProject(GameProject project, Size canvasSize) {
  // ساده‌سازی: هر سلول grid به یک سکو در جهان تبدیل می‌شود
  // canvas به اندازهٔ canvasSize است، همهٔ سکوها در همان فضا قرار می‌گیرند.
  final cellW = canvasSize.width / project.cols;
  final cellH = (canvasSize.height * 0.6) / project.rows; // 60% از ارتفاع canvas برای بازی
  final groundY = canvasSize.height * 0.85;
  final entities = <PlatformEntity>[];

  for (final item in project.items) {
    final cx = (item.col + 0.5) * cellW;
    final cy = (item.row + 0.5) * cellH + canvasSize.height * 0.15;
    switch (item.role) {
      case ItemRole.decoration:
        // تزئین در جای خودش (روی زمین یا سکو)
        entities.add(PlatformEntity(
          id: 'dec-${item.id}',
          position: Offset(cx, cy),
          size: const Size(40, 40),
          type: EntityType.decoration,
        ));
        break;
      case ItemRole.coin:
        entities.add(PlatformEntity(
          id: 'coin-${item.id}',
          position: Offset(cx, cy),
          size: const Size(36, 36),
          type: EntityType.coin,
        ));
        break;
      case ItemRole.enemy:
        entities.add(PlatformEntity(
          id: 'enemy-${item.id}',
          position: Offset(cx, cy),
          size: const Size(40, 40),
          type: EntityType.enemy,
        ));
        break;
      case ItemRole.exit:
        entities.add(PlatformEntity(
          id: 'exit-${item.id}',
          position: Offset(cx, cy),
          size: const Size(40, 50),
          type: EntityType.exit,
        ));
        break;
    }
  }

  // اگر هیچ در خروجی نیست، یک در در انتهای جهان اضافه کن
  if (!entities.any((e) => e.type == EntityType.exit)) {
    entities.add(PlatformEntity(
      id: 'exit-auto',
      position: Offset(canvasSize.width - 40, groundY - 25),
      size: const Size(40, 50),
      type: EntityType.exit,
    ));
  }

  return PlatformerEngine(
    worldSize: canvasSize,
    entities: entities,
    groundY: groundY,
    startX: 40,
    startY: groundY - 30,
  );
}
