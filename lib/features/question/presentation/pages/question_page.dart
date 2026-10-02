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
import '../../../../core/widgets/error_dialog.dart';
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
  bool _showReferenceAnswer = false;

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
            if (state.errorMessage != null) {
              ErrorDialog.show(
                context: context,
                title: 'Error',
                message: state.errorMessage!,
              ).then((_) {
                if (context.mounted) {
                  context.read<QuestionBloc>().add(const ClearQuestionError());
                }
              });
            }

            if (state.currentIndex != _lastIndex) {
              _showReferenceAnswer = false;

              // 1. Save draft for the old index (if valid and not evaluated)
              if (_lastIndex >= 0 && _lastIndex < state.questions.length) {
                final oldQuestion = state.questions[_lastIndex];
                final isOldEvaluated = oldQuestion.evaluationStatus?.toUpperCase() == 'COMPLETED';
                if (!isOldEvaluated) {
                  _draftAnswers[_lastIndex] = _answerController.text;
                }
              }

              // 2. Load draft or submitted answer for the new index
              _lastIndex = state.currentIndex;
              final activeQuestion = state.questions[state.currentIndex];
              final isCurrentEvaluated = activeQuestion.evaluationStatus?.toUpperCase() == 'COMPLETED';
              if (isCurrentEvaluated) {
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

            SuccessDialog.show(
              context: context,
              title: 'Success',
              message: AppConstants.answerSubmittedToast,
            );
          } else if (state is QuestionError) {
            ErrorDialog.show(
              context: context,
              title: 'Error',
              message: state.message,
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
            if (state.currentIndex != _lastIndex) {
              _showReferenceAnswer = false;
              _lastIndex = state.currentIndex;
              final q = state.questions[state.currentIndex];
              final isEvaluated = q.evaluationStatus?.toUpperCase() == 'COMPLETED';
              if (isEvaluated) {
                _answerController.text = q.userAnswer ?? '';
              } else {
                _answerController.text = _draftAnswers[state.currentIndex] ?? q.userAnswer ?? '';
              }
            }
            final questions = state.questions;
            final currentIndex = state.currentIndex;
            final activeQuestion = questions[currentIndex];
            final total = state.totalQuestions;
            final completed = state.completedQuestions;
            
            final isSubmitting = state is AnswerSubmitting;
            final isCompletedState = state is QuestionCompleted || completed == total;
            final isEvaluationCompleted = activeQuestion.evaluationStatus?.toUpperCase() == 'COMPLETED';

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
                                        setState(() {
                                          _showReferenceAnswer = false;
                                        });
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
                                  Expanded(
                                    child: Text(
                                      AppConstants.questionOfTotal(currentIndex + 1, total),
                                      style: AppTypography.bodyMedium.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textSecondary,
                                      ),
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
                          key: ValueKey('answer_input_${activeQuestion.id}'),
                          questionId: activeQuestion.id,
                          controller: _answerController,
                          enabled: !isSubmitting && !isEvaluationCompleted,
                          errorText: _validationError,
                        ),

                        if (activeQuestion.referenceAnswer != null &&
                            activeQuestion.referenceAnswer!.trim().isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.md),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: OutlinedButton.icon(
                              key: const ValueKey('toggle_reference_answer_button'),
                              onPressed: () {
                                setState(() {
                                  _showReferenceAnswer = !_showReferenceAnswer;
                                });
                              },
                              icon: Icon(
                                _showReferenceAnswer
                                    ? Icons.visibility_off_outlined
                                    : Icons.lightbulb_outline_rounded,
                                size: 18,
                                color: AppColors.secondary,
                              ),
                              label: Text(
                                _showReferenceAnswer
                                    ? AppConstants.hideReferenceAnswerTitle
                                    : AppConstants.showReferenceAnswerTitle,
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: AppColors.secondary.withOpacity(0.4),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.sm,
                                ),
                              ),
                            ),
                          ),
                          if (_showReferenceAnswer) ...[
                            const SizedBox(height: AppSpacing.sm),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                                border: Border.all(
                                  color: AppColors.secondary.withOpacity(0.4),
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.menu_book_rounded,
                                        color: AppColors.secondary,
                                        size: 20,
                                      ),
                                      const SizedBox(width: AppSpacing.sm),
                                      Text(
                                        AppConstants.referenceAnswerTitle,
                                        style: AppTypography.bodyLarge.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Divider(color: AppColors.border, height: 1),
                                  const SizedBox(height: AppSpacing.md),
                                  SelectableText(
                                    activeQuestion.referenceAnswer!,
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: AppColors.textPrimary,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],

                        const SizedBox(height: AppSpacing.xl),

                        CustomButton(
                          text: isEvaluationCompleted 
                              ? AppConstants.duplicateSubmissionWarning 
                              : AppConstants.submitAnswerButton,
                          onPressed: (isSubmitting || isEvaluationCompleted)
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
                                      setState(() {
                                        _showReferenceAnswer = false;
                                      });
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
                                      setState(() {
                                        _showReferenceAnswer = false;
                                      });
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