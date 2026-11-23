/// بازی ماشین‌سوار: ماشین بالا/پایین حرکت می‌کند، موانع از راست می‌آیند، سکه‌ها جمع می‌شوند.
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../audio/audio_manager.dart';

class DrivingGame extends StatefulWidget {
  final VoidCallback onWin;
  final VoidCallback onLose;
  final int targetScore;

  const DrivingGame({
    super.key,
    required this.onWin,
    required this.onLose,
    this.targetScore = 150,
  });

  @override
  State<DrivingGame> createState() => _DrivingGameState();
}

class _DrivingGameState extends State<DrivingGame> {
  int _lane = 1; // 0=بالا، 1=وسط، 2=پایین
  int _score = 0;
  int _lives = 3;
  bool _finished = false;
  final List<_Obstacle> _obstacles = [];
  Timer? _spawnTimer;
  Timer? _gameTimer;
  final Random _rng = Random();
  DateTime _lastTick = DateTime.now();
  double _roadOffset = 0;

  @override
  void initState() {
    super.initState();
    _spawnTimer = Timer.periodic(const Duration(milliseconds: 900), (_) => _spawn());
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
    final r = _rng.nextDouble();
    String type;
    if (r < 0.5) type = 'coin';
    else if (r < 0.85) type = 'obstacle';
    else type = 'reward';
    setState(() {
      _obstacles.add(_Obstacle(
        x: 1.0,
        lane: _rng.nextInt(3),
        speed: 0.35 + _rng.nextDouble() * 0.2,
        type: type,
      ));
    });
  }

  void _tick() {
    final now = DateTime.now();
    final dt = (now.microsecondsSinceEpoch - _lastTick.microsecondsSinceEpoch) / 1000000.0;
    _lastTick = now;
    if (_finished) return;

    setState(() {
      _roadOffset = (_roadOffset + dt * 0.5) % 1.0;
      for (final o in _obstacles) {
        o.x -= o.speed * dt;
        // برخورد با ماشین بازیکن
        if (!o.collected && o.x < 0.15 && o.x > 0.05 && o.lane == _lane) {
          o.collected = true;
          switch (o.type) {
            case 'coin':
              _score += 10;
              AudioManager.instance.coin();
              if (_score >= widget.targetScore) {
                _finished = true;
                AudioManager.instance.win();
                widget.onWin();
              }
              break;
            case 'reward':
              _score += 30;
              AudioManager.instance.coin();
              if (_score >= widget.targetScore) {
                _finished = true;
                AudioManager.instance.win();
                widget.onWin();
              }
              break;
            case 'obstacle':
              _lives--;
              AudioManager.instance.hurt();
              if (_lives <= 0) {
                _finished = true;
                widget.onLose();
              }
              break;
          }
        }
      }
      _obstacles.removeWhere((o) => o.collected || o.x < -0.2);
    });
  }

  void _changeLane(int newLane) {
    if (_finished) return;
    setState(() => _lane = newLane);
    AudioManager.instance.click();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // پس‌زمینهٔ جاده
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1B5E20), Color(0xFF558B2F)],
                ),
              ),
            ),
            // جاده (با حرکت)
            Positioned.fill(
              child: CustomPaint(
                painter: _RoadPainter(offset: _roadOffset),
              ),
            ),
            // موانع
            ..._obstacles.map((o) {
              final laneY = (o.lane + 0.5) / 3.0;
              return Positioned(
                left: o.x * constraints.maxWidth - 20,
                top: laneY * constraints.maxHeight - 20,
                child: Text(
                  o.type == 'coin' ? '🪙' : (o.type == 'reward' ? '🎁' : '🚧'),
                  style: const TextStyle(fontSize: 36),
                ),
              );
            }).toList(),
            // ماشین بازیکن
            Positioned(
              left: 0.05 * constraints.maxWidth,
              top: (_lane + 0.5) / 3.0 * constraints.maxHeight - 24,
              child: const Text('🏎️', style: TextStyle(fontSize: 48)),
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
                  _pill('هدف: ${widget.targetScore}', Colors.green.shade300),
                ],
              ),
            ),
            // کنترل: ۳ دکمه برای ۳ لاین
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _laneBtn(Icons.arrow_upward, _lane == 0, () => _changeLane(0)),
                  _laneBtn(Icons.adjust, _lane == 1, () => _changeLane(1)),
                  _laneBtn(Icons.arrow_downward, _lane == 2, () => _changeLane(2)),
                ],
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

  Widget _laneBtn(IconData icon, bool active, VoidCallback onPressed) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: active
            ? [const Color(0xFFFFD54F), const Color(0xFFFF8F00)]
            : [const Color(0xFFB388FF), const Color(0xFF5E35B1)]),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(onTap: onPressed, customBorder: const CircleBorder(), child: Icon(icon, color: Colors.white, size: 32)),
      ),
    );
  }
}

class _Obstacle {
  double x;
  int lane;
  double speed;
  String type;
  bool collected = false;

  _Obstacle({required this.x, required this.lane, required this.speed, required this.type});
}

class _RoadPainter extends CustomPainter {
  final double offset;
  _RoadPainter({required this.offset});

  @override
  void paint(Canvas canvas, Size size) {
    // خطوط لاین‌ها
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..strokeWidth = 3;
    final laneH = size.height / 3;
    for (int i = 1; i < 3; i++) {
      final y = i * laneH;
      // خط چین
      for (double x = -50 + offset * 80; x < size.width + 50; x += 60) {
        canvas.drawLine(Offset(x, y), Offset(x + 30, y), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RoadPainter old) => old.offset != offset;
}
