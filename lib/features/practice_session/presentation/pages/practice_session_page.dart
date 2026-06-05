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
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_state.dart';
import '../bloc/practice_session_bloc.dart';
import '../bloc/practice_session_event.dart';
import '../bloc/practice_session_state.dart';
import '../widgets/session_card_widget.dart';
import '../widgets/session_summary_widget.dart';
import '../../domain/entities/practice_session_entity.dart';

class PracticeSessionPage extends StatefulWidget {
  const PracticeSessionPage({super.key});

  @override
  State<PracticeSessionPage> createState() => _PracticeSessionPageState();
}

class _PracticeSessionPageState extends State<PracticeSessionPage> {
  int _selectedQuestionCount = 10;

  @override
  void initState() {
    super.initState();
    context.read<PracticeSessionBloc>().add(LoadSessionHistoryRequested());
  }

  void _onStartSessionPressed(String techId, String expId) {
    context.read<PracticeSessionBloc>().add(
          CreateSessionRequested(
            technologyId: techId,
            experienceId: expId,
            totalQuestions: _selectedQuestionCount,
          ),
        );
  }

  void _showSummaryDialog(BuildContext context, PracticeSessionEntity session) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                  border: Border.all(
                    color: AppColors.border.withOpacity(AppDimensions.opacityBorder),
                  ),
                ),
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      AppConstants.readyForPracticeTitle,
                      style: AppTypography.headingMedium.copyWith(
                        color: AppColors.success,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      AppConstants.practiceQuestionsGeneratedToast,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    SessionSummaryWidget(session: session),
                    const SizedBox(height: AppSpacing.lg),
                    CustomButton(
                      text: AppConstants.closeButton,
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileState = context.watch<ProfileBloc>().state;
    bool isProfileComplete = false;
    String techName = '';
    String techId = '';
    String expLabel = '';
    String expId = '';

    if (profileState is ProfileLoaded) {
      if (profileState.profile.technology != null && profileState.profile.experience != null) {
        isProfileComplete = true;
        techName = profileState.profile.technology!.name;
        techId = profileState.profile.technology!.id;
        expLabel = profileState.profile.experience!.experienceLabel;
        expId = profileState.profile.experience!.id;
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          AppConstants.practiceDashboardTitle,
          style: AppTypography.headingMedium,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocConsumer<PracticeSessionBloc, PracticeSessionState>(
        listener: (context, state) {
          if (state is PracticeSessionCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppConstants.practiceSessionCreatedToast,
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.white),
                ),
                backgroundColor: AppColors.success,
              ),
            );
            // Trigger question generation immediately after creation
            context.read<PracticeSessionBloc>().add(GenerateQuestionsRequested(state.session.id));
          } else if (state is PracticeQuestionsGenerated) {
            _showSummaryDialog(context, state.session);
            // Reload history preview list
            context.read<PracticeSessionBloc>().add(LoadSessionHistoryRequested());
          } else if (state is PracticeSessionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.white),
                ),
                backgroundColor: AppColors.error,
              ),
            );
            // Refresh preview if we failed in generating questions
            context.read<PracticeSessionBloc>().add(LoadSessionHistoryRequested());
          }
        },
        builder: (context, state) {
          final isLoading = state is PracticeSessionLoading;

          if (!isProfileComplete) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.warning,
                      size: 64,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      AppConstants.incompleteProfileWarning,
                      style: AppTypography.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    CustomButton(
                      text: AppConstants.goToProfileSetupButton,
                      onPressed: () {
                        Navigator.of(context).pushNamed(RouteConstants.profileSetup);
                      },
                    ),
                  ],
                ),
              ),
            );
          }

          List<PracticeSessionEntity> recentSessions = [];
          if (state is PracticeSessionsLoaded) {
            recentSessions = state.sessions.take(3).toList();
          }

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
                        AppConstants.practiceDashboardSubtitle,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Configuration Card
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
                            Text(
                              AppConstants.activeSelectionsTitle,
                              style: AppTypography.bodyLarge.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  AppConstants.technologyLabel,
                                  style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                                ),
                                Text(
                                  techName,
                                  style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  AppConstants.experienceLevelLabel,
                                  style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                                ),
                                Text(
                                  expLabel,
                                  style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            const Divider(color: AppColors.border),
                            const SizedBox(height: AppSpacing.lg),
                            Text(
                              AppConstants.totalQuestionsSelectorLabel,
                              style: AppTypography.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: AppConstants.questionCountPresets.map((count) {
                                final isSelected = _selectedQuestionCount == count;
                                return ChoiceChip(
                                  label: Text('$count'),
                                  selected: isSelected,
                                  selectedColor: AppColors.primary,
                                  backgroundColor: AppColors.surfaceLight,
                                  labelStyle: TextStyle(
                                    color: isSelected ? AppColors.white : AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  onSelected: isLoading
                                      ? null
                                      : (selected) {
                                          if (selected) {
                                            setState(() {
                                              _selectedQuestionCount = count;
                                            });
                                          }
                                        },
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            CustomButton(
                              text: AppConstants.startPracticeButton,
                              onPressed: isLoading ? null : () => _onStartSessionPressed(techId, expId),
                              isLoading: isLoading,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xxl),
                      const Divider(color: AppColors.border),
                      const SizedBox(height: AppSpacing.xl),

                      // Recent Sessions Preview Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppConstants.recentSessionsLabel,
                            style: AppTypography.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pushNamed(RouteConstants.sessionHistory);
                            },
                            child: const Text(
                              AppConstants.viewAllHistoryButton,
                              style: TextStyle(color: AppColors.primaryLight),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),

                      if (recentSessions.isEmpty && state is! PracticeSessionLoading) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                          child: Center(
                            child: Text(
                              AppConstants.noRecentSessionsText,
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: recentSessions.length,
                          separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
                          itemBuilder: (context, index) {
                            final session = recentSessions[index];
                            return SessionCardWidget(
                              session: session,
                              onTap: () {
                                Navigator.of(context).pushNamed(
                                  RouteConstants.sessionActive,
                                  arguments: session.id,
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
