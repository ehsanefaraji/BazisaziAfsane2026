/// مدل‌های بازی نسخهٔ ۵: پاورآپ‌ها، محیط، چندمرحله‌ای، دستاوردها
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme.dart';

enum GameGenre { maze, driving, catcher, story, platformer }

extension GameGenreX on GameGenre {
  String get label {
    switch (this) {
      case GameGenre.maze:        return 'هزارتو';
      case GameGenre.driving:     return 'ماشین\u200cسوار';
      case GameGenre.catcher:     return 'شکارچی ستاره';
      case GameGenre.story:       return 'داستان تعاملی';
      case GameGenre.platformer:  return 'پلتفرمر';
    }
  }

  String get emoji {
    switch (this) {
      case GameGenre.maze:        return '🌀';
      case GameGenre.driving:     return '🏎️';
      case GameGenre.catcher:     return '⭐';
      case GameGenre.story:       return '📖';
      case GameGenre.platformer:  return '🦊';
    }
  }

  String get description {
    switch (this) {
      case GameGenre.maze:        return 'مسیری بساز و گنج را پیدا کن';
      case GameGenre.driving:     return 'با ماشین از موانع عبور کن';
      case GameGenre.catcher:     return 'ستاره\u200cها را بگیر، بمب را نه';
      case GameGenre.story:       return 'صحنه بساز و روایت کن';
      case GameGenre.platformer:  return 'بپر، بدود، به در خروجی برس';
    }
  }

  Color get color {
    switch (this) {
      case GameGenre.maze:        return const Color(0xFF4CAF50);
      case GameGenre.driving:     return const Color(0xFFFF7043);
      case GameGenre.catcher:     return const Color(0xFFFFB300);
      case GameGenre.story:       return const Color(0xFF7E57C2);
      case GameGenre.platformer:  return const Color(0xFF29B6F6);
    }
  }

  Environment get environment {
    switch (this) {
      case GameGenre.maze:        return Environment.forest;
      case GameGenre.platformer:  return Environment.sky;
      case GameGenre.catcher:     return Environment.underwater;
      case GameGenre.driving:     return Environment.cave;
      case GameGenre.story:       return Environment.castle;
    }
  }
}

/// نقش هر آیتم روی بوم
enum ItemRole {
  coin,        // سکه
  enemy,       // دشمن
  exit,        // در خروجی
  decoration,  // تزئین
  shield,      // پاورآپ: سپر
  magnet,      // پاورآپ: آهنربا
  speedBoost,  // پاورآپ: سرعت
  extraLife,   // پاورآپ: جان اضافه
}

extension ItemRoleX on ItemRole {
  String get label {
    switch (this) {
      case ItemRole.coin:        return 'سکه';
      case ItemRole.enemy:       return 'دشمن';
      case ItemRole.exit:        return 'در خروجی';
      case ItemRole.decoration:  return 'تزئین';
      case ItemRole.shield:      return 'سپر';
      case ItemRole.magnet:      return 'آهنربا';
      case ItemRole.speedBoost:  return 'سرعت';
      case ItemRole.extraLife:   return 'جان اضافه';
    }
  }

  String get emoji {
    switch (this) {
      case ItemRole.coin:        return '💎';
      case ItemRole.enemy:       return '👾';
      case ItemRole.exit:        return '🚪';
      case ItemRole.decoration:  return '🌸';
      case ItemRole.shield:      return '🛡️';
      case ItemRole.magnet:      return '🧲';
      case ItemRole.speedBoost:  return '⚡';
      case ItemRole.extraLife:   return '❤️';
    }
  }

  Color get color {
    switch (this) {
      case ItemRole.coin:        return const Color(0xFFFFD54F);
      case ItemRole.enemy:       return const Color(0xFFEF5350);
      case ItemRole.exit:        return const Color(0xFF66BB6A);
      case ItemRole.decoration:  return const Color(0xFFCE93D8);
      case ItemRole.shield:      return const Color(0xFF42A5F5);
      case ItemRole.magnet:      return const Color(0xFFFF7043);
      case ItemRole.speedBoost:  return const Color(0xFFAB47BC);
      case ItemRole.extraLife:   return const Color(0xFFEC407A);
    }
  }

  bool get isPowerUp => switch (this) {
    ItemRole.shield || ItemRole.magnet || ItemRole.speedBoost || ItemRole.extraLife => true,
    _ => false,
  };
}

class PlacedItem {
  final int id;
  final int row;
  final int col;
  ItemRole role;

  PlacedItem({required this.id, required this.row, required this.col, required this.role});

  Map<String, dynamic> toJson() => {
    'id': id, 'row': row, 'col': col, 'role': role.name,
  };

  factory PlacedItem.fromJson(Map<String, dynamic> j) => PlacedItem(
    id: j['id'] as int,
    row: j['row'] as int,
    col: j['col'] as int,
    role: ItemRole.values.byName(j['role'] as String),
  );
}

class GameProject {
  final String id;
  String name;
  GameGenre genre;
  int rows;
  int cols;
  int startRow;
  int startCol;
  List<PlacedItem> items;

  GameProject({
    required this.id,
    required this.name,
    required this.genre,
    this.rows = 6,
    this.cols = 4,
    this.startRow = 5,
    this.startCol = 0,
    List<PlacedItem>? items,
  }) : items = items ?? [];

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'genre': genre.name,
    'rows': rows, 'cols': cols, 'startRow': startRow, 'startCol': startCol,
    'items': items.map((e) => e.toJson()).toList(),
  };

  factory GameProject.fromJson(Map<String, dynamic> j) => GameProject(
    id: j['id'] as String,
    name: j['name'] as String,
    genre: GameGenre.values.byName(j['genre'] as String),
    rows: j['rows'] as int? ?? 6,
    cols: j['cols'] as int? ?? 4,
    startRow: j['startRow'] as int? ?? 5,
    startCol: j['startCol'] as int? ?? 0,
    items: (j['items'] as List? ?? [])
        .map((e) => PlacedItem.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  factory GameProject.create({required String name, required GameGenre genre}) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    return GameProject(id: id, name: name, genre: genre);
  }
}

/// دستاوردها
class Achievement {
  final String id;
  final String name;
  final String description;
  final String emoji;
  const Achievement({required this.id, required this.name, required this.description, required this.emoji});
}

class Achievements {
  static const List<Achievement> all = [
    Achievement(id: 'first_project', name: 'اولین بازی', description: 'اولین بازی خودت را بساز', emoji: '🎮'),
    Achievement(id: 'all_types', name: 'همه سبک‌ها', description: 'از هر سبک یک بازی بساز', emoji: '🏆'),
    Achievement(id: 'first_win', name: 'اولین برد', description: 'یک مرحله را کامل کن', emoji: '⭐'),
    Achievement(id: 'collect_100_coins', name: 'گوهرگردان', description: '۱۰۰ سکه جمع کن', emoji: '💰'),
    Achievement(id: 'stomp_10_enemies', name: 'دشمن‌کوب', description: '۱۰ دشمن را بکش', emoji: '⚔️'),
  ];
}

class GameStore {
  static const _key = 'bazisazi-afsane-projects-v5';
  static const _achievementsKey = 'bazisazi-afsane-achievements-v5';
  static const _coinsKey = 'bazisazi-afsane-total-coins-v5';
  static const _enemiesKey = 'bazisazi-afsane-enemies-killed-v5';

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
    final raw = p.getStringList(_achievementsKey) ?? [];
    return raw.toSet();
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
    final current = p.getInt(_coinsKey) ?? 0;
    await p.setInt(_coinsKey, current + delta);
  }

  static Future<int> enemiesKilled() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(_enemiesKey) ?? 0;
  }

  static Future<void> addEnemyKill() async {
    final p = await SharedPreferences.getInstance();
    final current = p.getInt(_enemiesKey) ?? 0;
    await p.setInt(_enemiesKey, current + 1);
  }
}
