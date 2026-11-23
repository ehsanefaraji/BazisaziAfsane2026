/// صفحهٔ خانهٔ نسخهٔ ۷ — با روباه انیمه و گالری پروژه‌ها
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';
import '../painters/dynamic_background.dart';
import '../painters/fox_character_painter.dart';
import '../game_store.dart';
import 'genre_picker_screen.dart';
import 'map_screen.dart';
import 'achievements_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  List<GameProject> _projects = [];
  bool _loading = true;
  late AnimationController _bgLoop;
  late AnimationController _breathLoop;

  @override
  void initState() {
    super.initState();
    _bgLoop = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat();
    _breathLoop = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    _load();
  }

  @override
  void dispose() {
    _bgLoop.dispose();
    _breathLoop.dispose();
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

  Future<void> _save() async => GameStore.saveAll(_projects);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('بازی\u200cسازی افسانه', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF0D1457), Colors.transparent]),
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'دستاوردها',
            icon: const Icon(Icons.emoji_events, color: Colors.white),
            onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => const AchievementsScreen()));
              await _load();
            },
          ),
          IconButton(
            tooltip: 'Import JSON',
            icon: const Icon(Icons.file_download, color: Colors.white),
            onPressed: _importProject,
          ),
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
                await GameStore.unlock('first_project');
              }
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, color: Colors.white, size: 28),
                  SizedBox(width: 10),
                  Text('بازی جدید', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_projects.isEmpty) return _buildEmptyState(context);
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 100, 16, 120),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.78,
      ),
      itemCount: _projects.length,
      itemBuilder: (context, i) {
        final project = _projects[i];
        return _ProjectCard(
          project: project,
          onTap: () async {
            await Navigator.push(context, MaterialPageRoute(builder: (_) => MapScreen(project: project)));
            await _load();
          },
          onExport: () => _exportProject(project),
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
          AnimatedBuilder(
            animation: _breathLoop,
            builder: (context, _) => SizedBox(
              width: 220,
              height: 220,
              child: CustomPaint(
                painter: FoxCharacterPainter(
                  pose: FoxPose.idle,
                  breathPhase: _breathLoop.value * 6.28,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(colors: [Color(0xFFFFD54F), Color(0xFFFFF59D)]).createShader(bounds),
            child: const Text('سلام قهرمان!', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white)),
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
                  'دکمهٔ «بازی جدید» را بزن تا اولین بازی خودت را با چندین مرحله و نقشهٔ مسیر بسازی.',
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

  Future<void> _exportProject(GameProject project) async {
    final json = project.exportToJson();
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Export پروژه'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('JSON را کپی کن و برای دوستت بفرست:'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
                child: SelectableText(json, style: const TextStyle(fontFamily: 'monospace', fontSize: 11)),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('بستن')),
          FilledButton(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: json));
              if (!mounted) return;
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('در کلیپ‌بورد کپی شد')));
            },
            child: const Text('کپی'),
          ),
        ],
      ),
    );
  }

  Future<void> _importProject() async {
    final controller = TextEditingController();
    final imported = await showDialog<GameProject>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Import پروژه'),
        content: TextField(
          controller: controller,
          maxLines: 8,
          decoration: const InputDecoration(
            hintText: 'JSON پروژه را اینجا پیست کن',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('بستن')),
          FilledButton(
            onPressed: () {
              final project = GameProject.importFromJson(controller.text.trim());
              Navigator.pop(ctx, project);
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
    if (imported != null) {
      setState(() => _projects.insert(0, imported));
      await _save();
      await GameStore.unlock('import_project');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('«${imported.name}» import شد')));
    }
  }

  void _showAbout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('دربارهٔ بازی\u200cسازی افسانه ۷'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('نسخهٔ ۷ با Flame/Forge2D کامل، چندمرحله‌ای، Sprite Sheet، و Export/Import JSON.'),
              SizedBox(height: 16),
              Text('۵ سبک بازی، ۵ محیط بصری، ۴ پاورآپ، ۸ دستاورد، و نقشهٔ مسیر مثل Angry Birds.'),
            ],
          ),
        ),
        actions: [FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('باشه'))],
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final GameProject project;
  final VoidCallback onTap;
  final VoidCallback onExport;
  final VoidCallback onDelete;

  const _ProjectCard({required this.project, required this.onTap, required this.onExport, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final completedCount = project.levels.where((l) => l.completed).length;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [project.genre.color.withValues(alpha: 0.95), project.genre.color.withValues(alpha: 0.55)],
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
                            colors: [project.genre.color.withValues(alpha: 0.4), project.genre.color.withValues(alpha: 0.1)],
                          ),
                        ),
                      ),
                      Positioned.fill(child: Center(child: Text(project.genre.emoji, style: const TextStyle(fontSize: 56)))),
                      // تعداد مراحل
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${project.levels.length} مرحله',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(project.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                // نوار پیشرفت
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: project.levels.isEmpty ? 0 : completedCount / project.levels.length,
                    backgroundColor: Colors.black.withValues(alpha: 0.3),
                    color: Colors.white,
                    minHeight: 4,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('$completedCount/${project.levels.length}',
                        style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.9), fontWeight: FontWeight.bold)),
                    const Spacer(),
                    GestureDetector(
                      onTap: onExport,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.3), shape: BoxShape.circle),
                        child: const Icon(Icons.share, color: Colors.white, size: 14),
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: onDelete,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.3), shape: BoxShape.circle),
                        child: const Icon(Icons.close, color: Colors.white, size: 14),
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
