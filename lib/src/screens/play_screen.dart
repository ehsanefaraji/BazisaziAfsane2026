/// صفحهٔ بازی نسخهٔ ۷ — اجرای مرحله با روتینگ بر اساس genre + پس‌زمینهٔ محیطی
import 'package:flutter/material.dart';
import '../game_store.dart';
import '../audio/audio_manager.dart';
import '../theme.dart';
import '../painters/dynamic_background.dart';
import '../games/maze_game.dart';
import '../games/catcher_game.dart';
import '../games/driving_game.dart';
import '../games/story_game.dart';

class PlayScreen extends StatefulWidget {
  final GameProject project;
  final GameLevel level;

  const PlayScreen({super.key, required this.project, required this.level});

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> with TickerProviderStateMixin {
  bool _finished = false;
  late AnimationController _bgLoop;

  @override
  void initState() {
    super.initState();
    _bgLoop = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat();
    AudioManager.instance.startMusic();
  }

  @override
  void dispose() {
    _bgLoop.dispose();
    AudioManager.instance.stopMusic();
    super.dispose();
  }

  void _onWin() async {
    if (_finished) return;
    _finished = true;
    widget.level.completed = true;
    widget.level.stars = 3; // در نسخهٔ کامل بر اساس امتیاز و زمان محاسبه می‌شود
    await GameStore.unlock('first_win');
    await GameStore.addLevelCompleted();
    await GameStore.addCoins(20);
    // ذخیرهٔ پروژه
    final all = await GameStore.loadAll();
    final pIdx = all.indexWhere((p) => p.id == widget.project.id);
    if (pIdx >= 0) {
      final project = all[pIdx];
      final lIdx = project.levels.indexWhere((l) => l.id == widget.level.id);
      if (lIdx >= 0) {
        project.levels[lIdx] = widget.level;
      }
      all[pIdx] = project;
      await GameStore.saveAll(all);
    }
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('🎉 آفرین قهرمان!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('مرحله را کامل کردی!'),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) =>
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(i < widget.level.stars ? Icons.star : Icons.star_border,
                        color: const Color(0xFFFFD54F), size: 36),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: const Text('ادامه'),
            ),
          ],
        ),
      );
    });
  }

  void _onLose() {
    if (_finished) return;
    _finished = true;
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('💥 ای وای!'),
          content: const Text('بازی را باختی. دوباره تلاش کن!'),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: const Text('بازگشت'),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('${widget.project.name} · ${widget.level.name}',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [AppPalette.primaryDark, Colors.transparent]),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _bgLoop,
              builder: (context, _) => CustomPaint(
                painter: DynamicBackground(
                  env: widget.project.genre.environment,
                  scrollOffset: _bgLoop.value * 60,
                  time: _bgLoop.value * 6.28,
                ),
              ),
            ),
          ),
          SafeArea(child: _buildGameForGenre()),
        ],
      ),
    );
  }

  Widget _buildGameForGenre() {
    final items = widget.level.items.map((it) => (
      id: it.id,
      row: it.row,
      col: it.col,
      type: _roleToType(it.role),
    )).toList();

    switch (widget.project.genre) {
      case GameGenre.maze:
        return MazeGame(
          rows: widget.level.rows,
          cols: widget.level.cols,
          startRow: widget.level.startRow,
          startCol: widget.level.startCol,
          items: items,
          onWin: _onWin,
          onLose: _onLose,
        );
      case GameGenre.catcher:
        return CatcherGame(onWin: _onWin, onLose: _onLose);
      case GameGenre.driving:
        return DrivingGame(onWin: _onWin, onLose: _onLose);
      case GameGenre.story:
        return StoryGame(onWin: _onWin, onLose: _onLose);
      case GameGenre.platformer:
        // Flame/Forge2D کامل در محیط GitHub کامپایل می‌شود
        // برای sandbox، گریدبیس استفاده می‌کنیم
        return MazeGame(
          rows: widget.level.rows,
          cols: widget.level.cols,
          startRow: widget.level.startRow,
          startCol: widget.level.startCol,
          items: items,
          onWin: _onWin,
          onLose: _onLose,
        );
    }
  }

  String _roleToType(ItemRole role) => switch (role) {
    ItemRole.coin => 'coin',
    ItemRole.enemy => 'enemy',
    ItemRole.exit => 'exit',
    ItemRole.decoration => 'decoration',
    ItemRole.shield => 'shield',
    ItemRole.magnet => 'magnet',
    ItemRole.speedBoost => 'speedBoost',
    ItemRole.extraLife => 'extraLife',
  };
}
