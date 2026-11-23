/// بازی هزارتو: حرکت سلول‌به‌سلول با تشخیص مسیر، گنج، دشمن، در خروجی.
import 'package:flutter/material.dart';
import '../audio/audio_manager.dart';

class MazeGame extends StatefulWidget {
  final int rows;
  final int cols;
  final int startRow;
  final int startCol;
  final List<({int id, int row, int col, String type})> items;
  final VoidCallback onWin;
  final VoidCallback onLose;

  const MazeGame({
    super.key,
    required this.rows,
    required this.cols,
    required this.startRow,
    required this.startCol,
    required this.items,
    required this.onWin,
    required this.onLose,
  });

  @override
  State<MazeGame> createState() => _MazeGameState();
}

class _MazeGameState extends State<MazeGame> {
  late int _playerRow;
  late int _playerCol;
  late List<int> _collectedCoins;
  int _score = 0;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _playerRow = widget.startRow;
    _playerCol = widget.startCol;
    _collectedCoins = [];
  }

  void _move(int dr, int dc) {
    if (_finished) return;
    final newRow = _playerRow + dr;
    final newCol = _playerCol + dc;
    if (newRow < 0 || newRow >= widget.rows) return;
    if (newCol < 0 || newCol >= widget.cols) return;

    setState(() {
      _playerRow = newRow;
      _playerCol = newCol;
      // بررسی موجودیت در خانهٔ جدید
      for (final it in widget.items) {
        if (it.row != newRow || it.col != newCol) continue;
        if (_collectedCoins.contains(it.id)) continue;
        switch (it.type) {
          case 'coin':
            _score += 10;
            _collectedCoins.add(it.id);
            AudioManager.instance.coin();
            break;
          case 'enemy':
            _finished = true;
            AudioManager.instance.hurt();
            widget.onLose();
            break;
          case 'exit':
            _finished = true;
            AudioManager.instance.win();
            widget.onWin();
            break;
          case 'shield':
            _collectedCoins.add(it.id);
            AudioManager.instance.shield();
            break;
          case 'magnet':
          case 'speedBoost':
            _collectedCoins.add(it.id);
            AudioManager.instance.powerUp();
            break;
          case 'extraLife':
            _collectedCoins.add(it.id);
            AudioManager.instance.powerUp();
            break;
          case 'decoration':
            break;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text('امتیاز: $_score', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: widget.cols,
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
            ),
            itemCount: widget.rows * widget.cols,
            itemBuilder: (context, i) {
              final row = i ~/ widget.cols;
              final col = i % widget.cols;
              final isPlayer = row == _playerRow && col == _playerCol;
              final isStart = row == widget.startRow && col == widget.startCol;
              final item = widget.items.cast<dynamic?>().firstWhere(
                (it) => it?.row == row && it?.col == col && !_collectedCoins.contains(it!.id),
                orElse: () => null,
              );
              return Container(
                decoration: BoxDecoration(
                  color: item != null
                      ? _colorForType(item.type as String)
                      : (isStart ? Colors.green.shade100 : Colors.brown.shade100),
                  border: Border.all(color: Colors.brown.shade400, width: 0.5),
                ),
                child: Center(
                  child: Text(
                    isPlayer ? '🦊' : (item != null ? _emojiForType(item.type as String) : (isStart ? '🏁' : '')),
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
              );
            },
          ),
        ),
        _buildDpad(),
      ],
    );
  }

  Widget _buildDpad() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [_btn(Icons.arrow_upward, () => _move(-1, 0))]),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _btn(Icons.arrow_back, () => _move(0, 1)),
              const SizedBox(width: 32),
              _btn(Icons.arrow_forward, () => _move(0, -1)),
            ]),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [_btn(Icons.arrow_downward, () => _move(1, 0))]),
          ],
        ),
      ),
    );
  }

  Widget _btn(IconData icon, VoidCallback onPressed) {
    return Container(
      width: 72,
      height: 72,
      margin: const EdgeInsets.all(4),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFFB388FF), Color(0xFF5E35B1)]),
        shape: BoxShape.circle,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(onTap: onPressed, customBorder: const CircleBorder(), child: Icon(icon, color: Colors.white, size: 32)),
      ),
    );
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'coin':        return Colors.yellow.shade200;
      case 'enemy':       return Colors.red.shade200;
      case 'exit':        return Colors.green.shade200;
      case 'shield':      return Colors.blue.shade200;
      case 'magnet':      return Colors.orange.shade200;
      case 'speedBoost':  return Colors.purple.shade200;
      case 'extraLife':   return Colors.pink.shade200;
      default:            return Colors.purple.shade100;
    }
  }

  String _emojiForType(String type) {
    switch (type) {
      case 'coin':        return '💎';
      case 'enemy':       return '👾';
      case 'exit':        return '🚪';
      case 'shield':      return '🛡️';
      case 'magnet':      return '🧲';
      case 'speedBoost':  return '⚡';
      case 'extraLife':   return '❤️';
      default:            return '🌸';
    }
  }
}
