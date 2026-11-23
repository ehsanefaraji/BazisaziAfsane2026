/// مدل‌های نسخهٔ ۷: چندمرحله‌ای، نقشهٔ مسیر، Export/Import JSON
import 'dart:convert';
import "package:flutter/material.dart";
import 'package:shared_preferences/shared_preferences.dart';
import 'theme.dart';

enum GameGenre { maze, driving, catcher, story, platformer }

extension GameGenreX on GameGenre {
  String get label => switch (this) {
    GameGenre.maze => 'هزارتو',
    GameGenre.driving => 'ماشین\u200cسوار',
    GameGenre.catcher => 'شکارچی ستاره',
    GameGenre.story => 'داستان تعاملی',
    GameGenre.platformer => 'پلتفرمر',
  };
  String get emoji => switch (this) {
    GameGenre.maze => '🌀',
    GameGenre.driving => '🏎️',
    GameGenre.catcher => '⭐',
    GameGenre.story => '📖',
    GameGenre.platformer => '🦊',
  };
  String get description => switch (this) {
    GameGenre.maze => 'مسیری بساز و گنج را پیدا کن',
    GameGenre.driving => 'با ماشین از موانع عبور کن',
    GameGenre.catcher => 'ستاره\u200cها را بگیر، بمب را نه',
    GameGenre.story => 'صحنه بساز و روایت کن',
    GameGenre.platformer => 'بپر، بدود، به در خروجی برس',
  };
  Color get color => switch (this) {
    GameGenre.maze => const Color(0xFF4CAF50),
    GameGenre.driving => const Color(0xFFFF7043),
    GameGenre.catcher => const Color(0xFFFFB300),
    GameGenre.story => const Color(0xFF7E57C2),
    GameGenre.platformer => const Color(0xFF29B6F6),
  };
  Environment get environment => switch (this) {
    GameGenre.maze => Environment.forest,
    GameGenre.platformer => Environment.sky,
    GameGenre.catcher => Environment.underwater,
    GameGenre.driving => Environment.cave,
    GameGenre.story => Environment.castle,
  };
}

enum ItemRole {
  coin, enemy, exit, decoration,
  shield, magnet, speedBoost, extraLife,
}

extension ItemRoleX on ItemRole {
  String get label => switch (this) {
    ItemRole.coin => 'سکه',
    ItemRole.enemy => 'دشمن',
    ItemRole.exit => 'در خروجی',
    ItemRole.decoration => 'تزئین',
    ItemRole.shield => 'سپر',
    ItemRole.magnet => 'آهنربا',
    ItemRole.speedBoost => 'سرعت',
    ItemRole.extraLife => 'جان اضافه',
  };
  String get emoji => switch (this) {
    ItemRole.coin => '💎',
    ItemRole.enemy => '👾',
    ItemRole.exit => '🚪',
    ItemRole.decoration => '🌸',
    ItemRole.shield => '🛡️',
    ItemRole.magnet => '🧲',
    ItemRole.speedBoost => '⚡',
    ItemRole.extraLife => '❤️',
  };
  Color get color => switch (this) {
    ItemRole.coin => const Color(0xFFFFD54F),
    ItemRole.enemy => const Color(0xFFEF5350),
    ItemRole.exit => const Color(0xFF66BB6A),
    ItemRole.decoration => const Color(0xFFCE93D8),
    ItemRole.shield => const Color(0xFF42A5F5),
    ItemRole.magnet => const Color(0xFFFF7043),
    ItemRole.speedBoost => const Color(0xFFAB47BC),
    ItemRole.extraLife => const Color(0xFFEC407A),
  };
  bool get isPowerUp => switch (this) {
    ItemRole.shield || ItemRole.magnet || ItemRole.speedBoost || ItemRole.extraLife => true,
    _ => false,
  };
}

class PlacedItem {
  final int id;
  final int row, col;
  ItemRole role;
  PlacedItem({required this.id, required this.row, required this.col, required this.role});
  Map<String, dynamic> toJson() => {'id': id, 'row': row, 'col': col, 'role': role.name};
  factory PlacedItem.fromJson(Map<String, dynamic> j) => PlacedItem(
    id: j['id'] as int,
    row: j['row'] as int,
    col: j['col'] as int,
    role: ItemRole.values.byName(j['role'] as String),
  );
}

/// یک مرحله در پروژه
class GameLevel {
  final String id;
  String name;
  int rows, cols, startRow, startCol;
  List<PlacedItem> items;
  bool completed;
  int stars; // 0..3

  GameLevel({
    required this.id,
    required this.name,
    this.rows = 6,
    this.cols = 4,
    this.startRow = 5,
    this.startCol = 0,
    List<PlacedItem>? items,
    this.completed = false,
    this.stars = 0,
  }) : items = items ?? [];

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'rows': rows, 'cols': cols,
    'startRow': startRow, 'startCol': startCol,
    'items': items.map((e) => e.toJson()).toList(),
    'completed': completed, 'stars': stars,
  };

  factory GameLevel.fromJson(Map<String, dynamic> j) => GameLevel(
    id: j['id'] as String,
    name: j['name'] as String,
    rows: j['rows'] as int? ?? 6,
    cols: j['cols'] as int? ?? 4,
    startRow: j['startRow'] as int? ?? 5,
    startCol: j['startCol'] as int? ?? 0,
    items: (j['items'] as List? ?? []).map((e) => PlacedItem.fromJson(e as Map<String, dynamic>)).toList(),
    completed: j['completed'] as bool? ?? false,
    stars: j['stars'] as int? ?? 0,
  );

  factory GameLevel.create({required String name, int levelNumber = 1}) {
    final id = 'lvl-${DateTime.now().millisecondsSinceEpoch}-$levelNumber';
    return GameLevel(id: id, name: name);
  }
}

/// یک پروژهٔ بازی با چندین مرحله (تا ۲۰ مرحله)
class GameProject {
  final String id;
  String name;
  GameGenre genre;
  List<GameLevel> levels;

  GameProject({
    required this.id,
    required this.name,
    required this.genre,
    List<GameLevel>? levels,
  }) : levels = levels ?? [];

  /// مرحلهٔ اول قابل‌بازشدن، بقیه قفل (مگر اینکه کامل شده باشند)
  int get nextLevelIndex {
    for (int i = 0; i < levels.length; i++) {
      if (!levels[i].completed) return i;
    }
    return levels.length - 1;
  }

  /// آیا مرحلهٔ i قابل‌بازشدن است؟ (اولین یا قبلی کامل شده)
  bool canOpenLevel(int i) {
    if (i == 0) return true;
    if (i >= levels.length) return false;
    return levels[i - 1].completed;
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'genre': genre.name,
    'levels': levels.map((e) => e.toJson()).toList(),
  };

  factory GameProject.fromJson(Map<String, dynamic> j) => GameProject(
    id: j['id'] as String,
    name: j['name'] as String,
    genre: GameGenre.values.byName(j['genre'] as String),
    levels: (j['levels'] as List? ?? []).map((e) => GameLevel.fromJson(e as Map<String, dynamic>)).toList(),
  );

  factory GameProject.create({required String name, required GameGenre genre}) {
    final id = 'proj-${DateTime.now().millisecondsSinceEpoch}';
    final project = GameProject(id: id, name: name, genre: genre);
    // اولین مرحلهٔ پیش‌فرض
    project.levels.add(GameLevel.create(name: 'مرحلهٔ ۱', levelNumber: 1));
    return project;
  }

  /// Export به JSON string برای اشتراک‌گذاری
  String exportToJson() => jsonEncode(toJson());

  /// Import از JSON string
  static GameProject? importFromJson(String jsonStr) {
    try {
      final j = jsonDecode(jsonStr) as Map<String, dynamic>;
      return GameProject.fromJson(j);
    } catch (_) {
      return null;
    }
  }
}

/// دستاوردها
class Achievement {
  final String id, name, description, emoji;
  const Achievement({required this.id, required this.name, required this.description, required this.emoji});
}

class Achievements {
  static const List<Achievement> all = [
    Achievement(id: 'first_project', name: 'اولین بازی', description: 'اولین بازی خودت را بساز', emoji: '🎮'),
    Achievement(id: 'all_types', name: 'همه سبک‌ها', description: 'از هر سبک یک بازی بساز', emoji: '🏆'),
    Achievement(id: 'first_win', name: 'اولین برد', description: 'یک مرحله را کامل کن', emoji: '⭐'),
    Achievement(id: 'collect_100_coins', name: 'گوهرگردان', description: '۱۰۰ سکه جمع کن', emoji: '💰'),
    Achievement(id: 'stomp_10_enemies', name: 'دشمن‌کوب', description: '۱۰ دشمن را بکش', emoji: '⚔️'),
    Achievement(id: 'complete_10_levels', name: 'قهرمان', description: '۱۰ مرحله را کامل کن', emoji: '👑'),
    Achievement(id: 'multi_level', name: 'معمار', description: 'یک پروژه با ۵+ مرحله بساز', emoji: '🏗️'),
    Achievement(id: 'import_project', name: 'مهمان‌نواز', description: 'یک پروژه را import کن', emoji: '📥'),
  ];
}

class GameStore {
  static const _key = 'bazisazi-afsane-projects-v7';
  static const _achievementsKey = 'bazisazi-afsane-achievements-v7';
  static const _coinsKey = 'bazisazi-afsane-total-coins-v7';
  static const _enemiesKey = 'bazisazi-afsane-enemies-killed-v7';
  static const _levelsKey = 'bazisazi-afsane-levels-completed-v7';

  static Future<List<GameProject>> loadAll() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => GameProject.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveAll(List<GameProject> projects) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_key, jsonEncode(projects.map((e) => e.toJson()).toList()));
  }

  static Future<Set<String>> unlockedAchievements() async {
    final p = await SharedPreferences.getInstance();
    return (p.getStringList(_achievementsKey) ?? []).toSet();
  }

  static Future<void> unlock(String id) async {
    final p = await SharedPreferences.getInstance();
    final current = (p.getStringList(_achievementsKey) ?? []).toSet();
    if (current.add(id)) {
      await p.setStringList(_achievementsKey, current.toList());
    }
  }

  static Future<int> totalCoins() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(_coinsKey) ?? 0;
  }

  static Future<void> addCoins(int delta) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_coinsKey, (p.getInt(_coinsKey) ?? 0) + delta);
  }

  static Future<int> enemiesKilled() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(_enemiesKey) ?? 0;
  }

  static Future<void> addEnemyKill() async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_enemiesKey, (p.getInt(_enemiesKey) ?? 0) + 1);
  }

  static Future<int> levelsCompleted() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(_levelsKey) ?? 0;
  }

  static Future<void> addLevelCompleted() async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_levelsKey, (p.getInt(_levelsKey) ?? 0) + 1);
  }
}
