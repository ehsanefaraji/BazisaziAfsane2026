import 'package:flutter_test/flutter_test.dart';
import 'package:little_game_maker/src/game_store.dart';

void main() {
  group('GameProject', () {
    test('create assigns unique id and preserves name and genre', () {
      final p1 = GameProject.create(name: 'بازی من', genre: GameGenre.maze);
      final p2 = GameProject.create(name: 'بازی تو', genre: GameGenre.platformer);
      expect(p1.id, isNot(equals(p2.id)));
      expect(p1.name, equals('بازی من'));
      expect(p1.genre, equals(GameGenre.maze));
      expect(p2.genre, equals(GameGenre.platformer));
    });

    test('toJson and fromJson round-trip preserves all fields', () {
      final original = GameProject(
        id: 'abc',
        name: 'تست',
        genre: GameGenre.catcher,
        rows: 4,
        cols: 3,
        startRow: 3,
        startCol: 0,
        items: [
          PlacedItem(id: 1, row: 0, col: 0, role: ItemRole.coin),
          PlacedItem(id: 2, row: 1, col: 1, role: ItemRole.enemy),
          PlacedItem(id: 3, row: 2, col: 2, role: ItemRole.exit),
        ],
      );
      final json = original.toJson();
      final restored = GameProject.fromJson(json);

      expect(restored.id, equals('abc'));
      expect(restored.name, equals('تست'));
      expect(restored.genre, equals(GameGenre.catcher));
      expect(restored.rows, equals(4));
      expect(restored.cols, equals(3));
      expect(restored.startRow, equals(3));
      expect(restored.startCol, equals(0));
      expect(restored.items.length, equals(3));
      expect(restored.items[0].role, equals(ItemRole.coin));
      expect(restored.items[1].role, equals(ItemRole.enemy));
      expect(restored.items[2].role, equals(ItemRole.exit));
    });

    test('fromJson tolerates missing optional fields', () {
      final restored = GameProject.fromJson({
        'id': 'x',
        'name': 'y',
        'genre': 'maze',
      });
      expect(restored.rows, equals(6));
      expect(restored.cols, equals(4));
      expect(restored.items, isEmpty);
    });
  });

  group('GameGenre', () {
    test('every genre has a label, emoji, description, and color', () {
      for (final g in GameGenre.values) {
        expect(g.label, isNotEmpty);
        expect(g.emoji, isNotEmpty);
        expect(g.description, isNotEmpty);
        expect(g.color, isNotNull);
      }
    });
  });

  group('ItemRole', () {
    test('every role has a label, emoji, and color', () {
      for (final r in ItemRole.values) {
        expect(r.label, isNotEmpty);
        expect(r.emoji, isNotEmpty);
        expect(r.color, isNotNull);
      }
    });
  });
}
