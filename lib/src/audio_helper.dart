import 'package:just_audio/just_audio.dart';

class AudioHelper {
  static AudioHelper get instance => AudioHelper._();

  AudioHelper._();

  final _soundPlayer = AudioPlayer();
  final _bgSoundPlayer = AudioPlayer();

  String _backgroundPrefix = '';
  String _soundPrefix = '';
  late ConcatenatingAudioSource _playlist;

  bool _isInitialed = false;
  String _lastSoundName = '';

  /// Initial sound helper
  Future<void> initial({
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

    _playlist = ConcatenatingAudioSource(
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

    _soundPlayer.setVolume(soundVolume);
    _soundPlayer.setLoopMode(LoopMode.off);

    _bgSoundPlayer.setVolume(backgroundMusicVolume);
    _bgSoundPlayer.setLoopMode(LoopMode.all);

    _bgSoundPlayer.setAudioSource(
      _playlist,
      initialPosition: Duration.zero,
    );
  }

  /// Dispose sound helper
  Future<void> dispose() async {
    _soundPlayer.dispose();
    _bgSoundPlayer.dispose();
  }

  /// name with extension. Ex: bound.mp3
  void playSound(String name) async {
    if (_lastSoundName != name) {
      await _soundPlayer.setAsset('$_soundPrefix$name');
      _lastSoundName = name;
    }

    await _soundPlayer.seek(Duration.zero);
    _soundPlayer.play();
  }

  /// Play background music list
  void playMusic() {
    _bgSoundPlayer.play();
  }

  /// Stop background music
  void stopMusic() {
    _bgSoundPlayer.stop();
  }
}
