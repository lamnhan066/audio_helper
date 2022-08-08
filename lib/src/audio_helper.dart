import 'package:flutter/widgets.dart';
import 'package:just_audio/just_audio.dart';

/// This all methods must be static to make it works
class AudioHelper extends WidgetsBindingObserver {
  AudioHelper._();

  static final _soundPlayer = AudioPlayer();
  static final _bgSoundPlayer = AudioPlayer();

  static String _backgroundPrefix = '';
  static String _soundPrefix = '';

  static bool _isInitialed = false;
  static String _lastSoundName = '';

  static bool _isPlayMusic = false;

  static final _registerObserver = _RegisterObserver(
    onStateChanged: (state) {
      if (_isPlayMusic) {
        if (state == AppLifecycleState.resumed) {
          playMusic();
        } else {
          _pauseMusic();
        }
      }
    },
  );

  /// Initial audio helper
  ///
  /// `backgroundPrefix` the prefix path of the background music
  ///
  /// `soundPrefix` the prefix path of sounds
  ///
  /// `backgroundMusicNames` all the background music names without prefix
  ///
  /// `soundVolume` volume of sounds
  ///
  /// `musicVolume` volume of the background music
  static Future<void> initial({
    // Prefix path for background music
    String backgroundPrefix = 'assets/audio/music/',

    // Prefix path for sound
    String soundPrefix = 'assets/audio/sound/',

    // Name with extension. Ex: ['love-story.mp3']
    List<String> backgroundMusicNames = const [],

    // Volume for sound. 0 -> 1
    double soundVolume = 1.0,

    // Volume for background music. 0 -> 1
    double musicVolume = 1.0,
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
        for (final name in backgroundMusicNames)
          AudioSource.uri(Uri.parse('asset:///$_backgroundPrefix$name')),
      ],
    );

    await Future.wait([
      _soundPlayer.setVolume(soundVolume),
      _soundPlayer.setLoopMode(LoopMode.off),
      _bgSoundPlayer.setVolume(musicVolume),
      _bgSoundPlayer.setLoopMode(LoopMode.all),
    ]);

    await _bgSoundPlayer.setAudioSource(
      playlist,
      initialPosition: Duration.zero,
    );
  }

  /// Dispose audio helper
  static Future<void> dispose() async {
    _registerObserver.register();
    await Future.wait([
      _soundPlayer.dispose(),
      _bgSoundPlayer.dispose(),
    ]);
  }

  /// Play sound, `name` is the file name with extension. Ex: bound.mp3
  static void playSound(String name) async {
    if (_lastSoundName != name) {
      await _soundPlayer.setAsset('$_soundPrefix$name');
      _lastSoundName = name;
    }

    await _soundPlayer.seek(Duration.zero);
    _soundPlayer.play();
  }

  /// Play background music
  static void playMusic() {
    _isPlayMusic = true;
    _registerObserver.register();
    _bgSoundPlayer.play();
  }

  /// Stop background music
  static void stopMusic() {
    _isPlayMusic = false;
    _bgSoundPlayer.stop();
  }

  /// Next background music song
  static void nextMusic() {
    _bgSoundPlayer.seekToNext();
  }

  /// Pause the background music
  static void _pauseMusic() {
    _bgSoundPlayer.stop();
  }
}

/// Register the auto stop when users leave the app
class _RegisterObserver extends WidgetsBindingObserver {
  final void Function(AppLifecycleState state) onStateChanged;
  bool _isRegisteredBindingObserver = false;

  _RegisterObserver({required this.onStateChanged});

  void register() {
    if (!_isRegisteredBindingObserver) {
      _isRegisteredBindingObserver = true;
      WidgetsBinding.instance.addObserver(this);
    }
  }

  void unRegister() {
    if (_isRegisteredBindingObserver) {
      _isRegisteredBindingObserver = false;
      WidgetsBinding.instance.removeObserver(this);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    onStateChanged(state);
  }
}
