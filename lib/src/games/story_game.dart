/// بازی داستان تعاملی: ۵ صحنه، هر صحنه یک انتخاب با دو گزینه.
import 'package:flutter/material.dart';
import '../audio/audio_manager.dart';

class StoryGame extends StatefulWidget {
  final VoidCallback onWin;
  final VoidCallback onLose;

  const StoryGame({super.key, required this.onWin, required this.onLose});

  @override
  State<StoryGame> createState() => _StoryGameState();
}

class _StoryGameState extends State<StoryGame> {
  int _scene = 0;
  int _hearts = 3;

  static const _scenes = [
    (
      title: 'جنگل تاریک',
      emoji: '🌲',
      text: 'روباه در جنگل تاریک گم شده. یک مسیر کوتاه ولی خطرناک، یک مسیر طولانی ولی امن. کدام را انتخاب می\u200cکنی؟',
      choice1: 'مسیر کوتاه 🐺',
      choice2: 'مسیر طولانی 🦌',
      correct: 2,
    ),
    (
      title: 'پل شکسته',
      emoji: '🌉',
      text: 'به یک پل شکسته رسیدی. می\u200cتوانی از روی آن بپری یا دور بزنی.',
      choice1: 'پرش 💪',
      choice2: 'دور زدن 🚶',
      correct: 1,
    ),
    (
      title: 'غار دوستانه',
      emoji: '🕳️',
      text: 'یک غار با صدای عجیب. داخل چیست؟',
      choice1: 'ورود به غار 🔦',
      choice2: 'فرار از غار 🏃',
      correct: 1,
    ),
    (
      title: 'دریاچهٔ جادویی',
      emoji: '🌊',
      text: 'یک ماهی سخن\u200cگو پیدا کردی. به او کمک می\u200cکنی یا نادیده می\u200cگیری؟',
      choice1: 'کمک 🤝',
      choice2: 'نادیده 🙈',
      correct: 1,
    ),
    (
      title: 'قلعهٔ نهایی',
      emoji: '🏰',
      text: 'به قلعهٔ افسانه رسیدی. در بزرگ باز است. وارد می\u200cشوی؟',
      choice1: 'ورود به قلعه 🚪',
      choice2: 'صبر کردن ⏳',
      correct: 1,
    ),
  ];

  void _choose(int choice) {
    final scene = _scenes[_scene];
    if (choice == scene.correct) {
      AudioManager.instance.coin();
      if (_scene < _scenes.length - 1) {
        setState(() => _scene++);
      } else {
        AudioManager.instance.win();
        widget.onWin();
      }
    } else {
      setState(() => _hearts--);
      AudioManager.instance.hurt();
      if (_hearts <= 0) {
        widget.onLose();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scene = _scenes[_scene];
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A237E), Color(0xFF7E57C2), Color(0xFFFFF8E7)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hearts
              Row(
                children: [
                  for (int i = 0; i < 3; i++)
                    Icon(
                      i < _hearts ? Icons.favorite : Icons.favorite_border,
                      color: Colors.red,
                      size: 24,
                    ),
                  const Spacer(),
                  Text('صحنهٔ ${_scene + 1} از ${_scenes.length}',
                      style: const TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
              const Spacer(),
              // Emoji بزرگ
              Center(child: Text(scene.emoji, style: const TextStyle(fontSize: 96))),
              const SizedBox(height: 16),
              // عنوان
              Center(
                child: Text(
                  scene.title,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              // متن داستان
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  scene.text,
                  style: const TextStyle(color: Colors.white, fontSize: 18, height: 1.6),
                  textAlign: TextAlign.center,
                ),
              ),
              const Spacer(),
              // دو انتخاب
              Row(
                children: [
                  Expanded(child: _choiceBtn(scene.choice1, () => _choose(1))),
                  const SizedBox(width: 12),
                  Expanded(child: _choiceBtn(scene.choice2, () => _choose(2))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _choiceBtn(String text, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFB388FF), Color(0xFF5E35B1)]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.purple.withValues(alpha: 0.4), offset: const Offset(0, 4), blurRadius: 10),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
