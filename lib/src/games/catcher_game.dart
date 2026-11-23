/// بازی شکارچی ستاره: سبد پایین حرکت می‌کند، ستاره و بمب از بالا می‌افتند.
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../audio/audio_manager.dart';

class CatcherGame extends StatefulWidget {
  final VoidCallback onWin;
  final VoidCallback onLose;
  final int targetScore;

  const CatcherGame({
    super.key,
    required this.onWin,
    required this.onLose,
    this.targetScore = 100,
  });

  @override
  State<CatcherGame> createState() => _CatcherGameState();
}

class _CatcherGameState extends State<CatcherGame> {
  double _basketX = 0.5; // 0 تا 1
  int _score = 0;
  int _lives = 3;
  bool _finished = false;
  final List<_FallingObject> _objects = [];
  Timer? _spawnTimer;
  Timer? _gameTimer;
  final Random _rng = Random();
  DateTime _lastTick = DateTime.now();

  @override
  void initState() {
    super.initState();
    _spawnTimer = Timer.periodic(const Duration(milliseconds: 700), (_) => _spawn());
    _gameTimer = Timer.periodic(const Duration(milliseconds: 16), (_) => _tick());
  }

  @override
  void dispose() {
    _spawnTimer?.cancel();
    _gameTimer?.cancel();
    super.dispose();
  }

  void _spawn() {
    if (_finished) return;
    final isBomb = _rng.nextDouble() < 0.25;
    setState(() {
      _objects.add(_FallingObject(
        x: _rng.nextDouble(),
        y: 0.0,
        speed: 0.4 + _rng.nextDouble() * 0.3,
        type: isBomb ? 'bomb' : 'star',
      ));
    });
  }

  void _tick() {
    final now = DateTime.now();
    final dt = (now.microsecondsSinceEpoch - _lastTick.microsecondsSinceEpoch) / 1000000.0;
    _lastTick = now;
    if (_finished) return;

    setState(() {
      for (final o in _objects) {
        o.y += o.speed * dt;
      }
      // تشخیص برخورد با سبد
      final basketY = 0.92;
      for (final o in _objects) {
        if (!o.collected && o.y >= basketY - 0.04 && o.y <= basketY + 0.04) {
          if ((o.x - _basketX).abs() < 0.08) {
            o.collected = true;
            if (o.type == 'star') {
              _score += 10;
              AudioManager.instance.coin();
              if (_score >= widget.targetScore) {
                _finished = true;
                AudioManager.instance.win();
                widget.onWin();
              }
            } else {
              // بمب
              _lives--;
              AudioManager.instance.hurt();
              if (_lives <= 0) {
                _finished = true;
                widget.onLose();
              }
            }
          } else if (o.y > 1.0) {
            o.collected = true; // از صفحه خارج شد
          }
        }
      }
      _objects.removeWhere((o) => o.collected || o.y > 1.1);
    });
  }

  void _moveBasket(double dx) {
    setState(() {
      _basketX = (_basketX + dx).clamp(0.0, 1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // پس‌زمینه
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1A237E), Color(0xFF7E57C2), Color(0xFFFF8A65)],
                ),
              ),
            ),
            // ستاره‌ها و بمب‌ها
            ..._objects.map((o) {
              return Positioned(
                left: o.x * constraints.maxWidth - 16,
                top: o.y * constraints.maxHeight - 16,
                child: Text(
                  o.type == 'star' ? '⭐' : '💣',
                  style: const TextStyle(fontSize: 32),
                ),
              );
            }).toList(),
            // سبد پایین
            Positioned(
              left: _basketX * constraints.maxWidth - 40,
              bottom: 8,
              child: const Text('🧺', style: TextStyle(fontSize: 64)),
            ),
            // HUD
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  _pill('★ $_score', Colors.amber),
                  const SizedBox(width: 8),
                  _pill('❤ × $_lives', Colors.red),
                  const Spacer(),
                  _pill('هدف: ${widget.targetScore}', Colors.purple.shade300),
                ],
              ),
            ),
            // کنترل لمسی
            Positioned.fill(
              child: GestureDetector(
                onPanUpdate: (details) {
                  _moveBasket(details.delta.dx / constraints.maxWidth);
                },
                onTapDown: (details) {
                  // روی ضربه، سبد به آن نقطه برود
                  setState(() {
                    _basketX = (details.localPosition.dx / constraints.maxWidth).clamp(0.0, 1.0);
                  });
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _pill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }
}

class _FallingObject {
  double x;
  double y;
  double speed;
  String type;
  bool collected = false;

  _FallingObject({required this.x, required this.y, required this.speed, required this.type});
}
