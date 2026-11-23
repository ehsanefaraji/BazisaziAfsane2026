/// صفحهٔ خانهٔ نسخهٔ ۶ — با روباه سه‌بعدی چرخان Zflutter
import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme.dart';
import '../painters/dynamic_background.dart';
import '../three_d/fox_3d.dart';
import '../game_store.dart';
import 'genre_picker_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  List<GameProject> _projects = [];
  bool _loading = true;
  late AnimationController _bgLoop;
  late AnimationController _foxLoop;

  @override
  void initState() {
    super.initState();
    _bgLoop = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat();
    _foxLoop = AnimationController(vsync: this, duration: const Duration(seconds: 12))..repeat();
    _load();
  }

  @override
  void dispose() {
    _bgLoop.dispose();
    _foxLoop.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final projects = await GameStore.loadAll();
    if (mounted) {
      setState(() {
        _projects = projects;
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    await GameStore.saveAll(_projects);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('بازی\u200cسازی افسانه ۳بعدی', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0D1457), Colors.transparent],
            ),
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'درباره',
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () => _showAbout(context),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Stack(
              children: [
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _bgLoop,
                    builder: (context, _) => CustomPaint(
                      painter: DynamicBackground(
                        env: Environment.castle,
                        scrollOffset: _bgLoop.value * 60,
                        time: _bgLoop.value * 6.28,
                      ),
                    ),
                  ),
                ),
                SafeArea(child: _buildContent(context)),
              ],
            ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: AppPalette.buttonGradient,
          boxShadow: AppShadows.button,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () async {
              final project = await Navigator.push<GameProject>(
                context,
                MaterialPageRoute(builder: (_) => const GenrePickerScreen()),
              );
              if (project != null) {
                setState(() => _projects.insert(0, project));
                await _save();
              }
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, color: Colors.white, size: 28),
                  SizedBox(width: 10),
                  Text(
                    'بازی جدید',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_projects.isEmpty) {
      return _buildEmptyState(context);
    }
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 100, 16, 120),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.82,
      ),
      itemCount: _projects.length,
      itemBuilder: (context, i) {
        final project = _projects[i];
        return _ProjectCard(
          project: project,
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => PlayScreen(project: project)),
            );
            await _load();
          },
          onDelete: () async {
            setState(() => _projects.removeAt(i));
            await _save();
          },
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // روباه سه‌بعدی چرخان
          SizedBox(
            width: 240,
            height: 240,
            child: AnimatedBuilder(
              animation: _foxLoop,
              builder: (context, _) => Fox3D(
                rotationY: _foxLoop.value * 6.28,
                breath: _foxLoop.value * 6.28,
                waving: true,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFFFFD54F), Color(0xFFFFF59D)],
            ).createShader(bounds),
            child: const Text(
              'سلام قهرمان!',
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'نسخهٔ ۶ با روباه سه‌بعدی واقعی. دکمهٔ «بازی جدید» را بزن تا اولین بازی خودت را بسازی.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.white, height: 1.6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('دربارهٔ بازی\u200cسازی افسانه ۳بعدی'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('نسخهٔ ۶ با رندر سه‌بعدی واقعی Zflutter: روباه ۳بعدی، سکه‌های چرخان، دشمن خاری، و در خروجی با عمق واقعی.'),
              SizedBox(height: 16),
              Text('۵ محیط بصری، ۴ پاورآپ، موسیقی چندصدایی، و دستاوردهای محلی.'),
            ],
          ),
        ),
        actions: [
          FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('باشه')),
        ],
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final GameProject project;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ProjectCard({required this.project, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            project.genre.color.withValues(alpha: 0.95),
            project.genre.color.withValues(alpha: 0.55),
          ],
        ),
        boxShadow: AppShadows.card,
        border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 4,
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              project.genre.color.withValues(alpha: 0.4),
                              project.genre.color.withValues(alpha: 0.1),
                            ],
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Center(
                          child: Text(project.genre.emoji, style: const TextStyle(fontSize: 56)),
                        ),
                      ),
                      if (project.items.any((e) => e.role == ItemRole.exit))
                        Positioned(
                          top: 6,
                          right: 6,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.star, color: Color(0xFFFFD54F), size: 18),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  project.name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    Text(
                      project.genre.label,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: onDelete,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
