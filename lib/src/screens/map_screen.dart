/// صفحهٔ نقشهٔ مسیر — مثل Angry Birds، مراحل به‌صورت مسیر پیچ‌دار
import 'package:flutter/material.dart';
import '../theme.dart';
import '../game_store.dart';
import '../audio/audio_manager.dart';
import 'editor_screen.dart';
import 'play_screen.dart';

class MapScreen extends StatefulWidget {
  final GameProject project;
  const MapScreen({super.key, required this.project});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  late AnimationController _bgLoop;

  @override
  void initState() {
    super.initState();
    _bgLoop = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat();
  }

  @override
  void dispose() {
    _bgLoop.dispose();
    super.dispose();
  }

  Future<void> _refreshProject() async {
    final all = await GameStore.loadAll();
    if (mounted) {
      final idx = all.indexWhere((p) => p.id == widget.project.id);
      if (idx >= 0) {
        setState(() {});
      }
    }
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
        actions: [
          IconButton(
            tooltip: 'افزودن مرحله',
            icon: const Icon(Icons.add_road, color: Colors.white),
            onPressed: () {
              if (widget.project.levels.length >= 20) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('حداکثر ۲۰ مرحله می‌توانی بسازی')),
                );
                return;
              }
              setState(() {
                widget.project.levels.add(GameLevel.create(
                  name: 'مرحلهٔ ${widget.project.levels.length + 1}',
                  levelNumber: widget.project.levels.length + 1,
                ));
              });
              _saveProject();
            },
          ),
          IconButton(
            tooltip: 'Export JSON',
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () => _exportProject(),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _bgLoop,
              builder: (context, _) => CustomPaint(
                painter: _MapBackgroundPainter(
                  env: widget.project.genre.environment,
                  scrollOffset: _bgLoop.value * 60,
                  time: _bgLoop.value * 6.28,
                ),
              ),
            ),
          ),
          SafeArea(
            child: widget.project.levels.isEmpty
                ? _buildEmpty()
                : CustomPaint(
                    painter: _PathPainter(
                      levelCount: widget.project.levels.length,
                      color: widget.project.genre.color,
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Stack(
                          children: List.generate(widget.project.levels.length, (i) {
                            final level = widget.project.levels[i];
                            final canOpen = widget.project.canOpenLevel(i);
                            final pos = _levelPosition(i, widget.project.levels.length, constraints.biggest);
                            return Positioned(
                              left: pos.dx - 35,
                              top: pos.dy - 35,
                              child: _LevelNode(
                                level: level,
                                index: i,
                                canOpen: canOpen,
                                genreColor: widget.project.genre.color,
                                onTap: () async {
                                  if (!canOpen) {
                                    AudioManager.instance.click();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('اول مرحلهٔ قبلی را کامل کن')),
                                    );
                                    return;
                                  }
                                  AudioManager.instance.click();
                                  final updated = await Navigator.push<GameLevel>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EditorScreen(project: widget.project, level: level),
                                    ),
                                  );
                                  if (updated != null) {
                                    await _refreshProject();
                                  }
                                },
                                onPlay: () async {
                                  if (!canOpen) return;
                                  AudioManager.instance.click();
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PlayScreen(project: widget.project, level: level),
                                    ),
                                  );
                                  await _refreshProject();
                                },
                              ),
                            );
                          }),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.map, size: 80, color: Colors.white70),
          const SizedBox(height: 16),
          const Text('هنوز مرحله‌ای نیست. دکمهٔ + را بزن تا اولین مرحله را بسازی.',
              style: TextStyle(color: Colors.white), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Offset _levelPosition(int i, int total, Size size) {
    // مسیر زیگزاگ از پایین به بالا
    final padding = 80.0;
    final usableH = size.height - 2 * padding;
    final usableW = size.width - 2 * padding;
    final rowH = usableH / (total + 1);
    final y = size.height - padding - i * rowH;
    // زیگزاگ: هر زوج به چپ، هر فرد به راست
    final isEven = i % 2 == 0;
    final x = padding + (isEven ? usableW * 0.3 : usableW * 0.7);
    return Offset(x, y);
  }

  Future<void> _saveProject() async {
    final all = await GameStore.loadAll();
    final idx = all.indexWhere((p) => p.id == widget.project.id);
    if (idx >= 0) {
      all[idx] = widget.project;
    } else {
      all.insert(0, widget.project);
    }
    await GameStore.saveAll(all);
  }

  Future<void> _exportProject() async {
    final json = widget.project.exportToJson();
    await _showExportDialog(json);
  }

  Future<void> _showExportDialog(String json) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('اشتراک‌گذاری پروژه'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('این JSON را کپی کن و برای دوستت بفرست:'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  json,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('بستن'),
          ),
          FilledButton(
            onPressed: () {
              // در نسخهٔ کامل با Clipboard.setData کار می‌کند
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('JSON آمادهٔ کپی است')),
              );
            },
            child: const Text('کپی شد'),
          ),
        ],
      ),
    );
  }
}

class _LevelNode extends StatelessWidget {
  final GameLevel level;
  final int index;
  final bool canOpen;
  final Color genreColor;
  final VoidCallback onTap;
  final VoidCallback onPlay;

  const _LevelNode({
    required this.level,
    required this.index,
    required this.canOpen,
    required this.genreColor,
    required this.onTap,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70,
      height: 70,
      child: Stack(
        alignment: Alignment.center,
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                gradient: canOpen
                    ? LinearGradient(colors: [genreColor, genreColor.withValues(alpha: 0.7)])
                    : null,
                color: canOpen ? null : Colors.grey.shade800,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: canOpen
                    ? [BoxShadow(color: genreColor.withValues(alpha: 0.5), offset: const Offset(0, 4), blurRadius: 10)]
                    : null,
              ),
              child: Center(
                child: canOpen
                    ? Text(
                        '${index + 1}',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                      )
                    : const Icon(Icons.lock, color: Colors.white54, size: 28),
              ),
            ),
          ),
          // ستاره‌های کامل‌شدن
          if (level.completed && level.stars > 0)
            Positioned(
              top: -8,
              child: Row(
                children: List.generate(
                  3,
                  (i) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: Icon(
                      i < level.stars ? Icons.star : Icons.star_border,
                      color: const Color(0xFFFFD54F),
                      size: 14,
                    ),
                  ),
                ),
              ),
            ),
          // دکمهٔ Play روی مرحلهٔ قابل‌بازشدن
          if (canOpen)
            Positioned(
              bottom: -4,
              right: -4,
              child: GestureDetector(
                onTap: onPlay,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: Color(0xFF66BB6A),
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 4)],
                  ),
                  child: const Icon(Icons.play_arrow, color: Colors.white, size: 18),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PathPainter extends CustomPainter {
  final int levelCount;
  final Color color;

  _PathPainter({required this.levelCount, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (levelCount < 2) return;
    final paint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final padding = 80.0;
    final usableH = size.height - 2 * padding;
    final usableW = size.width - 2 * padding;
    final rowH = usableH / (levelCount + 1);
    for (int i = 0; i < levelCount - 1; i++) {
      final y1 = size.height - padding - i * rowH;
      final y2 = size.height - padding - (i + 1) * rowH;
      final x1 = padding + (i % 2 == 0 ? usableW * 0.3 : usableW * 0.7);
      final x2 = padding + ((i + 1) % 2 == 0 ? usableW * 0.3 : usableW * 0.7);
      // منحنی Bezier
      final path = Path()
        ..moveTo(x1, y1)
        ..quadraticBezierTo((x1 + x2) / 2, (y1 + y2) / 2, x2, y2);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _PathPainter old) => old.levelCount != levelCount || old.color != color;
}

class _MapBackgroundPainter extends CustomPainter {
  final Environment env;
  final double scrollOffset;
  final double time;

  _MapBackgroundPainter({required this.env, this.scrollOffset = 0, this.time = 0});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final basePaint = Paint()..shader = env.gradient.createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), basePaint);
    // جرقه‌های معلق برای جلوه
    final rng = DateTime.now().millisecond;
    for (int i = 0; i < 30; i++) {
      final x = ((i * 53 + scrollOffset) % w);
      final y = (i * 37 % h);
      final alpha = 0.3 + 0.3 * ((i * 7 + time * 10) % 1.0);
      canvas.drawCircle(Offset(x, y), 1.5, Paint()..color = const Color(0xFFFFF59D).withValues(alpha: alpha));
    }
  }

  @override
  bool shouldRepaint(covariant _MapBackgroundPainter old) => true;
}
