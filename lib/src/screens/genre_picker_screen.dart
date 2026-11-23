/// انتخاب سبک بازی — نسخهٔ ۳ با کارت‌های گرادیانی پر جنب‌وجوش
import 'package:flutter/material.dart';
import '../theme.dart';
import '../game_store.dart';
import 'editor_screen.dart';

class GenrePickerScreen extends StatefulWidget {
  const GenrePickerScreen({super.key});

  @override
  State<GenrePickerScreen> createState() => _GenrePickerScreenState();
}

class _GenrePickerScreenState extends State<GenrePickerScreen> {
  GameGenre? _selected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('کدام سبک بازی؟', style: TextStyle(fontWeight: FontWeight.bold)),
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
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0D1457),
              Color(0xFF311B92),
              Color(0xFF5E35B1),
              Color(0xFF8E44FF),
              AppPalette.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: GameGenre.values.length,
            itemBuilder: (context, i) {
              final genre = GameGenre.values[i];
              final selected = _selected == genre;
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _GenreCard(
                  genre: genre,
                  selected: selected,
                  onTap: () => setState(() => _selected = genre),
                ),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: _selected == null ? null : AppPalette.buttonGradient,
              boxShadow: _selected == null ? null : AppShadows.button,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: _selected == null
                    ? null
                    : () async {
                        final project = GameProject.create(
                          name: 'بازی ${_selected!.label}',
                          genre: _selected!,
                        );
                        // برای پلتفرمر، چند سکه و دشمن نمونه اضافه کن
                        if (project.genre == GameGenre.platformer) {
                          project.items.addAll([
                            PlacedItem(id: 1, row: 2, col: 1, role: ItemRole.coin),
                            PlacedItem(id: 2, row: 3, col: 2, role: ItemRole.coin),
                            PlacedItem(id: 3, row: 4, col: 3, role: ItemRole.coin),
                            PlacedItem(id: 4, row: 1, col: 2, role: ItemRole.enemy),
                            PlacedItem(id: 5, row: 5, col: 3, role: ItemRole.exit),
                          ]);
                        }
                        if (!mounted) return;
                        final edited = await Navigator.push<GameProject>(
                          context,
                          MaterialPageRoute(builder: (_) => EditorScreen(project: project)),
                        );
                        Navigator.pop(context, edited ?? project);
                      },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_forward, color: _selected == null ? Colors.grey : Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        'ادامه',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _selected == null ? Colors.grey : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GenreCard extends StatelessWidget {
  final GameGenre genre;
  final bool selected;
  final VoidCallback onTap;

  const _GenreCard({required this.genre, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            genre.color.withValues(alpha: 0.95),
            genre.color.withValues(alpha: 0.55),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: genre.color.withValues(alpha: selected ? 0.6 : 0.3),
            offset: const Offset(0, 8),
            blurRadius: selected ? 20 : 12,
          ),
        ],
        border: Border.all(
          color: selected ? Colors.white : Colors.white.withValues(alpha: 0.3),
          width: selected ? 3 : 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 2),
                  ),
                  child: Center(child: Text(genre.emoji, style: const TextStyle(fontSize: 44))),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        genre.label,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        genre.description,
                        style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.9), height: 1.4),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: selected ? Colors.white : Colors.black.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    selected ? Icons.check : Icons.radio_button_off,
                    color: selected ? genre.color : Colors.white.withValues(alpha: 0.7),
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
