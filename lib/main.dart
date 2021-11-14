import 'package:flutter/material.dart';
import 'package:grad_demo/sound_player.dart';
import 'package:grad_demo/sound_recorder.dart';

/// Main entry point of application.
main() {
  runApp(const AudioApp());
}

/// The main Audio Material App.
class AudioApp extends StatelessWidget {
  const AudioApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark
      ),
      home: const AudioScreen()
    );
  }
}

/// The main screen of the application that allows recording and playing audio.
class AudioScreen extends StatefulWidget {
  const AudioScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AudioScreenState();
}

/// State of the audio recorder app.
class _AudioScreenState extends State<AudioScreen> {

  final SoundRecorder _soundRecorder = SoundRecorder();
  final SoundPlayer _soundPlayer = SoundPlayer();

  bool get _isRecording => _soundRecorder.isRecording;
  bool get _isPlaying =>  _soundPlayer.isPlaying;

  double _playbackSpeed = 1.0;
  double _playbackVolume = 1.0;
  String _playbackProgressText = '';
  double _playbackProgress = 0.0;

  /// Initialize the audio recorder and sound recorder.
  @override
  void initState() {
    super.initState();
    _soundRecorder.init();
    _soundPlayer.init();
  }

  /// Dispose of the audio and sound recorder when not needed to free resources.
  @override
  void dispose() {
    _soundPlayer.dispose();
    _soundRecorder.dispose();
    super.dispose();
  }

  /// Create the main screen of the app.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.mic),
        title: const Text('Audio Recorder and Player'),
      ),
      body: ListView(
        children: [

          // Record button that allows starting and stopping a recording.
          ElevatedButton.icon(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(_isRecording ? Colors.red : Colors.green)
            ),
            label: Text(_isRecording ? 'STOP' : 'RECORD'),
            icon: Icon(_isRecording ? Icons.stop : Icons.mic),
            onPressed: () async {
              await _soundRecorder.toggleRecording();
              setState(() {});
            },
          ),

          // Display playback progress
          Center(
            child: Text(
              _playbackProgressText,
              style: const TextStyle(
                fontSize: 48
              ),
            )
          ),
          LinearProgressIndicator(
            value: _playbackProgress,
          ),

          // Show stop playback button and play/pause button.
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () =>  setState(() {
                    _soundPlayer.stop();
                    _playbackProgressText = Duration().toString();
                    _playbackProgress = 0;
                  }),
                  icon: const Icon(Icons.stop),
                  label: const Text('Stop audio')
                ),
              ),
              Expanded(
                child: ElevatedButton.icon(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(_isPlaying ? Colors.green : Colors.blue)
                  ),
                  icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                  label: Text(_isPlaying ? 'Pause audio!' : 'Play audio!'),
                  onPressed: () async {

                    // Update the progress text and linear progress bar every 1 millisecond.
                    _soundPlayer.getPlayer.onProgress!.listen((event) {
                      setState(() {
                        _playbackProgressText = event.position.toString();
                        _playbackProgress = event.position.inMilliseconds / event.duration.inMilliseconds;
                      });
                    });

                    // Start playing, and reset UI when done.
                    await _soundPlayer.togglePlaying(whenFinished: () => setState(() {
                      _playbackProgressText = Duration().toString();
                      _playbackProgress = 0.0;
                    }));
                    setState(() {});
                  },
                ),
              ),
            ],
          ),

          // Slider to adjust playback speed of audio when playing.
          const Center(child: Text('Adjust playback speed')),
          Row(
            children: [
              const Text('0.5x'),
              Expanded(
                child: Slider(
                  divisions: 6,
                  min: 0.5,
                  max: 2.0,
                  value: _playbackSpeed,
                  label: "${_playbackSpeed.toString()}x",
                  onChanged: (value) => setState(() {

                    // Update the speed of the player behind the scenes.
                    _playbackSpeed = value;
                    _soundPlayer.setPlaybackSpeed(_playbackSpeed);
                  }),
                ),
              ),
              const Text('2.0x'),
            ]
          ),

          // Slider to adjust the playback volume when playing.
          const Center(child: Text('Adjust playback volume')),
          Row(
            children: [
              const Text('0%'),
              Expanded(
                child: Slider(
                  divisions: 10,
                  value: _playbackVolume,
                  label: '${(_playbackVolume*100).round().toString()}%',
                  onChanged: (value) => setState(() {

                    // Update the volume of the player behind the scenes.
                    _playbackVolume = value;
                    _soundPlayer.setPlaybackVolume(_playbackVolume);
                  })
                ),
              ),
              const Text('100%'),
            ],
          )
        ],
      ),
    );
  }
}
