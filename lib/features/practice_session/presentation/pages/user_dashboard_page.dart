import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/routes/route_constants.dart';
import '../../../../core/widgets/user_drawer.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_event.dart';
import '../../../profile/presentation/bloc/profile_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/practice_session_bloc.dart';
import '../bloc/practice_session_event.dart';
import '../bloc/practice_session_state.dart';
import '../widgets/session_card_widget.dart';
import '../../domain/entities/practice_session_entity.dart';

class UserDashboardPage extends StatefulWidget {
  const UserDashboardPage({super.key});

  @override
  State<UserDashboardPage> createState() => _UserDashboardPageState();
}

class _UserDashboardPageState extends State<UserDashboardPage> {
  List<PracticeSessionEntity> _cachedRecentSessions = [];

  @override
  void initState() {
    super.initState();
    context.read<PracticeSessionBloc>().add(LoadSessionHistoryRequested());
    context.read<ProfileBloc>().add(LoadProfile());
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final weekDays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    final weekDay = weekDays[now.weekday - 1];
    final month = months[now.month - 1];
    return '$weekDay, $month ${now.day}, ${now.year}';
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

  Future<bool?> _showExitConfirmationDialog(BuildContext context) {
    return showGeneralDialog<bool>(
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
                    color: AppColors.primary.withValues(alpha: AppDimensions.opacityLow),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.exit_to_app_rounded,
                    color: AppColors.primary,
                    size: AppDimensions.iconMedium,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  AppConstants.exitTitle,
                  style: AppTypography.headingSmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  AppConstants.exitMessage,
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
                        onPressed: () => Navigator.of(dialogContext).pop(false),
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
                          Navigator.of(dialogContext).pop(true);
                        },
                        child: Text(
                          AppConstants.exitButtonLabel,
                          style: AppTypography.bodyLarge.copyWith(
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

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final profileState = context.watch<ProfileBloc>().state;
    final sessionState = context.watch<PracticeSessionBloc>().state;

    String userName = 'User';
    String userRole = AppConstants.candidateLabel;
    if (authState is Authenticated) {
      userName = authState.user.name;
      userRole = AppConstants.formatRole(authState.user.role);
    }

    // Determine profile configuration stats
    bool isProfileComplete = false;
    String techName = AppConstants.notConfigured;
    String expLabel = AppConstants.notConfigured;
    if (profileState is ProfileLoaded) {
      if (profileState.profile.technology != null && profileState.profile.experience != null) {
        isProfileComplete = true;
        techName = profileState.profile.technology!.name;
        expLabel = profileState.profile.experience!.experienceLabel;
      }
    }

    // Determine practice sessions stats
    int totalSessions = 0;
    double sumScores = 0.0;
    int scoredSessionsCount = 0;
    if (sessionState is PracticeSessionsLoaded) {
      _cachedRecentSessions = sessionState.sessions.take(3).toList();
      totalSessions = sessionState.sessions.length;
      for (final s in sessionState.sessions) {
        if (s.sessionStatus == 'COMPLETED' || s.averageScore > 0) {
          sumScores += s.averageScore;
          scoredSessionsCount++;
        }
      }
    }
    final recentSessions = _cachedRecentSessions;
    final double overallAvg = scoredSessionsCount > 0 ? sumScores / scoredSessionsCount : 0.0;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldExit = await _showExitConfirmationDialog(context);
        if (shouldExit == true) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            AppConstants.appName,
            style: AppTypography.headingSmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            _buildProfileHeaderWidget(context, userName, userRole),
          ],
        ),
        drawer: UserDrawer(
          currentRoute: RouteConstants.home,
          parentContext: context,
        ),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              context.read<PracticeSessionBloc>().add(LoadSessionHistoryRequested());
              context.read<ProfileBloc>().add(LoadProfile());
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(
                    maxWidth: AppDimensions.maxContentWidth,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. Welcome Card
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withValues(alpha: 0.7),
                              AppColors.secondary.withValues(alpha: 0.8),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            const Positioned(
                              right: -10,
                              bottom: -10,
                              child: Opacity(
                                opacity: 0.12,
                                child: Icon(
                                  Icons.school_outlined,
                                  size: 140,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(AppSpacing.xl),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Welcome back,',
                                        style: AppTypography.headingMedium.copyWith(
                                          color: AppColors.white.withValues(alpha: 0.9),
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.xs),
                                      const Text(
                                        '👋',
                                        style: TextStyle(fontSize: 24),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    userName,
                                    style: AppTypography.headingLarge.copyWith(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Text(
                                    _getFormattedDate(),
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: AppColors.white.withValues(alpha: 0.85),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // 2. Metrics Statistics Row
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth >= 600;
                          return GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: isWide ? 3 : 2,
                            crossAxisSpacing: AppSpacing.md,
                            mainAxisSpacing: AppSpacing.md,
                            childAspectRatio: isWide ? 1.4 : 1.25,
                            children: [
                              _buildStatCard(
                                title: 'Total Sessions',
                                icon: Icons.history_edu_outlined,
                                iconColor: AppColors.primary,
                                value: totalSessions.toString(),
                              ),
                              _buildStatCard(
                                title: 'Overall Avg Score',
                                icon: Icons.insights_outlined,
                                iconColor: AppColors.success,
                                value: scoredSessionsCount > 0 ? '${overallAvg.toStringAsFixed(1)} / 10' : AppConstants.notAvailablePlaceholder,
                              ),
                              _buildStatCard(
                                title: 'Profile Setup',
                                icon: isProfileComplete ? Icons.verified_user_outlined : Icons.warning_amber_outlined,
                                iconColor: isProfileComplete ? AppColors.success : AppColors.warning,
                                value: isProfileComplete ? techName : 'Incomplete',
                                subtitle: isProfileComplete ? expLabel : 'Configure selections',
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // 3. Quick Actions
                      Text(
                        'Start Practicing',
                        style: AppTypography.headingSmall.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: _buildActionCard(
                              title: 'Practice Session',
                              subtitle: 'Start customizable practice set tailored to your role',
                              icon: Icons.forum_rounded,
                              color: AppColors.primary,
                              onTap: () {
                                Navigator.of(context).pushNamed(RouteConstants.sessionStart);
                              },
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: _buildActionCard(
                              title: 'Session History',
                              subtitle: 'Review detailed AI responses & evaluations',
                              icon: Icons.history_rounded,
                              color: AppColors.secondary,
                              onTap: () {
                                Navigator.of(context).pushNamed(RouteConstants.sessionHistory);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xxl),

                      // 4. Recent Sessions List
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

                      if (recentSessions.isEmpty && sessionState is! PracticeSessionLoading) ...[
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
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required String value,
    String? subtitle,
  }) {
    return Card(
      color: AppColors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: AppDimensions.opacityLow),
                    borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    value,
                    style: AppTypography.headingSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: subtitle != null ? 14 : 18,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          border: Border.all(
            color: AppColors.border.withValues(alpha: AppDimensions.opacityBorder),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: color.withValues(alpha: AppDimensions.opacityLow),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: AppTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTypography.bodyMedium.copyWith(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
