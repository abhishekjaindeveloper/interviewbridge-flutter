import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interview_bridge_app/core/constants/app_constants.dart';
import 'package:interview_bridge_app/features/question/presentation/services/speech_recognition_service.dart';
import 'package:interview_bridge_app/features/question/presentation/widgets/answer_input_widget.dart';

class FakeSpeechRecognitionService implements SpeechRecognitionService {
  bool _isListening = false;
  bool isAvailableValue = true;
  void Function(String words, bool isFinal)? onResultCallback;
  void Function(String errorMsg)? onErrorCallback;
  void Function(String status)? onStatusCallback;
  int stopCallCount = 0;
  int cancelCallCount = 0;
  int disposeCallCount = 0;
  int listenCallCount = 0;

  @override
  bool get isListening => _isListening;

  @override
  bool get isAvailable => isAvailableValue;

  @override
  Future<bool> initialize({
    void Function(String errorMsg)? onError,
    void Function(String status)? onStatus,
  }) async {
    onErrorCallback = onError;
    onStatusCallback = onStatus;
    return isAvailableValue;
  }

  @override
  Future<void> listen({
    required void Function(String words, bool isFinal) onResult,
    Duration? listenFor,
    Duration? pauseFor,
  }) async {
    _isListening = true;
    listenCallCount++;
    onResultCallback = onResult;
  }

  @override
  Future<void> stop() async {
    _isListening = false;
    stopCallCount++;
    onStatusCallback?.call('notListening');
  }

  @override
  Future<void> cancel() async {
    _isListening = false;
    cancelCallCount++;
  }

  @override
  void dispose() {
    _isListening = false;
    disposeCallCount++;
  }

  void emitResult(String words, bool isFinal) {
    onResultCallback?.call(words, isFinal);
  }

  void emitError(String errorMsg) {
    _isListening = false;
    onErrorCallback?.call(errorMsg);
  }

  void emitStatus(String status) {
    onStatusCallback?.call(status);
  }
}

void main() {
  late TextEditingController controller;
  late FakeSpeechRecognitionService fakeSpeech;

  setUp(() {
    controller = TextEditingController();
    fakeSpeech = FakeSpeechRecognitionService();
  });

  tearDown(() {
    controller.dispose();
  });

  Widget buildWidget({
    bool enabled = true,
    String? errorText,
    String? questionId = 'q1',
  }) {
    return MaterialApp(
      home: Scaffold(
        body: AnswerInputWidget(
          controller: controller,
          enabled: enabled,
          errorText: errorText,
          questionId: questionId,
          speechService: fakeSpeech,
        ),
      ),
    );
  }

  testWidgets('A: AnswerInputWidget still accepts normal typed text', (tester) async {
    await tester.pumpWidget(buildWidget());

    expect(find.byType(TextField), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Manual typed answer');
    await tester.pump();

    expect(controller.text, equals('Manual typed answer'));
  });

  testWidgets('B & C: Microphone control renders in idle state with start action', (tester) async {
    await tester.pumpWidget(buildWidget());

    final micButton = find.byKey(const ValueKey('voice_input_microphone_button'));
    expect(micButton, findsOneWidget);
    expect(find.byIcon(Icons.mic_rounded), findsOneWidget);
    expect(find.byTooltip(AppConstants.startVoiceInputTitle), findsOneWidget);
  });

  testWidgets('D: Tapping mic enters listening state with stop icon and status indicator', (tester) async {
    await tester.pumpWidget(buildWidget());

    final micButton = find.byKey(const ValueKey('voice_input_microphone_button'));
    await tester.tap(micButton);
    await tester.pump();

    expect(fakeSpeech.listenCallCount, equals(1));
    expect(find.byIcon(Icons.stop_circle_rounded), findsOneWidget);
    expect(find.byTooltip(AppConstants.stopVoiceInputTitle), findsOneWidget);
    expect(find.text(AppConstants.listeningVoiceInputStatus), findsOneWidget);
  });

  testWidgets('E: Speech result is inserted into the empty answer field', (tester) async {
    await tester.pumpWidget(buildWidget());

    final micButton = find.byKey(const ValueKey('voice_input_microphone_button'));
    await tester.tap(micButton);
    await tester.pump();

    fakeSpeech.emitResult('Java is an object oriented language', true);
    await tester.pump();

    expect(controller.text, equals('Java is an object oriented language'));
  });

  testWidgets('F: Existing answer text is preserved when speech text is added', (tester) async {
    controller.text = 'Polymorphism allows';
    await tester.pumpWidget(buildWidget());

    final micButton = find.byKey(const ValueKey('voice_input_microphone_button'));
    await tester.tap(micButton);
    await tester.pump();

    fakeSpeech.emitResult('multiple implementations', true);
    await tester.pump();

    expect(controller.text, equals('Polymorphism allows multiple implementations'));
  });

  testWidgets('G & H: Partial speech results do not duplicate text and final result commits correctly', (tester) async {
    controller.text = 'Initial answer';
    await tester.pumpWidget(buildWidget());

    final micButton = find.byKey(const ValueKey('voice_input_microphone_button'));
    await tester.tap(micButton);
    await tester.pump();

    // Partial 1
    fakeSpeech.emitResult('Java is', false);
    await tester.pump();
    expect(controller.text, equals('Initial answer Java is'));

    // Partial 2 (cumulative in speech_to_text)
    fakeSpeech.emitResult('Java is an object', false);
    await tester.pump();
    expect(controller.text, equals('Initial answer Java is an object'));

    // Final result
    fakeSpeech.emitResult('Java is an object oriented language', true);
    await tester.pump();
    expect(controller.text, equals('Initial answer Java is an object oriented language'));
  });

  testWidgets('I: Empty speech result does not overwrite existing answer', (tester) async {
    controller.text = 'Existing text';
    await tester.pumpWidget(buildWidget());

    final micButton = find.byKey(const ValueKey('voice_input_microphone_button'));
    await tester.tap(micButton);
    await tester.pump();

    fakeSpeech.emitResult('', false);
    await tester.pump();
    expect(controller.text, equals('Existing text'));

    fakeSpeech.emitResult('   ', false);
    await tester.pump();
    expect(controller.text, equals('Existing text'));
  });

  testWidgets('J: Tapping stop while listening halts speech and returns to idle state', (tester) async {
    await tester.pumpWidget(buildWidget());

    final micButton = find.byKey(const ValueKey('voice_input_microphone_button'));
    await tester.tap(micButton);
    await tester.pump();
    expect(find.byIcon(Icons.stop_circle_rounded), findsOneWidget);

    // Tap stop
    await tester.tap(micButton);
    await tester.pump();

    expect(fakeSpeech.stopCallCount, equals(1));
    expect(find.byIcon(Icons.mic_rounded), findsOneWidget);
    expect(find.text(AppConstants.listeningVoiceInputStatus), findsNothing);
  });

  testWidgets('K: Moving to another question stops and resets speech state', (tester) async {
    await tester.pumpWidget(buildWidget(questionId: 'q1'));

    final micButton = find.byKey(const ValueKey('voice_input_microphone_button'));
    await tester.tap(micButton);
    await tester.pump();
    expect(find.byIcon(Icons.stop_circle_rounded), findsOneWidget);

    // Widget updates with new questionId
    await tester.pumpWidget(buildWidget(questionId: 'q2'));
    await tester.pump();

    expect(find.byIcon(Icons.mic_rounded), findsOneWidget);
    expect(find.text(AppConstants.listeningVoiceInputStatus), findsNothing);
  });

  testWidgets('L: Widget disposal cleans up speech recognition', (tester) async {
    await tester.pumpWidget(buildWidget());

    final micButton = find.byKey(const ValueKey('voice_input_microphone_button'));
    await tester.tap(micButton);
    await tester.pump();

    // Pump a different widget to dispose AnswerInputWidget
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: SizedBox())));

    expect(fakeSpeech.disposeCallCount, equals(1));
  });

  testWidgets('M: Speech recognition error does not crash and shows user-friendly message', (tester) async {
    await tester.pumpWidget(buildWidget());

    final micButton = find.byKey(const ValueKey('voice_input_microphone_button'));
    await tester.tap(micButton);
    await tester.pump();

    // Emit permission denied error
    fakeSpeech.emitError('permission denied by user');
    await tester.pump();

    expect(find.text(AppConstants.microphonePermissionDeniedMessage), findsOneWidget);
    expect(find.byIcon(Icons.mic_rounded), findsOneWidget);

    // User can still type normally
    await tester.enterText(find.byType(TextField), 'Typed despite error');
    await tester.pump();
    expect(controller.text, equals('Typed despite error'));
  });

  testWidgets('Unavailable speech recognition shows unavailable message', (tester) async {
    fakeSpeech.isAvailableValue = false;
    await tester.pumpWidget(buildWidget());

    final micButton = find.byKey(const ValueKey('voice_input_microphone_button'));
    await tester.tap(micButton);
    await tester.pump();

    expect(find.text(AppConstants.speechRecognitionUnavailableMessage), findsOneWidget);
    expect(find.byIcon(Icons.mic_rounded), findsOneWidget);
  });
}
