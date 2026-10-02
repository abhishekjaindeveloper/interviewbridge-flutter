import 'package:speech_to_text/speech_to_text.dart';

/// Interface for speech-to-text recognition service to allow seamless
/// integration with AnswerInputWidget and deterministic testing.
abstract class SpeechRecognitionService {
  bool get isListening;
  bool get isAvailable;

  Future<bool> initialize({
    void Function(String errorMsg)? onError,
    void Function(String status)? onStatus,
  });

  Future<void> listen({
    required void Function(String words, bool isFinal) onResult,
    Duration? listenFor,
    Duration? pauseFor,
  });

  Future<void> stop();
  Future<void> cancel();
  void dispose();
}

/// Default implementation using the speech_to_text package.
class DefaultSpeechRecognitionService implements SpeechRecognitionService {
  final SpeechToText _speech;
  bool _isAvailable = false;

  DefaultSpeechRecognitionService({SpeechToText? speechToText})
      : _speech = speechToText ?? SpeechToText();

  @override
  bool get isListening => _speech.isListening;

  @override
  bool get isAvailable => _isAvailable;

  @override
  Future<bool> initialize({
    void Function(String errorMsg)? onError,
    void Function(String status)? onStatus,
  }) async {
    try {
      _isAvailable = await _speech.initialize(
        onError: (errorNotification) {
          onError?.call(errorNotification.errorMsg);
        },
        onStatus: (status) {
          onStatus?.call(status);
        },
      );
      return _isAvailable;
    } catch (e) {
      _isAvailable = false;
      onError?.call(e.toString());
      return false;
    }
  }

  @override
  Future<void> listen({
    required void Function(String words, bool isFinal) onResult,
    Duration? listenFor,
    Duration? pauseFor,
  }) async {
    if (!_isAvailable) {
      final initialized = await initialize();
      if (!initialized) return;
    }

    try {
      await _speech.listen(
        onResult: (result) {
          onResult(result.recognizedWords, result.finalResult);
        },
        listenOptions: SpeechListenOptions(
          listenMode: ListenMode.dictation,
          cancelOnError: false,
          partialResults: true,
        ),
      );
    } catch (e) {
      // Handle any unexpected runtime exception cleanly
    }
  }

  @override
  Future<void> stop() async {
    try {
      if (_speech.isListening) {
        await _speech.stop();
      }
    } catch (_) {}
  }

  @override
  Future<void> cancel() async {
    try {
      if (_speech.isListening) {
        await _speech.cancel();
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    try {
      if (_speech.isListening) {
        _speech.cancel();
      }
    } catch (_) {}
  }
}
