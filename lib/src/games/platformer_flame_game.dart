/// موتور بازی پلتفرمر با Flame + Forge2D
/// فیزیک واقعی: گرانش، بدن پویا، سکوهای استاتیک، سکه‌های sensor،
/// دشمن‌های kinematic با گشت‌و‌برگشت، در خروجی sensor.
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import '../audio/audio_manager.dart';

/// یک آیتم در دنیای پلتفرمر
class PlatformerEntity {
  final String id;
  final Offset position; // در مختصات Forge2D (مرکز)
  final double width;
  final double height;
  final String type; // 'coin', 'enemy', 'exit', 'decoration'
  PlatformerEntity({
    required this.id,
    required this.position,
    required this.width,
    required this.height,
    required this.type,
  });
}

/// ساخت لیست موجودیت‌ها از یک GameProject ساده
/// هر سلول grid به یک موجودیت تبدیل می‌شود.
List<PlatformerEntity> entitiesFromGrid({
  required int rows,
  required int cols,
  required int startRow,
  required int startCol,
  required List<({int id, int row, int col, String type})> items,
}) {
  // مختصات Forge2D: world به اندازهٔ 20 واحد عرض، 30 واحد ارتفاع
  const worldW = 20.0;
  const worldH = 30.0;
  final cellW = worldW / cols;
  final cellH = worldH / rows;
  return items.map((it) {
    final cx = (it.col + 0.5) * cellW;
    final cy = worldH - (it.row + 0.5) * cellH; // y معکوس
    return PlatformerEntity(
      id: '${it.type}-${it.id}',
      position: Offset(cx, cy),
      width: cellW * 0.8,
      height: cellH * 0.8,
      type: it.type,
    );
  }).toList();
}

// ------- Components -------

class PlayerBody extends BodyComponent {
  final Vector2 initialPosition;
  final VoidCallback onLand;
  final VoidCallback onJump;
  PlayerBody({required this.initialPosition, required this.onLand, required this.onJump});

  @override
  Body createBody() {
    final def = BodyDef()
      ..type = BodyType.dynamic
      ..position = initialPosition
      ..fixedRotation = true
      ..gravityScale = 1.0;
    final body = world.createBody(def);
    final shape = CircleShape()..radius = 0.7;
    final fixture = FixtureDef(shape)
      ..restitution = 0.0
      ..friction = 0.3
      ..density = 1.0;
    body.createFixture(fixture);
    return body;
  }

  void jump() {
    if (body.linearVelocity.y.abs() < 0.5) {
      body.applyLinearImpulse(Vector2(0, 8));
      onJump();
    }
  }

  void moveHorizontal(double dir) {
    body.linearVelocity = Vector2(dir * 6, body.linearVelocity.y);
  }
}

class PlatformBody extends BodyComponent {
  final Vector2 position;
  final Vector2 size;
  PlatformBody({required this.position, required this.size});

  @override
  Body createBody() {
    final def = BodyDef()
      ..type = BodyType.static
      ..position = position;
    final body = world.createBody(def);
    final shape = PolygonShape()..setAsBox(size.x / 2, size.y / 2);
    body.createFixture(FixtureDef(shape)..friction = 0.4);
    return body;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // رسم ظاهر سکو
    final paint = Paint()..color = const Color(0xFF8D6E63);
    final rect = Rect.fromCenter(center: Offset.zero, width: size.x, height: size.y);
    canvas.drawRect(rect, paint);
    // چمن روی سکو
    canvas.drawRect(
      Rect.fromLTWH(rect.left, rect.top, rect.width, 0.2),
      Paint()..color = const Color(0xFF7CB342),
    );
  }
}

class CoinBody extends BodyComponent {
  final VoidCallback onCollect;
  CoinBody({required Vector2 position, required this.onCollect}) {
    this.position = position;
  }

  @override
  Body createBody() {
    final def = BodyDef()
      ..type = BodyType.static
      ..position = position
      ..userData = 'coin';
    final body = world.createBody(def);
    final shape = CircleShape()..radius = 0.4;
    body.createFixture(FixtureDef(shape)..isSensor = true);
    return body;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()
      ..color = const Color(0xFFFFD54F);
    canvas.drawCircle(Offset.zero, 0.4, paint);
    // درخشش
    final glow = Paint()
      ..color = const Color(0xFFFFF59D).withValues(alpha: 0.5);
    canvas.drawCircle(Offset.zero, 0.6, glow);
  }
}

class EnemyBody extends BodyComponent {
  final double patrolRange;
  final VoidCallback onStomp;
  final VoidCallback onPlayerHit;
  late double _originX;
  double _direction = 1;

  EnemyBody({
    required Vector2 position,
    required this.patrolRange,
    required this.onStomp,
    required this.onPlayerHit,
  }) {
    this.position = position;
  }

  @override
  Body createBody() {
    _originX = position.x;
    final def = BodyDef()
      ..type = BodyType.kinematic
      ..position = position
      ..userData = 'enemy';
    final body = world.createBody(def);
    final shape = CircleShape()..radius = 0.5;
    body.createFixture(FixtureDef(shape));
    return body;
  }

  @override
  void update(double dt) {
    super.update(dt);
    // گشت‌و‌برگشت
    body.linearVelocity = Vector2(_direction * 2, 0);
    if ((body.position.x - _originX).abs() > patrolRange) {
      _direction *= -1;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()..color = const Color(0xFFEF5350);
    canvas.drawCircle(Offset.zero, 0.5, paint);
    // خارها
    final spikePaint = Paint()..color = const Color(0xFFB71C1C);
    for (int i = 0; i < 8; i++) {
      final a = i * 3.14159 / 4;
      final path = Path()
        ..moveTo(0.5 * cos(a), 0.5 * sin(a))
        ..lineTo(0.7 * cos(a), 0.7 * sin(a))
        ..lineTo(0.6 * cos(a + 0.3), 0.6 * sin(a + 0.3))
        ..close();
      canvas.drawPath(path, spikePaint);
    }
  }
}

class ExitBody extends BodyComponent {
  final VoidCallback onReach;
  ExitBody({required Vector2 position, required this.onReach}) {
    this.position = position;
  }

  @override
  Body createBody() {
    final def = BodyDef()
      ..type = BodyType.static
      ..position = position
      ..userData = 'exit';
    final body = world.createBody(def);
    final shape = PolygonShape()..setAsBox(0.6, 1.0);
    body.createFixture(FixtureDef(shape)..isSensor = true);
    return body;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // هالهٔ سبز
    final glow = Paint()..color = const Color(0xFFB9F6CA).withValues(alpha: 0.5);
    canvas.drawCircle(Offset.zero, 1.5, glow);
    // قاب در
    final frame = Paint()..color = const Color(0xFF2E7D32);
    canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: 1.2, height: 2.0), frame);
    // خود در
    final door = Paint()..color = const Color(0xFF66BB6A);
    canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: 1.0, height: 1.8), door);
    // ستاره بالای در
    final star = Paint()..color = const Color(0xFFFFD54F);
    canvas.drawCircle(const Offset(0, -1.3), 0.2, star);
  }
}

/// خود بازی Flame/Forge2D
class PlatformerFlameGame extends Forge2DGame with TapDetector, PanDetector {
  final List<PlatformerEntity> entities;
  final VoidCallback onWin;
  final VoidCallback onLose;
  final VoidCallback onCoinCollected;
  final VoidCallback onJump;
  final VoidCallback onLand;
  late PlayerBody _player;
  double _horizontalInput = 0;
  bool _jumpQueued = false;
  bool _gameOver = false;

  PlatformerFlameGame({
    required this.entities,
    required this.onWin,
    required this.onLose,
    required this.onCoinCollected,
    required this.onJump,
    required this.onLand,
  }) : super(gravity: Vector2(0, -10));

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // زمین: یک سکوی بزرگ در پایین
    final groundY = -camera.visibleWorldRect.height / 2 + 1;
    add(PlatformBody(
      position: Vector2(0, groundY),
      size: Vector2(40, 2),
    ));
    // سکوها و موجودیت‌ها از روی entities
    for (final e in entities) {
      final pos = Vector2(e.position.dx - 10, e.position.dy - 15); // شیفت به مرکز دوربین
      switch (e.type) {
        case 'platform':
          add(PlatformBody(position: pos, size: Vector2(e.width, e.height)));
          break;
        case 'coin':
          add(CoinBody(position: pos, onCollect: onCoinCollected));
          break;
        case 'enemy':
          add(EnemyBody(
            position: pos,
            patrolRange: 2,
            onStomp: onLose, // یا هر callback مناسب
            onPlayerHit: onLose,
          ));
          break;
        case 'exit':
          add(ExitBody(position: pos, onReach: onWin));
          break;
      }
    }
    // بازیکن
    _player = PlayerBody(
      initialPosition: Vector2(-9, groundY + 1),
      onLand: onLand,
      onJump: onJump,
    );
    add(_player);
    // contact listener برای جمع‌کردن سکه و در خروجی
    addContactCallback(_ContactCallback(
      onCoin: (coin) {
        coin.removeFromParent();
        onCoinCollected();
        AudioManager.instance.coin();
      },
      onExit: (_) {
        if (!_gameOver) {
          _gameOver = true;
          onWin();
          AudioManager.instance.win();
        }
      },
      onEnemy: (_) {
        if (!_gameOver) {
          _gameOver = true;
          onLose();
          AudioManager.instance.hurt();
        }
      },
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_gameOver) return;
    _player.moveHorizontal(_horizontalInput);
    if (_jumpQueued) {
      _player.jump();
      _jumpQueued = false;
    }
    // اگر بازیکن از زمین افتاد
    if (_player.body.position.y < -30) {
      if (!_gameOver) {
        _gameOver = true;
        onLose();
        AudioManager.instance.hurt();
      }
    }
  }

  void setHorizontalInput(double dir) => _horizontalInput = dir;
  void queueJump() {
    if (!_gameOver) {
      _jumpQueued = true;
      AudioManager.instance.jump();
    }
  }

  // PanDetector برای حرکت
  @override
  void onPanUpdate(DragUpdateInfo info) {
    //的运动 کنترل نمی‌شود با pan؛ دکمه‌ها صدا می‌زنند
  }
}

class _ContactCallback extends ContactCallback<BodyComponent, BodyComponent> {
  final void Function(CoinBody) onCoin;
  final void Function(ExitBody) onExit;
  final void Function(EnemyBody) onEnemy;

  _ContactCallback({required this.onCoin, required this.onExit, required this.onEnemy});

  @override
  void begin(Contact contact, BodyComponent a, BodyComponent b) {
    final aData = a.body.userData;
    final bData = b.body.userData;
    final isPlayerA = a is PlayerBody;
    final isPlayerB = b is PlayerBody;
    if (!isPlayerA && !isPlayerB) return;
    final other = isPlayerA ? b : a;
    if (other is CoinBody) {
      onCoin(other);
    } else if (other is ExitBody) {
      onExit(other);
    } else if (other is EnemyBody) {
      onEnemy(other);
    }
  }
}
