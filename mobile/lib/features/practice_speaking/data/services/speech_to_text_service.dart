// data/services/speech_to_text_service.dart
import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechToTextService {
  final stt.SpeechToText _speechToText = stt.SpeechToText();

  final _recognizedWordsController = StreamController<String>.broadcast();
  final _errorController = StreamController<String>.broadcast();
  final _statusController = StreamController<SpeechRecognizerState>.broadcast();

  Stream<String> get recognizedWordsStream => _recognizedWordsController.stream;
  Stream<String> get errorStream => _errorController.stream;
  Stream<SpeechRecognizerState> get statusStream => _statusController.stream;

  bool _isInitialized = false;

  Future<void> init() async {
    _isInitialized = await _speechToText.initialize(
      onError: (error) {
        _errorController.add(error.errorMsg);
        _statusController.add(SpeechRecognizerState.error);
      },
      onStatus: (status) {
        if (status == 'listening') {
          _statusController.add(SpeechRecognizerState.listening);
        } else if (status == 'done') {
          _statusController.add(SpeechRecognizerState.done);
        }
      },
    );
    _statusController.add(_isInitialized
        ? SpeechRecognizerState.ready
        : SpeechRecognizerState.error);
  }

  Future<void> startListening() async {
    if (!_isInitialized) {
      _errorController.add('Speech recognition not initialized.');
      return;
    }
    await _speechToText.listen(
      onResult: (result) {
        _recognizedWordsController.add(result.recognizedWords);
      },
      listenFor: const Duration(minutes: 2),
      pauseFor: const Duration(seconds: 25),
      localeId: (await _speechToText.systemLocale())?.localeId ?? 'en_US',
    );
  }


  Future<void> stopListening() async {
    await _speechToText.stop();
    _statusController.add(SpeechRecognizerState.stopped);
  }

  Future<void> cancelListening() async {
    await _speechToText.cancel();
    _statusController.add(SpeechRecognizerState.stopped);
  }

  void dispose() {
    _recognizedWordsController.close();
    _errorController.close();
    _statusController.close();
  }
}

enum SpeechRecognizerState { ready, listening, stopped, done, error }
