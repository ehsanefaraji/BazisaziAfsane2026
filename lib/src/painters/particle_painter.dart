/// سیستم ذرات برای افکت‌های جرقه، گرد و غبار، و درخشش
import 'dart:math';
import 'package:flutter/material.dart';

class Particle {
  final Offset position;
  final Offset velocity;
  final double life;        // 0..1, 0 = تازه، 1 = مرده
  final double maxLife;
  final double size;
  final Color color;

  Particle({
    required this.position,
    required this.velocity,
    required this.life,
    required this.maxLife,
    required this.size,
    required this.color,
  });

  Particle update(double dt) {
    return Particle(
      position: position + velocity * dt,
      velocity: velocity,
      life: life + dt / maxLife,
      maxLife: maxLife,
      size: size,
      color: color,
    );
  }

  bool get dead => life >= 1.0;
}

class ParticleSystem {
  final List<Particle> _particles = [];
  final Random _rng = Random();

  List<Particle> get particles => List.unmodifiable(_particles);

  /// افزودن جرقه‌های درخشش (مثلاً هنگام جمع‌کردن سکه)
  void spawnSparkles(Offset center, {int count = 12, Color color = const Color(0xFFFFD54F)}) {
    for (int i = 0; i < count; i++) {
      final angle = _rng.nextDouble() * 2 * pi;
      final speed = 30 + _rng.nextDouble() * 60;
      _particles.add(Particle(
        position: center,
        velocity: Offset(cos(angle) * speed, sin(angle) * speed),
        life: 0,
        maxLife: 0.5 + _rng.nextDouble() * 0.3,
        size: 2 + _rng.nextDouble() * 3,
        color: color,
      ));
    }
  }

  /// افزودن گرد و غبار هنگام فرود
  void spawnDust(Offset center, {int count = 8}) {
    for (int i = 0; i < count; i++) {
      final angle = pi + (_rng.nextDouble() - 0.5) * pi; // به سمت بالا و کنار
      final speed = 20 + _rng.nextDouble() * 40;
      _particles.add(Particle(
        position: center,
        velocity: Offset(cos(angle) * speed, sin(angle) * speed),
        life: 0,
        maxLife: 0.4 + _rng.nextDouble() * 0.3,
        size: 3 + _rng.nextDouble() * 4,
        color: const Color(0xFFD7CCC8),
      ));
    }
  }

  /// افزودن جرقه‌های متحرک ریز برای حالت نبرد/برد
  void spawnCelebration(Offset center, {int count = 30}) {
    final colors = [
      const Color(0xFFFFD54F),
      const Color(0xFFFFAB91),
      const Color(0xFFB388FF),
      const Color(0xFF81D4FA),
      Colors.white,
    ];
    for (int i = 0; i < count; i++) {
      final angle = _rng.nextDouble() * 2 * pi;
      final speed = 80 + _rng.nextDouble() * 120;
      _particles.add(Particle(
        position: center,
        velocity: Offset(cos(angle) * speed, sin(angle) * speed),
        life: 0,
        maxLife: 0.8 + _rng.nextDouble() * 0.6,
        size: 2 + _rng.nextDouble() * 4,
        color: colors[_rng.nextInt(colors.length)],
      ));
    }
  }

  void update(double dt) {
    for (int i = 0; i < _particles.length; i++) {
      _particles[i] = _particles[i].update(dt);
    }
    _particles.removeWhere((p) => p.dead);
  }

  void clear() => _particles.clear();
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  const ParticlePainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final alpha = (1 - p.life).clamp(0.0, 1.0);
      final color = p.color.withValues(alpha: alpha);
      // هاله
      final haloPaint = Paint()
        ..color = p.color.withValues(alpha: alpha * 0.3);
      canvas.drawCircle(p.position, p.size * 2, haloPaint);
      // خود ذره
      canvas.drawCircle(p.position, p.size, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter old) => true;
}
