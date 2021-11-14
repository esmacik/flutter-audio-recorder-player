import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:core';

/// Custom wrapper for `FlutterSoundRecorder` to abstract some boiler plate code.
class SoundRecorder {

  /// Save file name of audio to play.
  final String _path = 'my_recording.aac';
  bool _isRecorderInitialized = false;
  FlutterSoundRecorder? _audioRecorder;

  bool get isRecording => _audioRecorder!.isRecording;

  /// Initialize the recorder and open the sound session. Request mic access if needed.
  Future<void> init() async {
    _audioRecorder = FlutterSoundRecorder();

    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Mic permission denied ):');
    }

    await _audioRecorder!.openAudioSession();
    _isRecorderInitialized = true;
  }

  /// Free microphone resources when finished.
  Future<void> dispose() async {
    _audioRecorder = FlutterSoundRecorder();
    await _audioRecorder!.closeAudioSession();
    _isRecorderInitialized = false;
  }

  /// Begin recording if the recording has not started, and stop if it has started.
  Future<void> toggleRecording() async {
    if (_audioRecorder!.isStopped) {
      await _record();
    } else {
      await _stop();
    }
  }

  /// Begin recording audio.
  Future<void> _record() async {
    if (!_isRecorderInitialized) return;
    await _audioRecorder!.startRecorder(toFile: _path);
  }

  /// Complete recording audio.
  Future<void> _stop() async {
    if (!_isRecorderInitialized) return;
    await _audioRecorder!.stopRecorder();
  }
}