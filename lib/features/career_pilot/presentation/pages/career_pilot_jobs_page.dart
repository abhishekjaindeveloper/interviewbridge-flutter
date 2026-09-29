import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/routes/route_constants.dart';
import '../../../../core/widgets/user_drawer.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../injection_container.dart';
import '../bloc/career_pilot_bloc.dart';
import '../bloc/career_pilot_event.dart';
import '../bloc/career_pilot_state.dart';
import '../widgets/job_card_widget.dart';

class CareerPilotJobsPage extends StatelessWidget {
  const CareerPilotJobsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CareerPilotBloc>(
      create: (_) => sl<CareerPilotBloc>()..add(const FetchMatchedJobsRequested()),
      child: const _CareerPilotJobsView(),
    );
  }
}

class _CareerPilotJobsView extends StatelessWidget {
  const _CareerPilotJobsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'CareerPilot Jobs',
          style: AppTypography.headingSmall.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      drawer: UserDrawer(
        currentRoute: RouteConstants.careerPilotJobs,
        parentContext: context,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<CareerPilotBloc>().add(const FetchMatchedJobsRequested());
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
                    // Header Banner
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withValues(alpha: 0.8),
                            AppColors.secondary,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.25),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'AI Matched Opportunities',
                                  style: AppTypography.headingMedium.copyWith(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  'Personalized job recommendations based on your preferences & technical skills',
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: AppColors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: AppColors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.auto_awesome_rounded,
                              size: 32,
                              color: AppColors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Content Body
                    BlocBuilder<CareerPilotBloc, CareerPilotState>(
                      builder: (context, state) {
                        if (state is CareerPilotLoading) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl * 2),
                            child: Center(
                              child: LoadingIndicator(),
                            ),
                          );
                        }

                        if (state is CareerPilotError) {
                          return _buildErrorState(context, state.message);
                        }

                        if (state is CareerPilotJobsEmpty) {
                          return _buildEmptyState(context);
                        }

                        if (state is CareerPilotJobsLoaded) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${state.jobs.length} Matched Positions',
                                style: AppTypography.bodyLarge.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: state.jobs.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: AppSpacing.md),
                                itemBuilder: (context, index) {
                                  final job = state.jobs[index];
                                  return JobCardWidget(
                                    job: job,
                                    onTap: () {
                                      Navigator.of(context).pushNamed(
                                        RouteConstants.careerPilotJobDetails,
                                        arguments: job.id,
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          );
                        }

                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(
          color: AppColors.border.withValues(alpha: AppDimensions.opacityBorder),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: AppDimensions.opacityLow),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.work_off_outlined,
              size: 48,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'No matching jobs found',
            style: AppTypography.headingSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Ensure your profile career preferences and technologies are updated to see matched opportunities.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.md,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
              ),
            ),
            onPressed: () {
              context.read<CareerPilotBloc>().add(const FetchMatchedJobsRequested());
            },
            icon: const Icon(Icons.refresh_rounded, color: AppColors.white),
            label: Text(
              'Refresh Jobs',
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: AppDimensions.opacityLow),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Failed to load jobs',
            style: AppTypography.headingSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            message.isNotEmpty ? message : 'An unexpected network error occurred.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.md,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
              ),
            ),
            onPressed: () {
              context.read<CareerPilotBloc>().add(const FetchMatchedJobsRequested());
            },
            icon: const Icon(Icons.refresh_rounded, color: AppColors.white),
            label: Text(
              'Try Again',
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
