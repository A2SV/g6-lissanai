import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';

import 'package:lissan_ai/features/practice_speaking/presentation/widgets/animated_audio.dart';

enum ConversationState { idle, connected, listening, processing, speaking }

class RecordFreeSpeechAudio extends StatefulWidget {
  final String websocketUrl;

  const RecordFreeSpeechAudio({super.key, required this.websocketUrl});

  @override
  State<RecordFreeSpeechAudio> createState() => _RecordFreeSpeechAudioState();
}

class _RecordFreeSpeechAudioState extends State<RecordFreeSpeechAudio> {
  WebSocketChannel? _channel;
  final AudioPlayer _audioPlayer = AudioPlayer();
  StreamSubscription? _audioSubscription;
  StreamSubscription? _amplitudeSubscription;
  final AudioRecorder _audioRecorder = AudioRecorder();

  ConversationState _currentState = ConversationState.idle;
  String _statusText = 'Tap to Speak';
  bool _isRecording = false;

  double _currentVolume = 0.0;
  Timer? _aiAnimationTimer;
  final Random _random = Random();
  static const double _silenceThresholdDb = -10.0;
  static const Duration _maxSessionDuration = Duration(minutes: 3);

  bool _isSessionActive = false;
  Timer? _sessionTimer;
  Timer? _silenceTimer;

  @override
  void initState() {
    super.initState();
    _log('--- Widget Initializing ---');
    _initializeWebSocket();
  }

  @override
  void dispose() {
    _log('--- Widget Disposing ---');
    _silenceTimer?.cancel();
    _aiAnimationTimer?.cancel();
    _audioSubscription?.cancel();
    _channel?.sink.close();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _log(String message) {
    print('[LOG] ${DateTime.now().toIso8601String()}: $message');
  }

  void _setStatus(String text, ConversationState state) {
    if (!mounted) return;
    _log("Setting status: '$text', State: $state");
    setState(() {
      _statusText = text;
      _currentState = state;
      if (state != ConversationState.listening &&
          state != ConversationState.speaking) {
        _currentVolume = 0.0;
      }
    });
  }

  // --- NEW: Method to start the entire conversation session ---
  void _startSession() {
    if (_isSessionActive) return;
    _log("--- SESSION STARTED ---");
    setState(() {
      _isSessionActive = true;
    });

    _sessionTimer = Timer(_maxSessionDuration, () {
      _log("--- SESSION TIMEOUT: 3 minutes reached ---");
      _endSession(timeout: true);
    });

    // Start the very first turn
    _startRecording();
  }

  // --- NEW: Method to end the entire conversation session ---
  void _endSession({bool timeout = false}) {
    if (!_isSessionActive) return;
    _log("--- SESSION ENDED ---");
    
    _sessionTimer?.cancel();
    _sessionTimer = null;
    
    // Make sure we stop recording if the user ends the session while speaking
    if (_isRecording) {
      _stopRecording();
    }
    
    setState(() {
      _isSessionActive = false;
      if (timeout) {
        _statusText = "Session ended (3 min timeout)";
      } else {
        _statusText = "Session Ended";
      }
      _currentState = ConversationState.connected;
    });
  }

  Future<void> _initializeWebSocket() async {
    _log('Attempting to connect to WebSocket: ${widget.websocketUrl}');
    try {
      _channel = WebSocketChannel.connect(Uri.parse(widget.websocketUrl));
      _log('WebSocket connection object created. Listening to stream...');

      _channel!.stream.listen(
        (message) {
          if (message is String) {
            _log('✅ [WebSocket Received TEXT]: $message');
            _setStatus('Processing...', ConversationState.processing);
          } else if (message is Uint8List) {
            _log(
              '✅ [WebSocket Received AUDIO]: ${message.lengthInBytes} bytes',
            );
            _playAudio(message);
          } else {
            _log('✅ [WebSocket Received UNKNOWN TYPE]: ${message.runtimeType}');
          }
        },
        onDone: () {
          _log(
            '❌ [WebSocket onDone]: Connection closed by server. Code: ${_channel?.closeCode}, Reason: ${_channel?.closeReason}',
          );
          _setStatus('Disconnected. Tap to reconnect.', ConversationState.idle);
          _stopRecording();
          _channel = null;
        },
        onError: (error) {
          _log('❌ [WebSocket onError]: $error');
          _setStatus('Error. Tap to reconnect.', ConversationState.idle);
          _stopRecording();
          _channel = null;
        },
      );
      _setStatus('Tap to Speak', ConversationState.connected);
      _log('✅ WebSocket stream listener is active.');
    } catch (e) {
      _log('❌ [WebSocket EXCEPTION]: Failed to connect: $e');
      _setStatus('Connection Error', ConversationState.idle);
    }
  }

  Future<void> _playAudio(Uint8List audioBytes) async {
    _setStatus("AI Speaking...", ConversationState.speaking);
    _aiAnimationTimer?.cancel();
    _aiAnimationTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _currentVolume = 0.2 + _random.nextDouble() * 0.3;
      });
    });

    try {
      await _audioPlayer.setAudioSource(BytesAudioSource(audioBytes));
      _audioPlayer.play();
      _log("Playing AI audio from memory...");

      _audioPlayer.playerStateStream.listen((playerState) {
        if (playerState.processingState == ProcessingState.completed) {
          _aiAnimationTimer?.cancel();
          _audioPlayer.stop();

          // --- KEY CHANGE HERE ---
          // After AI finishes, check if the session should continue.
          if (_isSessionActive) {
            _log("AI finished, starting next turn automatically.");
            _startRecording(); // This creates the loop
          } else {
            _log("AI finished, but session is now inactive. Returning to idle.");
            _setStatus("Session Ended", ConversationState.connected);
          }
        }
      });
    } catch (e) {
      _log("Error playing audio: $e");
      _aiAnimationTimer?.cancel();
      _setStatus("Audio Error", ConversationState.connected);
    }
  }

  Future<void> _startRecording() async {
    _log('Attempting to start recording...');
    if (_isRecording) return;
    if (_channel == null) {
      _log('...channel is null, trying to reconnect.');
      await _initializeWebSocket();
      if (_channel == null) {
        _log('...reconnection failed. Aborting recording.');
        return;
      }
    }

    if (await Permission.microphone.request().isDenied) {
      _log('...permission denied. Aborting.');
      return;
    }

    try {
      if (await _audioRecorder.hasPermission()) {
        _log('...permission granted. Starting stream from recorder.');
        _isRecording = true;
        _setStatus('Listening...', ConversationState.listening);

        final audioStream = await _audioRecorder.startStream(
          const RecordConfig(sampleRate: 16000, numChannels: 1, bitRate: 48000),
        );

        _audioSubscription = audioStream.listen((audioChunk) {
          if (_channel?.sink != null && _isRecording) {
            _channel!.sink.add(audioChunk);
          }
        }, onError: (err) => _stopRecording());

        _amplitudeSubscription = _audioRecorder
            .onAmplitudeChanged(const Duration(milliseconds: 200))
            .listen((amp) {
              final volume = amp.current;

              _log(
                '🎤 Amplitude: ${volume.toStringAsFixed(2)} dB (Threshold is $_silenceThresholdDb dB)',
              );

              final minDb = -60.0;
              final normalized =
                  (volume.clamp(minDb, 0.0) - minDb) / (0.0 - minDb);
              if (mounted) setState(() => _currentVolume = normalized);

              if (volume > _silenceThresholdDb) {
                _log('... Volume is ABOVE threshold. Resetting silence timer.');
                _resetSilenceTimer();
              }
            });

        _startSilenceTimer();
      }
    } catch (e) {
      _log('❌ Error starting recording: $e');
      _setStatus('Recording Error', ConversationState.connected);
      _isRecording = false;
    }
  }

  void _stopRecording() {
    // Note: This only stops a single TURN, not the whole session.
    _log("Attempting to stop recording TURN...");
    if (!_isRecording) {
      return;
    }
    _isRecording = false;
    _audioRecorder.stop();
    _audioSubscription?.cancel();
    _amplitudeSubscription?.cancel();
    _silenceTimer?.cancel();
    _silenceTimer = null;

    // Set status to "Processing..." while waiting for AI, but only if the session is still active
    if(_isSessionActive) {
      _setStatus("Processing...", ConversationState.processing);
    }
    _log("✅ Stopped listening TURN.");
  }

  void _sendEndOfSpeechSignal() {
    _log("🤫 Silence/Manual stop detected. Sending 'end_of_speech'.");
    if (_channel?.sink != null) {
      _channel!.sink.add(jsonEncode({'type': 'end_of_speech'}));
      _log('...signal sent.');
    } else {
      _log('...could not send signal, channel is null.');
    }
    _stopRecording();
  }

  void _startSilenceTimer() {
    _silenceTimer?.cancel();
    _log('🤫 Starting 1.5s silence timer...');
    _silenceTimer = Timer(const Duration(milliseconds: 1500), () {
      if (_isRecording) {
        _log('🤫 Silence detected by initial timer.');
        _sendEndOfSpeechSignal();
      }
    });
  }

  void _resetSilenceTimer() {
    _silenceTimer?.cancel();

    _silenceTimer = Timer(const Duration(milliseconds: 2000), () {
      if (_isRecording) {
        _log('🤫 Silence detected by timer.');
        _sendEndOfSpeechSignal();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 32),
        Text(
          _statusText,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 64),

        // Show the blob and End button ONLY when a session is active
        if (_isSessionActive) ...[
          AnimatedAudioBlob(
            state: _currentState,
            volume: _currentVolume,
            onTap: () {
              // The blob's only job during a session is to manually end a turn
              if (_currentState == ConversationState.listening) {
                _sendEndOfSpeechSignal(); 
              }
            },
          ),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: _endSession,
            icon: const Icon(Icons.stop_circle_outlined),
            label: const Text("End Session"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700]),
          ),
        ] 
        // Show the Start button ONLY when no session is active
        else ...[
          // Using a simple button to start. You could also use the blob.
          SizedBox(
            width: 150,
            height: 150,
            child: ElevatedButton(
              onPressed: _startSession,
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(20),
                backgroundColor: Colors.blue,
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_arrow, size: 60),
                  Text("Start"),
                ],
              ),
            ),
          ),
          const SizedBox(height: 96), // Space to keep layout consistent
        ],
      ],
    );
  }
}

class BytesAudioSource extends StreamAudioSource {
  final Uint8List _buffer;

  BytesAudioSource(this._buffer) : super(tag: 'BytesAudioSource');

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    final startVal = start ?? 0;
    final endVal = end ?? _buffer.length;
    return StreamAudioResponse(
      sourceLength: _buffer.length,
      contentLength: endVal - startVal,
      offset: startVal,
      stream: Stream.value(_buffer.sublist(startVal, endVal)),

      contentType: 'audio/aac',
    );
  }
}
