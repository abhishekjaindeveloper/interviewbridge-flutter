// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/constants/app_constants.dart';
import '../services/speech_recognition_service.dart';

class AnswerInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final bool enabled;
  final String? errorText;
  final String? questionId;
  final SpeechRecognitionService? speechService;

  const AnswerInputWidget({
    super.key,
    required this.controller,
    required this.enabled,
    this.errorText,
    this.questionId,
    this.speechService,
  });

  @override
  State<AnswerInputWidget> createState() => _AnswerInputWidgetState();
}

class _AnswerInputWidgetState extends State<AnswerInputWidget> {
  late final SpeechRecognitionService _speechService;
  bool _isListening = false;
  bool _isInitialized = false;
  String _baseText = '';
  String? _speechError;

  @override
  void initState() {
    super.initState();
    _speechService = widget.speechService ?? DefaultSpeechRecognitionService();
  }

  @override
  void didUpdateWidget(covariant AnswerInputWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.questionId != widget.questionId) {
      _stopListeningSync();
      _speechError = null;
    }
  }

  @override
  void dispose() {
    _speechService.dispose();
    super.dispose();
  }

  void _stopListeningSync() {
    if (_isListening) {
      _speechService.stop();
      _isListening = false;
      _baseText = widget.controller.text;
    }
  }

  void _handleSpeechError(String errorMsg) {
    if (!mounted) return;
    setState(() {
      _isListening = false;
      if (errorMsg.toLowerCase().contains('denied') ||
          errorMsg.toLowerCase().contains('permission')) {
        _speechError = AppConstants.microphonePermissionDeniedMessage;
      } else {
        _speechError = AppConstants.speechRecognitionErrorMessage;
      }
    });
  }

  void _handleSpeechStatus(String status) {
    if (!mounted) return;
    if (status == 'done' || status == 'notListening') {
      setState(() {
        _isListening = false;
        _baseText = widget.controller.text;
      });
    }
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speechService.stop();
      if (mounted) {
        setState(() {
          _isListening = false;
          _baseText = widget.controller.text;
        });
      }
      return;
    }

    setState(() {
      _speechError = null;
    });

    if (!_isInitialized) {
      final available = await _speechService.initialize(
        onError: _handleSpeechError,
        onStatus: _handleSpeechStatus,
      );
      _isInitialized = true;

      if (!available) {
        if (mounted) {
          setState(() {
            _speechError = AppConstants.speechRecognitionUnavailableMessage;
            _isListening = false;
          });
        }
        return;
      }
    }

    _baseText = widget.controller.text.trimRight();
    setState(() {
      _isListening = true;
    });

    await _speechService.listen(
      onResult: (words, isFinal) {
        if (!mounted) return;
        final recognized = words.trim();
        if (recognized.isEmpty) return;

        final prefix = _baseText.isEmpty ? '' : '$_baseText ';
        final newText = '$prefix$recognized';

        widget.controller.value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: newText.length),
        );

        if (isFinal) {
          _baseText = widget.controller.text;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null || _speechError != null;
    final displayError = widget.errorText ?? _speechError;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
            border: Border.all(
              color: hasError
                  ? AppColors.error
                  : (_isListening
                      ? AppColors.primary
                      : AppColors.border.withOpacity(AppDimensions.opacityBorder)),
              width: (_isListening || hasError) ? 1.5 : 1.0,
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: widget.controller,
                maxLines: 8,
                minLines: 4,
                enabled: widget.enabled,
                maxLength: 5000,
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: AppConstants.answerInputPlaceholder,
                  hintStyle: TextStyle(color: AppColors.textSecondary),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  counterText: '',
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Divider(
                color: AppColors.border.withOpacity(0.5),
                height: 1,
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_isListening)
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          AppConstants.listeningVoiceInputStatus,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.error,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                  else
                    const SizedBox.shrink(),
                  IconButton(
                    key: const ValueKey('voice_input_microphone_button'),
                    icon: Icon(
                      _isListening ? Icons.stop_circle_rounded : Icons.mic_rounded,
                      color: _isListening
                          ? AppColors.error
                          : (widget.enabled ? AppColors.primary : AppColors.textSecondary),
                      size: 24,
                    ),
                    tooltip: _isListening
                        ? AppConstants.stopVoiceInputTitle
                        : AppConstants.startVoiceInputTitle,
                    onPressed: widget.enabled ? _toggleListening : null,
                  ),
                ],
              ),
            ],
          ),
        ),
        if (displayError != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Text(
              displayError,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.error,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ],
    );
  }
}