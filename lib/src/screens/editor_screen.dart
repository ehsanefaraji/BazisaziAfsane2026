/// ویرایشگر مرحله — نسخهٔ ۳ با آیتم‌های نقاشی‌شدهٔ متحرک
import 'package:flutter/material.dart';
import '../theme.dart';
import '../painters/item_painters.dart';
import '../game_store.dart';
import 'play_screen.dart';

class EditorScreen extends StatefulWidget {
  final GameProject project;

  const EditorScreen({super.key, required this.project});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> with TickerProviderStateMixin {
  late GameProject _project;
  ItemRole? _activeRole;
  int _nextId = 1;
  late AnimationController _animLoop;

  @override
  void initState() {
    super.initState();
    _project = widget.project;
    if (_project.items.isNotEmpty) {
      _nextId = _project.items.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1;
    }
    _animLoop = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  }

  @override
  void dispose() {
    _animLoop.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final all = await GameStore.loadAll();
    final idx = all.indexWhere((p) => p.id == _project.id);
    if (idx >= 0) {
      all[idx] = _project;
    } else {
      all.insert(0, _project);
    }
    await GameStore.saveAll(all);
  }

  PlacedItem? _itemAt(int row, int col) {
    for (final it in _project.items) {
      if (it.row == row && it.col == col) return it;
    }
    return null;
  }

  void _onCellTap(int row, int col) {
    final existing = _itemAt(row, col);
    if (existing != null) {
      _showRolePopup(existing);
      return;
    }
    if (_activeRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اول از پایین یک نقش انتخاب کن'), duration: Duration(seconds: 2)),
      );
      return;
    }
    setState(() {
      _project.items.add(PlacedItem(id: _nextId++, row: row, col: col, role: _activeRole!));
    });
  }

  void _showRolePopup(PlacedItem item) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, AppPalette.surface],
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'این آیتم چیست؟',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppPalette.textPrimary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: ItemRole.values.map((role) {
                    return _RoleChoice(
                      role: role,
                      active: item.role == role,
                      animValue: _animLoop.value,
                      onTap: () {
                        setState(() => item.role = role);
                        Navigator.pop(ctx);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() => _project.items.removeWhere((e) => e.id == item.id));
                    Navigator.pop(ctx);
                  },
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: const Text('حذف این آیتم', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(_project.name, style: const TextStyle(fontWeight: FontWeight.bold)),
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
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF66BB6A), Color(0xFF2E7D32)]),
              borderRadius: BorderRadius.circular(12),
              boxShadow: AppShadows.button,
            ),
            child: IconButton(
              tooltip: 'بازی کن',
              icon: const Icon(Icons.play_arrow, color: Colors.white),
              onPressed: () async {
                await _save();
                if (!mounted) return;
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PlayScreen(project: _project)),
                );
              },
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D1457), Color(0xFF311B92), Color(0xFF5E35B1), AppPalette.surface],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.tips_and_updates, color: Color(0xFFFFD54F)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'یک نقش از پایین انتخاب کن، بعد خانه\u200cای را که می\u200cخواهی بزن. برای تغییر، روی آیتم دوباره بزن.',
                          style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.9), height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(child: _buildGrid()),
              _buildRolePicker(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppShadows.card,
        ),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _project.cols,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: _project.rows * _project.cols,
            itemBuilder: (context, i) {
              final row = i ~/ _project.cols;
              final col = i % _project.cols;
              final item = _itemAt(row, col);
              final isStart = row == _project.startRow && col == _project.startCol;
              return InkWell(
                onTap: () => _onCellTap(row, col),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: item != null
                          ? [item.role.color.withValues(alpha: 0.4), item.role.color.withValues(alpha: 0.15)]
                          : isStart
                              ? [const Color(0xFF66BB6A), const Color(0xFFA5D6A7)]
                              : [const Color(0xFFFFF8E7), const Color(0xFFFFF3E0)],
                    ),
                    border: Border.all(color: Colors.white, width: 1.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: item == null
                      ? Center(child: Text(isStart ? '🏁' : '', style: const TextStyle(fontSize: 22)))
                      : AnimatedBuilder(
                          animation: _animLoop,
                          builder: (context, _) => CustomPaint(
                            painter: _itemPainterForRole(item.role, _animLoop.value),
                          ),
                        ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRolePicker() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadows.card,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ItemRole.values.map((role) {
            final active = _activeRole == role;
            return GestureDetector(
              onTap: () => setState(() => _activeRole = active ? null : role),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          role.color.withValues(alpha: active ? 0.7 : 0.3),
                          role.color.withValues(alpha: active ? 0.4 : 0.1),
                        ],
                      ),
                      border: Border.all(color: active ? role.color : Colors.transparent, width: 3),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: active
                          ? [BoxShadow(color: role.color.withValues(alpha: 0.5), offset: const Offset(0, 4), blurRadius: 8)]
                          : null,
                    ),
                    child: AnimatedBuilder(
                      animation: _animLoop,
                      builder: (context, _) => CustomPaint(
                        painter: _itemPainterForRole(role, _animLoop.value),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    role.label,
                    style: TextStyle(
                      fontSize: 11,
                      color: active ? role.color : AppPalette.textSecondary,
                      fontWeight: active ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

CustomPainter _itemPainterForRole(ItemRole role, double t) {
  final phase = t * 6.28;
  switch (role) {
    case ItemRole.coin:
      return CoinPainter(spinPhase: phase);
    case ItemRole.enemy:
      return EnemyPainter(walkPhase: phase);
    case ItemRole.exit:
      return ExitDoorPainter(pulse: (sin(phase) + 1) / 2);
    case ItemRole.decoration:
      return FlowerPainter(swayPhase: phase);
    case ItemRole.shield:
      return ShieldPainter(pulse: (sin(phase) + 1) / 2);
    case ItemRole.magnet:
      return MagnetPainter(pulse: (sin(phase) + 1) / 2);
    case ItemRole.speedBoost:
      return SpeedBoostPainter(pulse: (sin(phase) + 1) / 2);
    case ItemRole.extraLife:
      return ExtraLifePainter(pulse: (sin(phase) + 1) / 2);
  }
}

class _RoleChoice extends StatelessWidget {
  final ItemRole role;
  final bool active;
  final double animValue;
  final VoidCallback onTap;

  const _RoleChoice({required this.role, required this.active, required this.animValue, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  role.color.withValues(alpha: active ? 0.7 : 0.3),
                  role.color.withValues(alpha: active ? 0.4 : 0.1),
                ],
              ),
              border: Border.all(color: active ? role.color : Colors.transparent, width: 3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: AnimatedBuilder(
              animation: Listenable.merge([]),
              builder: (context, _) => CustomPaint(painter: _itemPainterForRole(role, animValue)),
            ),
          ),
          const SizedBox(height: 6),
          Text(role.label, style: TextStyle(fontSize: 12, color: role.color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
