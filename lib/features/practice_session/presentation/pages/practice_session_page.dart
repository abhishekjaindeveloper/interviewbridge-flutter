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
import '../../../../core/widgets/user_drawer.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
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

  void _showProfileSetupRequiredDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: AppColors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (dialogContext, anim1, anim2) {
        return Dialog(
          backgroundColor: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: AppColors.border),
            borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          ),
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: AppDimensions.maxContentWidth - 100,
            ),
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: AppDimensions.opacityLow),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_amber_outlined,
                    color: AppColors.warning,
                    size: AppDimensions.iconMedium,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Profile Setup Required',
                  style: AppTypography.headingSmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Please complete your Technology and Experience before starting a practice session.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        child: Text(
                          AppConstants.cancelButtonLabel,
                          style: AppTypography.bodyLarge.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          Navigator.of(context).pushNamed(RouteConstants.profileSetup);
                        },
                        child: const Text(
                          'Complete Profile',
                          style: TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        final curve = CurvedAnimation(parent: anim1, curve: Curves.easeOutBack);
        return ScaleTransition(
          scale: curve,
          child: FadeTransition(
            opacity: anim1,
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildProfileHeaderWidget(BuildContext context, String userName, String userRole) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(RouteConstants.profile);
      },
      borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  userName,
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  userRole,
                  style: AppTypography.bodyMedium.copyWith(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(width: AppSpacing.sm),
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary,
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
      isProfileComplete = profileState.profile.profileStatus == 'COMPLETED';
      if (profileState.profile.technology != null) {
        techName = profileState.profile.technology!.name;
        techId = profileState.profile.technology!.id;
      }
      if (profileState.profile.experience != null) {
        expLabel = profileState.profile.experience!.experienceLabel;
        expId = profileState.profile.experience!.id;
      }
    }
    final authState = context.watch<AuthBloc>().state;
    String userName = 'User';
    String userRole = AppConstants.candidateLabel;
    if (authState is Authenticated) {
      userName = authState.user.name;
      userRole = AppConstants.formatRole(authState.user.role);
    }

    if (techName.isEmpty) techName = AppConstants.notConfigured;
    if (expLabel.isEmpty) expLabel = AppConstants.notConfigured;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          AppConstants.practiceDashboardTitle,
          style: AppTypography.headingMedium,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          _buildProfileHeaderWidget(context, userName, userRole),
        ],
      ),
      drawer: UserDrawer(
        currentRoute: RouteConstants.sessionStart,
        parentContext: context,
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
                              Divider(color: AppColors.border),
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
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        if (!isProfileComplete) {
                                          _showProfileSetupRequiredDialog(context);
                                        } else {
                                          _onStartSessionPressed(techId, expId);
                                        }
                                      },
                                isLoading: isLoading,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xxl),
                        Divider(color: AppColors.border),
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