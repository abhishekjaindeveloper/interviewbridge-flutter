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
import '../bloc/evaluation_bloc.dart';
import '../bloc/evaluation_event.dart';
import '../bloc/evaluation_state.dart';
import '../widgets/score_card_widget.dart';
import '../widgets/evaluation_section_widget.dart';

class EvaluationPage extends StatefulWidget {
  final String sessionId;

  const EvaluationPage({
    super.key,
    required this.sessionId,
  });

  @override
  State<EvaluationPage> createState() => _EvaluationPageState();
}

class _EvaluationPageState extends State<EvaluationPage> {
  @override
  void initState() {
    super.initState();
    context.read<EvaluationBloc>().add(LoadSessionQuestionsRequested(widget.sessionId));
  }

  @override
  void dispose() {
    context.read<EvaluationBloc>().add(ResetEvaluationState());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          AppConstants.evaluationPageTitle,
          style: AppTypography.headingMedium,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Navigator.of(context).pushReplacementNamed(RouteConstants.home);
            }
          },
        ),
      ),
      body: BlocConsumer<EvaluationBloc, EvaluationState>(
        listener: (context, state) {
          if (state is EvaluationLoaded && state.evaluateError != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.evaluateError!,
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.white),
                ),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is EvaluationLoading) {
            return const Center(child: LoadingIndicator());
          }

          if (state is EvaluationError) {
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

          if (state is EvaluationLoaded) {
            final questions = state.questions;
            if (questions.isEmpty) {
              return Center(
                child: Text(
                  AppConstants.emptyQuestionsText,
                  style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary),
                ),
              );
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 800) {
                  // Desktop Layout (Split-pane)
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Left sidebar questions list
                      Container(
                        width: 320,
                        decoration: BoxDecoration(
                          border: Border(
                            right: BorderSide(
                              color: AppColors.border.withOpacity(AppDimensions.opacityBorder),
                            ),
                          ),
                        ),
                        child: _buildSidebar(context, state),
                      ),
                      // Right details pane
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Center(
                            child: Container(
                              constraints: const BoxConstraints(
                                maxWidth: AppDimensions.maxContentWidth,
                              ),
                              child: _buildDetailsPane(context, state, constraints),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  // Mobile Layout (Vertical stack)
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildAverageScoreHeader(state.averageScore),
                        const SizedBox(height: AppSpacing.md),
                        _buildMobileSelector(context, state),
                        const SizedBox(height: AppSpacing.lg),
                        _buildDetailsPane(context, state, constraints),
                      ],
                    ),
                  );
                }
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildAverageScoreHeader(double averageScore) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(
          color: AppColors.border.withOpacity(AppDimensions.opacityBorder),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            AppConstants.averageScoreLabel,
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              averageScore > 0
                  ? '${averageScore.toStringAsFixed(1)} / 10'
                  : AppConstants.notAvailablePlaceholder,
              style: AppTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, EvaluationLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: _buildAverageScoreHeader(state.averageScore),
        ),
        Divider(color: AppColors.border, height: 1),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: state.questions.length,
            separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final q = state.questions[index];
              final isSelected = index == state.currentIndex;
              final isEvaluated = q.evaluationStatus?.toUpperCase() == 'COMPLETED';

              return InkWell(
                onTap: state.isEvaluating
                    ? null
                    : () {
                        context.read<EvaluationBloc>().add(
                              GetEvaluationRequested(
                                questionId: q.id,
                                index: index,
                              ),
                            );
                      },
                borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.surfaceLight : AppColors.surface,
                    borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.border.withOpacity(AppDimensions.opacityBorder),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : AppColors.surfaceLight,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${q.questionNumber}',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Question ${q.questionNumber}',
                              style: AppTypography.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isEvaluated
                                  ? '${AppConstants.scoreLabel}: ${q.score}/10'
                                  : AppConstants.notEvaluatedYet,
                              style: AppTypography.bodyMedium.copyWith(
                                fontSize: 12,
                                color: isEvaluated ? AppColors.success : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isEvaluated)
                        const Icon(
                          Icons.check_circle_outline_rounded,
                          color: AppColors.success,
                          size: 20,
                        )
                      else if (q.questionStatus.toUpperCase() == 'ANSWERED')
                        Icon(
                          Icons.circle_outlined,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Divider(color: AppColors.border, height: 1),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: _buildNavigationButtons(context),
        ),
      ],
    );
  }

  Widget _buildMobileSelector(BuildContext context, EvaluationLoaded state) {
    return SizedBox(
      height: 64,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: state.questions.length,
        separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final q = state.questions[index];
          final isSelected = index == state.currentIndex;
          final isEvaluated = q.evaluationStatus?.toUpperCase() == 'COMPLETED';

          Color cardBg = isSelected 
              ? AppColors.primary 
              : (isEvaluated ? AppColors.success.withOpacity(0.15) : AppColors.surface);
          Color borderCol = isSelected
              ? AppColors.primary
              : (isEvaluated ? AppColors.success.withOpacity(0.3) : AppColors.border.withOpacity(AppDimensions.opacityBorder));
          Color textCol = isSelected ? AppColors.white : AppColors.textPrimary;

          return InkWell(
            onTap: state.isEvaluating
                ? null
                : () {
                    context.read<EvaluationBloc>().add(
                          GetEvaluationRequested(
                            questionId: q.id,
                            index: index,
                          ),
                        );
                  },
            borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
            child: Container(
              width: 80,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
                border: Border.all(color: borderCol),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Q${q.questionNumber}',
                    style: AppTypography.bodyMedium.copyWith(
                      color: textCol,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isEvaluated ? '${q.score}/10' : '-',
                    style: AppTypography.bodyMedium.copyWith(
                      fontSize: 11,
                      color: isSelected 
                          ? AppColors.white.withOpacity(0.9) 
                          : (isEvaluated ? AppColors.success : AppColors.textSecondary),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailsPane(BuildContext context, EvaluationLoaded state, BoxConstraints constraints) {
    final activeQuestion = state.questions[state.currentIndex];
    final isAnswered = activeQuestion.questionStatus.toUpperCase() == 'ANSWERED';
    final isEvaluated = activeQuestion.evaluationStatus?.toUpperCase() == 'COMPLETED';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Question Details Card
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
                    'Question ${activeQuestion.questionNumber} of ${state.questions.length}',
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isEvaluated
                          ? AppColors.success.withOpacity(0.15)
                          : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isEvaluated
                          ? AppConstants.evaluationCompleted
                          : (isAnswered ? AppConstants.notEvaluatedYet : AppConstants.questionStatusSkipped),
                      style: AppTypography.bodyMedium.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isEvaluated ? AppColors.success : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                activeQuestion.question,
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // User Answer Section (always visible if answered)
        if (isAnswered) ...[
          EvaluationSectionWidget(
            icon: Icons.person_outline_rounded,
            title: AppConstants.userAnswerTitle,
            content: activeQuestion.userAnswer ?? '',
            accentColor: AppColors.primaryLight,
          ),
        ],

        const SizedBox(height: AppSpacing.md),

        // Evaluation status or actions
        if (!isAnswered) ...[
          // Skipped question
          Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Text(
                AppConstants.noEvaluationAvailable,
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
            ),
          ),
        ] else if (state.isEvaluating) ...[
          // Show evaluate loader
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
              border: Border.all(
                color: AppColors.border.withOpacity(AppDimensions.opacityBorder),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const LoadingIndicator(),
                const SizedBox(height: AppSpacing.md),
                Text(
                  AppConstants.evaluatingStatus,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ] else if (!isEvaluated) ...[
          // Action button to start evaluation
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
              border: Border.all(
                color: AppColors.border.withOpacity(AppDimensions.opacityBorder),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.auto_awesome_outlined,
                  color: AppColors.primaryLight,
                  size: 48,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  AppConstants.noEvaluationAvailable,
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                CustomButton(
                  text: AppConstants.evaluateButton,
                  onPressed: () {
                    context.read<EvaluationBloc>().add(
                          TriggerEvaluationRequested(
                            questionId: activeQuestion.id,
                            index: state.currentIndex,
                          ),
                        );
                  },
                ),
              ],
            ),
          ),
        ] else ...[
          // Show evaluated feedback details
          if (state.activeEvaluation != null) ...[
            ScoreCardWidget(score: state.activeEvaluation!.score ?? 0),
            const SizedBox(height: AppSpacing.lg),
            if (state.activeEvaluation!.translatedAnswer != null &&
                state.activeEvaluation!.translatedAnswer!.isNotEmpty) ...[
              EvaluationSectionWidget(
                icon: Icons.g_translate_rounded,
                title: AppConstants.translatedAnswerTitle,
                content: state.activeEvaluation!.translatedAnswer!,
                accentColor: AppColors.secondary,
                initiallyExpanded: false,
              ),
            ],
            if (state.activeEvaluation!.improvedAnswer != null &&
                state.activeEvaluation!.improvedAnswer!.isNotEmpty) ...[
              EvaluationSectionWidget(
                icon: Icons.auto_awesome,
                title: AppConstants.improvedAnswerTitle,
                content: state.activeEvaluation!.improvedAnswer!,
                accentColor: AppColors.success,
              ),
            ],
            if (state.activeEvaluation!.explanation != null &&
                state.activeEvaluation!.explanation!.isNotEmpty) ...[
              EvaluationSectionWidget(
                icon: Icons.feedback_outlined,
                title: AppConstants.explanationTitle,
                content: state.activeEvaluation!.explanation!,
                accentColor: AppColors.primary,
              ),
            ],
          ] else ...[
            const Center(child: LoadingIndicator()),
          ],
        ],

        // Show buttons below details pane in mobile layout
        if (constraints.maxWidth <= 800) ...[
          const SizedBox(height: AppSpacing.xl),
          _buildNavigationButtons(context),
        ],
      ],
    );
  }

  Widget _buildNavigationButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomButton(
          text: AppConstants.closeSessionButton,
          onPressed: () {
            bool hasHome = false;
            Navigator.of(context).popUntil((route) {
              if (route.settings.name == RouteConstants.home ||
                  route.settings.name == RouteConstants.sessionStart) {
                hasHome = true;
                return true;
              }
              return false;
            });
            if (!hasHome) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                RouteConstants.home,
                (route) => false,
              );
            }
          },
        ),
        const SizedBox(height: AppSpacing.sm),
        TextButton(
          onPressed: () {
            bool hasHistory = false;
            Navigator.of(context).popUntil((route) {
              if (route.settings.name == RouteConstants.sessionHistory) {
                hasHistory = true;
                return true;
              }
              return false;
            });
            if (!hasHistory) {
              Navigator.of(context).pushReplacementNamed(RouteConstants.sessionHistory);
            }
          },
          child: const Text(
            AppConstants.backToHistoryButton,
            style: TextStyle(
              color: AppColors.primaryLight,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}