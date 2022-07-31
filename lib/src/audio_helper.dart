import 'package:just_audio/just_audio.dart';

/// This all methods must be static to make it works
class AudioHelper {
  AudioHelper._();

  static final _soundPlayer = AudioPlayer();
  static final _bgSoundPlayer = AudioPlayer();

  static String _backgroundPrefix = '';
  static String _soundPrefix = '';

  static bool _isInitialed = false;
  static String _lastSoundName = '';

  /// Initial sound helper
  static Future<void> initial({
    // Prefix path for background music
    String backgroundPrefix = 'assets/audio/music/',

    // Prefix path for sound
    String soundPrefix = 'assets/audio/sound/',

    // Name with extension. Ex: ['love-story.mp3']
    List<String>? backgroundMusicNames,

    // Volume for sound. 0 -> 1
    double soundVolume = 1.0,

    // Volume for background music. 0 -> 1
    double backgroundMusicVolume = 1.0,
  }) async {
    if (_isInitialed) return;
    _isInitialed = true;

    _backgroundPrefix = backgroundPrefix;
    _soundPrefix = soundPrefix;

    final playlist = ConcatenatingAudioSource(
      // Start loading next item just before reaching it
      useLazyPreparation: true,
      // Customise the shuffle algorithm
      shuffleOrder: DefaultShuffleOrder(),
      // Specify the playlist items
      children: [
        if (backgroundMusicNames != null)
          for (final name in backgroundMusicNames)
            AudioSource.uri(Uri.parse('asset:///$_backgroundPrefix$name')),
      ],
    );

    await Future.wait([
      _soundPlayer.setVolume(soundVolume),
      _soundPlayer.setLoopMode(LoopMode.off),
      _bgSoundPlayer.setVolume(backgroundMusicVolume),
      _bgSoundPlayer.setLoopMode(LoopMode.all),
    ]);

    await _bgSoundPlayer.setAudioSource(
      playlist,
      initialPosition: Duration.zero,
    );
  }

  /// Dispose sound helper
  static Future<void> dispose() async {
    await Future.wait([
      _soundPlayer.dispose(),
      _bgSoundPlayer.dispose(),
    ]);
  }

  /// name with extension. Ex: bound.mp3
  static void playSound(String name) async {
    if (_lastSoundName != name) {
      await _soundPlayer.setAsset('$_soundPrefix$name');
      _lastSoundName = name;
    }

    await _soundPlayer.seek(Duration.zero);
    _soundPlayer.play();
  }

  /// Play background music list
  static void playMusic() {
    _bgSoundPlayer.play();
  }

  /// Stop background music
  static void stopMusic() {
    _bgSoundPlayer.stop();
  }
}
