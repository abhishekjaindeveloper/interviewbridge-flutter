// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/routes/route_constants.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../bloc/question_bloc.dart';
import '../bloc/question_event.dart';
import '../bloc/question_state.dart';
import '../widgets/question_progress_widget.dart';
import '../widgets/question_status_chip_widget.dart';
import '../widgets/answer_input_widget.dart';

class QuestionPage extends StatefulWidget {
  final String sessionId;

  const QuestionPage({
    super.key,
    required this.sessionId,
  });

  @override
  State<QuestionPage> createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  final TextEditingController _answerController = TextEditingController();
  final Map<int, String> _draftAnswers = {};
  int _lastIndex = -1;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    context.read<QuestionBloc>().add(LoadSessionQuestionsRequested(widget.sessionId));
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  void _onSubmitPressed(String questionId) {
    final answerText = _answerController.text.trim();
    if (answerText.isEmpty) {
      setState(() {
        _validationError = AppConstants.answerRequiredMsg;
      });
      return;
    }

    if (answerText.length > 5000) {
      setState(() {
        _validationError = AppConstants.answerTooLongMsg;
      });
      return;
    }
    
    setState(() {
      _validationError = null;
    });

    context.read<QuestionBloc>().add(
          SubmitAnswerRequested(
            questionId: questionId,
            answer: answerText,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          AppConstants.questionPageTitle,
          style: AppTypography.headingMedium,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocConsumer<QuestionBloc, QuestionState>(
        listener: (context, state) {
          if (state is QuestionsLoaded) {
            if (state.currentIndex != _lastIndex) {
              // 1. Save draft for the old index (if valid and not answered)
              if (_lastIndex >= 0 && _lastIndex < state.questions.length) {
                final oldQuestion = state.questions[_lastIndex];
                final isOldAnswered = oldQuestion.questionStatus.toUpperCase() == 'ANSWERED';
                if (!isOldAnswered) {
                  _draftAnswers[_lastIndex] = _answerController.text;
                }
              }

              // 2. Load draft or submitted answer for the new index
              _lastIndex = state.currentIndex;
              final activeQuestion = state.questions[state.currentIndex];
              if (activeQuestion.questionStatus.toUpperCase() == 'ANSWERED') {
                _answerController.text = activeQuestion.userAnswer ?? '';
              } else {
                _answerController.text = _draftAnswers[state.currentIndex] ?? activeQuestion.userAnswer ?? '';
              }
              _validationError = null;
            }
          }

          if (state is AnswerSubmitted) {
            // Clear draft on successful submission
            _draftAnswers.remove(state.currentIndex);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppConstants.answerSubmittedToast,
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.white),
                ),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (state is QuestionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.white),
                ),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is QuestionLoading) {
            return const Center(child: LoadingIndicator());
          }

          if (state is QuestionError && state is! QuestionsLoaded) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  state.message,
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.error),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (state is QuestionsLoaded) {
            final questions = state.questions;
            final currentIndex = state.currentIndex;
            final activeQuestion = questions[currentIndex];
            final total = state.totalQuestions;
            final completed = state.completedQuestions;
            
            final isSubmitting = state is AnswerSubmitting;
            final isCompletedState = state is QuestionCompleted || completed == total;
            final isQuestionAnswered = activeQuestion.questionStatus.toUpperCase() == 'ANSWERED';

            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(
                      maxWidth: AppDimensions.maxContentWidth,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          AppConstants.resumeSessionSub,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.md),

                        QuestionProgressWidget(
                          completedQuestions: completed,
                          totalQuestions: total,
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        SizedBox(
                          height: 40,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: total,
                            separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.sm),
                            itemBuilder: (context, index) {
                              final isSelected = index == currentIndex;
                              final q = questions[index];
                              final isAnswered = q.questionStatus.toUpperCase() == 'ANSWERED';
                              
                              Color tabBg = isSelected 
                                  ? AppColors.primary 
                                  : (isAnswered ? AppColors.success.withOpacity(0.15) : AppColors.surface);
                              Color borderCol = isSelected
                                  ? AppColors.primary
                                  : (isAnswered ? AppColors.success.withOpacity(0.3) : AppColors.border.withOpacity(AppDimensions.opacityBorder));
                              Color textCol = isSelected 
                                  ? AppColors.white 
                                  : (isAnswered ? AppColors.success : AppColors.textPrimary);

                              return InkWell(
                                onTap: isSubmitting
                                    ? null
                                    : () {
                                        context.read<QuestionBloc>().add(NavigateToQuestionRequested(index));
                                      },
                                borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
                                child: Container(
                                  width: 40,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: tabBg,
                                    borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
                                    border: Border.all(color: borderCol),
                                  ),
                                  child: Text(
                                    '${index + 1}',
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: textCol,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        Container(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                            border: Border.all(
                              color: AppColors.border.withOpacity(AppDimensions.opacityBorder),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Question ${currentIndex + 1} of $total',
                                    style: AppTypography.bodyMedium.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  QuestionStatusChipWidget(status: activeQuestion.questionStatus),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                activeQuestion.question,
                                style: AppTypography.bodyLarge.copyWith(
                                  fontWeight: FontWeight.w600,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        AnswerInputWidget(
                          controller: _answerController,
                          enabled: !isSubmitting && !isQuestionAnswered,
                          errorText: _validationError,
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        CustomButton(
                          text: isQuestionAnswered 
                              ? AppConstants.duplicateSubmissionWarning 
                              : AppConstants.submitAnswerButton,
                          onPressed: (isSubmitting || isQuestionAnswered)
                              ? null
                              : () => _onSubmitPressed(activeQuestion.id),
                          isLoading: isSubmitting,
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton.icon(
                              onPressed: (currentIndex == 0 || isSubmitting)
                                  ? null
                                  : () {
                                      context
                                          .read<QuestionBloc>()
                                          .add(NavigateToQuestionRequested(currentIndex - 1));
                                    },
                              icon: const Icon(Icons.arrow_back_rounded),
                              label: const Text(AppConstants.previousQuestionButton),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.primaryLight,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: (currentIndex == total - 1 || isSubmitting)
                                  ? null
                                  : () {
                                      context
                                          .read<QuestionBloc>()
                                          .add(NavigateToQuestionRequested(currentIndex + 1));
                                    },
                              icon: const Icon(Icons.arrow_forward_rounded),
                              label: const Text(AppConstants.nextQuestionButton),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.primaryLight,
                              ),
                            ),
                          ],
                        ),

                        if (isCompletedState) ...[
                          const SizedBox(height: AppSpacing.xxl),
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                              border: Border.all(
                                color: AppColors.success.withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.check_circle_outline_rounded,
                                      color: AppColors.success,
                                      size: 32,
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            AppConstants.questionsCompletedBannerTitle,
                                            style: AppTypography.bodyLarge.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.success,
                                            ),
                                          ),
                                          const SizedBox(height: AppSpacing.xs),
                                          Text(
                                            AppConstants.proceedToEvaluationPrompt,
                                            style: AppTypography.bodyMedium.copyWith(
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                CustomButton(
                                  text: AppConstants.finishViewEvaluationButton,
                                  onPressed: () {
                                    Navigator.of(context).pushReplacementNamed(
                                      RouteConstants.evaluationResults,
                                      arguments: widget.sessionId,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          return const Center(child: Text(AppConstants.emptyQuestionsText));
        },
      ),
    );
  }
}