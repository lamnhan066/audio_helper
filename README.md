# Audio Helper

Help you easier to add sounds and background music to your games or apps.

## Usage

Default path of the asset files:

``` yaml
flutter:
  assets:
    # Backgound music path 
    - assets/audio/music/name1.mp3
    - assets/audio/music/name2.mp3
    
    # Sound path
    - assets/audio/sound/sound.mp3
```

Initialize the plugin:

``` dart
await AudioHelper.initial(
    backgroundMusicNames: ['name1.mp3','name2.mp3'],
);

```

Play & stop background music:

``` dart
/// Play
AudioHelper.playMusic();

/// Stop
AudioHelper.stopMusic();
```

Play sound:

``` dart
AudioHelper.playSound('sound.mp3');
```
