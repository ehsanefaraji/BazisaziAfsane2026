/// صفحهٔ دستاوردها — گالری دستاوردهای بازشده و آمار بازی
import 'package:flutter/material.dart';
import '../theme.dart';
import '../game_store.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  Set<String> _unlocked = {};
  int _totalCoins = 0;
  int _enemiesKilled = 0;
  int _levelsCompleted = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final unlocked = await GameStore.unlockedAchievements();
    final coins = await GameStore.totalCoins();
    final enemies = await GameStore.enemiesKilled();
    final levels = await GameStore.levelsCompleted();
    if (mounted) {
      setState(() {
        _unlocked = unlocked;
        _totalCoins = coins;
        _enemiesKilled = enemies;
        _levelsCompleted = levels;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('دستاوردها و آمار', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [AppPalette.primaryDark, Colors.transparent]),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D1457), Color(0xFF311B92), Color(0xFF5E35B1), AppPalette.surface],
          ),
        ),
        child: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildStatsCard(),
                    const SizedBox(height: 16),
                    const Text('دستاوردها', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 12),
                    ...Achievements.all.map((a) => _buildAchievementCard(a)),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          const Text('آمار شما', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _stat('💰', '$_totalCoins', 'سکه'),
              _stat('⚔️', '$_enemiesKilled', 'دشمن'),
              _stat('⭐', '$_levelsCompleted', 'مرحله'),
              _stat('🏆', '${_unlocked.length}', 'دستاورد'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 32)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.7))),
      ],
    );
  }

  Widget _buildAchievementCard(Achievement a) {
    final unlocked = _unlocked.contains(a.id);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: unlocked ? AppPalette.buttonGradient : null,
        color: unlocked ? null : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: unlocked ? Colors.white.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.1),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: unlocked ? Colors.white.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                unlocked ? a.emoji : '🔒',
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(a.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: unlocked ? Colors.white : Colors.white.withValues(alpha: 0.5),
                    )),
                const SizedBox(height: 4),
                Text(a.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: unlocked ? Colors.white.withValues(alpha: 0.9) : Colors.white.withValues(alpha: 0.4),
                    )),
              ],
            ),
          ),
          if (unlocked)
            const Icon(Icons.check_circle, color: Color(0xFF66BB6A), size: 24),
        ],
      ),
    );
  }
}
