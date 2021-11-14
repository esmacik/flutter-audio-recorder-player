import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';

/// Custom wrapper for `FlutterSoundPlayer` to abstract some API boiler plate code.
class SoundPlayer {

  /// Save file name of audio to play.
  final String _path = 'my_recording.aac';
  FlutterSoundPlayer? _audioPlayer;

  bool get isPlaying => _audioPlayer!.isPlaying;
  FlutterSoundPlayer get getPlayer => _audioPlayer!;

  /// Adjust the playback speed of the audio player. This can be adjusted in real time.
  void setPlaybackSpeed(double playbackSpeed) {
    _audioPlayer!.setSpeed(playbackSpeed);
  }

  /// Adjust the playback volume of the audio player. This can be adjusted in real time.
  void setPlaybackVolume(double playbackVolume) {
    _audioPlayer!.setVolume(playbackVolume);
  }

  /// Initialize the player and open the sound session.
  Future<void> init() async {
    _audioPlayer = FlutterSoundPlayer();
    await _audioPlayer!.openAudioSession();
  }

  /// Free audio player resources when finished.
  Future<void> dispose() async {
    _audioPlayer!.closeAudioSession();
    _audioPlayer = null;
  }

  /// Play the audio from the file path, and set up UI updates every 1 millisecond.
  Future<void> _play(VoidCallback whenFinished) async {
    _audioPlayer!.setSubscriptionDuration(Duration(milliseconds: 1));
    await _audioPlayer!.startPlayer(
      fromURI: _path,
      whenFinished: whenFinished
    );
  }

  /// Reset the player to the beginning of the file.
  Future<void> stop() async {
    await _audioPlayer!.stopPlayer();
  }

  /// If the player is stopped, play the audio. Pause if it is playing. Resume if it is paused.
  Future<void> togglePlaying({required VoidCallback whenFinished}) async {
    if (_audioPlayer!.isStopped) {
      await _play(whenFinished);
    } else if (_audioPlayer!.isPlaying) {
      _audioPlayer!.pausePlayer();
    } else if (!_audioPlayer!.isPlaying) {
      _audioPlayer!.resumePlayer();
    }
  }
}