/// مدیر صدا نسخهٔ ۵ — موسیقی چندصدایی + ۸ افکت + کنترل مستقل
import 'dart:math';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  AudioManager._();
  static final AudioManager instance = AudioManager._();

  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();
  bool _soundEnabled = true;
  bool _musicEnabled = false;

  bool get soundEnabled => _soundEnabled;
  bool get musicEnabled => _musicEnabled;

  set soundEnabled(bool v) {
    _soundEnabled = v;
    if (!v) _sfxPlayer.stop();
  }

  set musicEnabled(bool v) {
    _musicEnabled = v;
    if (!v) _musicPlayer.stop();
  }

  /// تولید WAV با چند نوت، هر نوت شامل فرکانس و مدت و نوع موج
  Uint8List _generateTone(
    List<(int, int, String)> notes, {
    int sampleRate = 22050,
    double volume = 0.4,
  }) {
    final totalMs = notes.fold<int>(0, (a, n) => a + n.$2);
    final totalSamples = (sampleRate * totalMs / 1000).round();
    final bytesPerSample = 2;
    final dataLength = totalSamples * bytesPerSample;
    final buffer = ByteData(44 + dataLength);
    // WAV header
    buffer.setUint32(0, 0x52494646, Endian.big); // "RIFF"
    buffer.setUint32(4, 36 + dataLength, Endian.little);
    buffer.setUint32(8, 0x57415645, Endian.big); // "WAVE"
    buffer.setUint32(12, 0x666d7420, Endian.big); // "fmt "
    buffer.setUint32(16, 16, Endian.little);
    buffer.setUint16(20, 1, Endian.little); // PCM
    buffer.setUint16(22, 1, Endian.little); // mono
    buffer.setUint32(24, sampleRate, Endian.little);
    buffer.setUint32(28, sampleRate * bytesPerSample, Endian.little);
    buffer.setUint16(32, bytesPerSample, Endian.little);
    buffer.setUint16(34, 16, Endian.little);
    buffer.setUint32(36, 0x64617461, Endian.big); // "data"
    buffer.setUint32(40, dataLength, Endian.little);

    int sampleIdx = 0;
    for (final (freq, durMs, waveType) in notes) {
      final samples = (sampleRate * durMs / 1000).round();
      for (int i = 0; i < samples; i++) {
        final t = i / sampleRate;
        // Envelope: attack + decay
        final env = i < samples * 0.1
            ? (i / (samples * 0.1))
            : (1 - (i - samples * 0.1) / (samples * 0.9));
        final envClamped = env.clamp(0.0, 1.0);
        // شکل موج
        double wave;
        switch (waveType) {
          case 'sine':
            wave = sin(2 * pi * freq * t);
            break;
          case 'square':
            wave = (sin(2 * pi * freq * t) > 0) ? 1 : -1;
            break;
          case 'saw':
            wave = 2 * (freq * t - (freq * t).floor()) - 1;
            break;
          case 'triangle':
            wave = 2 * (2 * (freq * t - (freq * t + 0.5).floor())) - 1;
            break;
          default:
            wave = sin(2 * pi * freq * t);
        }
        // نویز کم
        final noise = (Random().nextDouble() - 0.5) * 0.02;
        final sampleValue = (wave * volume * envClamped + noise) * 32767;
        buffer.setInt16(44 + sampleIdx * 2, sampleValue.round(), Endian.little);
        sampleIdx++;
      }
    }
    return buffer.buffer.asUint8List();
  }

  // ۸ افکت

  Future<void> jump() async {
    if (!_soundEnabled) return;
    final wav = _generateTone([
      (400, 30, 'sine'), (500, 30, 'sine'), (650, 30, 'sine'), (800, 60, 'sine'),
    ]);
    await _sfxPlayer.play(BytesSource(wav));
  }

  Future<void> coin() async {
    if (!_soundEnabled) return;
    final wav = _generateTone([
      (880, 50, 'triangle'), (1320, 80, 'triangle'),
    ], volume: 0.35);
    await _sfxPlayer.play(BytesSource(wav));
  }

  Future<void> hurt() async {
    if (!_soundEnabled) return;
    final wav = _generateTone([
      (200, 80, 'saw'), (120, 120, 'saw'),
    ], volume: 0.45);
    await _sfxPlayer.play(BytesSource(wav));
  }

  Future<void> stomp() async {
    if (!_soundEnabled) return;
    final wav = _generateTone([
      (300, 40, 'square'), (600, 40, 'square'), (900, 60, 'square'),
    ]);
    await _sfxPlayer.play(BytesSource(wav));
  }

  Future<void> win() async {
    if (!_soundEnabled) return;
    final wav = _generateTone([
      (523, 120, 'triangle'), (659, 120, 'triangle'), (784, 200, 'triangle'),
      (1047, 300, 'triangle'),
    ], volume: 0.4);
    await _sfxPlayer.play(BytesSource(wav));
  }

  Future<void> click() async {
    if (!_soundEnabled) return;
    final wav = _generateTone([(660, 50, 'sine')], volume: 0.25);
    await _sfxPlayer.play(BytesSource(wav));
  }

  /// پاورآپ گرفتن — نت صعودی بلندتر
  Future<void> powerUp() async {
    if (!_soundEnabled) return;
    final wav = _generateTone([
      (440, 60, 'triangle'), (554, 60, 'triangle'), (659, 60, 'triangle'),
      (880, 120, 'triangle'),
    ], volume: 0.4);
    await _sfxPlayer.play(BytesSource(wav));
  }

  /// سپر فعال شدن — نت باس و محکم
  Future<void> shield() async {
    if (!_soundEnabled) return;
    final wav = _generateTone([
      (110, 100, 'sine'), (220, 100, 'sine'), (330, 150, 'sine'),
    ], volume: 0.45);
    await _sfxPlayer.play(BytesSource(wav));
  }

  /// موسیقی پس‌زمینه: یک لوپ ۸ ثانیه‌ای با ملودی و باس
  /// ساختار: ۸ میزان، هر میزان ۱ ثانیه
  Future<void> startMusic() async {
    if (!_musicEnabled) return;
    // ملودی اصلی (C major scale بر اساس گام)
    final melody = <(int, int, String)>[
      // میزان ۱: C - E - G - C (آکورد C major arpeggio)
      (523, 250, 'triangle'), (659, 250, 'triangle'), (784, 250, 'triangle'), (1047, 250, 'triangle'),
      // میزان ۲: D - F - A - D
      (587, 250, 'triangle'), (698, 250, 'triangle'), (880, 250, 'triangle'), (1175, 250, 'triangle'),
      // میزان ۳: E - G - B - E
      (659, 250, 'triangle'), (784, 250, 'triangle'), (988, 250, 'triangle'), (1319, 250, 'triangle'),
      // میزان ۴: C - E - G - C (بازگشت)
      (523, 250, 'triangle'), (659, 250, 'triangle'), (784, 250, 'triangle'), (1047, 250, 'triangle'),
      // میزان ۵-۸: باس عمیق‌تر
      (261, 500, 'sine'), (330, 500, 'sine'),
      (294, 500, 'sine'), (392, 500, 'sine'),
      (330, 500, 'sine'), (440, 500, 'sine'),
      (261, 500, 'sine'), (392, 500, 'sine'),
    ];
    final wav = _generateTone(melody, volume: 0.2);
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    await _musicPlayer.play(BytesSource(wav));
  }

  Future<void> stopMusic() async => _musicPlayer.stop();

  Future<void> dispose() async {
    await _sfxPlayer.dispose();
    await _musicPlayer.dispose();
  }
}
