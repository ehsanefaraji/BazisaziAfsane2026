/// صفحهٔ بازی نسخهٔ ۵ — روتینگ به موتور مناسب بر اساس genre + پس‌زمینهٔ محیطی
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
  const PlayScreen({super.key, required this.project});

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
    await GameStore.unlock('first_win');
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('🎉 آفرین قهرمان!'),
          content: const Text('مرحله را کامل کردی!'),
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
        title: Text(widget.project.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppPalette.primaryDark, Colors.transparent],
            ),
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
    final items = widget.project.items.map((it) => (
      id: it.id,
      row: it.row,
      col: it.col,
      type: _roleToType(it.role),
    )).toList();

    switch (widget.project.genre) {
      case GameGenre.maze:
        return MazeGame(
          rows: widget.project.rows,
          cols: widget.project.cols,
          startRow: widget.project.startRow,
          startCol: widget.project.startCol,
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
        // نسخهٔ Flame در github کامپایل می‌شود؛ اینجا گریدبیس استفاده می‌کنیم
        return MazeGame(
          rows: widget.project.rows,
          cols: widget.project.cols,
          startRow: widget.project.startRow,
          startCol: widget.project.startCol,
          items: items,
          onWin: _onWin,
          onLose: _onLose,
        );
    }
  }

  String _roleToType(ItemRole role) {
    switch (role) {
      case ItemRole.coin:        return 'coin';
      case ItemRole.enemy:       return 'enemy';
      case ItemRole.exit:        return 'exit';
      case ItemRole.decoration:  return 'decoration';
      case ItemRole.shield:      return 'shield';
      case ItemRole.magnet:      return 'magnet';
      case ItemRole.speedBoost:  return 'speedBoost';
      case ItemRole.extraLife:   return 'extraLife';
    }
  }
}
