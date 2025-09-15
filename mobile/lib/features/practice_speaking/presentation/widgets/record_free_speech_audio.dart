import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:lissan_ai/core/utils/constants/practice_speaking_constants.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';

import 'package:lissan_ai/features/practice_speaking/presentation/widgets/animated_audio.dart';


enum ConversationState { idle, connected, listening, processing, speaking }

class RecordFreeSpeechAudio extends StatefulWidget {
  const RecordFreeSpeechAudio({super.key});

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
  static const double _silenceThresholdDb = -20.0;
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
    _sessionTimer?.cancel();
    _silenceTimer?.cancel();
    _aiAnimationTimer?.cancel();
    _audioSubscription?.cancel();
    _amplitudeSubscription?.cancel();
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

  

  void _startSession() {
    if (_isSessionActive) return;
    _log('--- SESSION STARTED ---');
    _isSessionActive = true;

    _sessionTimer = Timer(_maxSessionDuration, () {
      _log('--- SESSION TIMEOUT: 3 minutes reached ---');
      _endSession(timeout: true);
    });

    
    _startRecording();
  }

  void _endSession({bool timeout = false}) {
    if (!_isSessionActive) return;
    _log('--- SESSION ENDED ---');

    _sessionTimer?.cancel();
    if (_isRecording) {
      _stopRecording(isSessionEnding: true);
    }
    _isSessionActive = false;

    setState(() {
      if (timeout) {
        _statusText = 'Session ended (3 min timeout)';
      } else {
        _statusText = 'Session Ended';
      }
      _currentState = ConversationState.idle; 
    });
  }

  

  Future<void> _initializeWebSocket() async {
    _log(
      'Attempting to connect to WebSocket: ${PracticeSpeakingConstants.webSocketUrl}',
    );
    try {
      _channel = WebSocketChannel.connect(
        Uri.parse(PracticeSpeakingConstants.webSocketUrl),
      );
      await _channel!.ready; 
      _log('✅ WebSocket connection established. Listening to stream...');

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
            '❌ [WebSocket onDone]: Connection closed. Code: ${_channel?.closeCode}',
          );
          if (_isSessionActive) { 
            _setStatus('Disconnected. Tap to reconnect.', ConversationState.idle);
            _endSession();
          }
        },
        onError: (error) {
          _log('❌ [WebSocket onError]: $error');
          if (_isSessionActive) {
            _setStatus('Error. Tap to reconnect.', ConversationState.idle);
            _endSession();
          }
        },
      );
      _setStatus('Tap to Speak', ConversationState.connected);
    } catch (e) {
      _log('❌ [WebSocket EXCEPTION]: Failed to connect: $e');
      _setStatus('Connection Error', ConversationState.idle);
    }
  }


  Future<void> _playAudio(Uint8List audioBytes) async {
    _setStatus('AI Speaking...', ConversationState.speaking);
    _aiAnimationTimer?.cancel();
    _aiAnimationTimer = Timer.periodic(const Duration(milliseconds: 100), (
      timer,
    ) {
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
      await _audioPlayer.play();
      _log('Playing AI audio...');

      _audioPlayer.playerStateStream.listen((playerState) {
        if (playerState.processingState == ProcessingState.completed) {
          _aiAnimationTimer?.cancel();

          if (_isSessionActive) {
            _log('AI finished speaking. Automatically starting to listen for user.');
            _startRecording();
          } else {
            _log('AI finished, session is inactive.');
            _setStatus('Session Ended', ConversationState.idle);
          }
        }
      });
    } catch (e) {
      _log('Error playing audio: $e');
      _aiAnimationTimer?.cancel();
      if (_isSessionActive) {
        _startRecording();
      }
    }
  }
  

  Future<void> _startRecording() async {
    _log('Attempting to start recording...');
    if (_isRecording) return;
    if (_channel == null || _channel?.closeCode != null) {
      _log('...channel is null or closed, trying to reconnect.');
      await _initializeWebSocket();
      if (_channel == null) {
        _log('...reconnection failed. Aborting recording.');
        return;
      }
    }

    if (await Permission.microphone.request().isDenied) {
      _log('...permission denied. Aborting.');
      _setStatus('Microphone permission needed', ConversationState.idle);
      return;
    }

    try {
      _isRecording = true;
      _setStatus('Listening...', ConversationState.listening);

      final audioStream = await _audioRecorder.startStream(
        const RecordConfig(sampleRate: 16000, numChannels: 1),
      );

      _audioSubscription = audioStream.listen(
        (audioChunk) {
          _channel?.sink.add(audioChunk);
        },
        onError: (err) {
          _log('Audio stream error: $err');
          _stopRecording();
        },
      );

      _amplitudeSubscription = _audioRecorder
          .onAmplitudeChanged(const Duration(milliseconds: 160))
          .listen((amp) {
        if (!mounted) return;
        final volume = amp.current;
        final minDb = -60.0;
        final normalized = (volume.clamp(minDb, 0.0) - minDb) / (0.0 - minDb);
        setState(() => _currentVolume = normalized);

        if (volume > _silenceThresholdDb) {
          _resetSilenceTimer();
        }
      });

      _startSilenceTimer();
    } catch (e) {
      _log('❌ Error starting recording: $e');
      _setStatus('Recording Error', ConversationState.connected);
      _isRecording = false;
    }
  }

  void _stopRecording({bool isSessionEnding = false}) {
    if (!_isRecording) return;
    _log('Attempting to stop recording TURN...');
    _isRecording = false;
    _audioRecorder.stop();
    _audioSubscription?.cancel();
    _amplitudeSubscription?.cancel();
    _silenceTimer?.cancel();

    
    if (_isSessionActive && !isSessionEnding) {
      _setStatus('Processing...', ConversationState.processing);
    }
    _log('✅ Stopped listening TURN.');
  }

  void _sendEndOfSpeechSignal() {
    _log("🤫 Silence/Manual stop detected. Sending 'end_of_speech'.");
    if (_channel?.sink != null) {
      _channel!.sink.add(jsonEncode({'type': 'end_of_speech'}));
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
        _log('🤫 Silence detected after speech.');
        _sendEndOfSpeechSignal();
      }
    });
  }

  
  void _handleMicTap() {
    switch (_currentState) {
      case ConversationState.idle:
      case ConversationState.connected:
        
        
        if (!_isSessionActive) {
          _startSession();
        } else {
          _startRecording();
        }
        break;
      case ConversationState.listening:
        
        _sendEndOfSpeechSignal();
        break;
      case ConversationState.processing:
      case ConversationState.speaking:
        
        _log('Ignoring tap while state is $_currentState');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    
    
    final bool isMicActive = _currentState == ConversationState.listening;
    final bool canTapMic = _currentState == ConversationState.connected ||
        _currentState == ConversationState.listening ||
        _currentState == ConversationState.idle;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 32),
            AnimatedAudioBlob(
              state: _currentState,
              volume: _currentVolume,
              onTap: () {
                
                if (_currentState == ConversationState.listening) {
                  _sendEndOfSpeechSignal();
                }
              },
            ),
            const SizedBox(height: 20),
            
            Text(
              _statusText,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.black12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            
            IconButton(
              onPressed: () {
                _endSession();
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.close, size: 32, color: Colors.red),
            ),

            GestureDetector(
              onTap: _handleMicTap, 
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isMicActive
                      ? Colors.green
                      : (canTapMic ? Colors.blue : Colors.grey[400]),
                  boxShadow: [
                    BoxShadow(
                      color: (isMicActive
                              ? Colors.green
                              : (canTapMic ? Colors.blue : Colors.grey))
                          .withOpacity(0.4),
                      blurRadius: 12,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Icon(
                  isMicActive ? Icons.mic : Icons.mic_none,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            ),
            
          ],
        ),
      ),
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