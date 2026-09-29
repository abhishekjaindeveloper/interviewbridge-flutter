import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/matched_job_entity.dart';
import '../bloc/career_pilot_bloc.dart';
import '../bloc/career_pilot_event.dart';
import '../bloc/career_pilot_state.dart';

class JobDetailsPage extends StatelessWidget {
  final String jobId;

  const JobDetailsPage({
    super.key,
    required this.jobId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CareerPilotBloc>(
      create: (_) => sl<CareerPilotBloc>()..add(FetchJobDetailsRequested(jobId)),
      child: _JobDetailsView(jobId: jobId),
    );
  }
}

class _JobDetailsView extends StatelessWidget {
  final String jobId;

  const _JobDetailsView({required this.jobId});

  Future<void> _openApplyUrl(BuildContext context, String? urlString) async {
    if (urlString == null || urlString.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No application URL provided for this job.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final cleanUrl = urlString.trim();
    await Clipboard.setData(ClipboardData(text: cleanUrl));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Application link copied to clipboard:\n$cleanUrl'),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  String _formatSalary(MatchedJobEntity job) {
    if (job.salaryMin != null && job.salaryMax != null) {
      return '\$${job.salaryMin!.toStringAsFixed(0)} - \$${job.salaryMax!.toStringAsFixed(0)}';
    } else if (job.salaryMin != null) {
      return 'From \$${job.salaryMin!.toStringAsFixed(0)}';
    } else if (job.salaryMax != null) {
      return 'Up to \$${job.salaryMax!.toStringAsFixed(0)}';
    }
    return 'Not specified';
  }

  String _formatPostedDate(MatchedJobEntity job) {
    if (job.postedAt == null) return 'N/A';
    final dt = job.postedAt!;
    final diffDays = DateTime.now().difference(dt).inDays;
    if (diffDays == 0) return 'Today';
    if (diffDays == 1) return 'Yesterday';
    if (diffDays < 30) return '$diffDays days ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Job Details',
          style: AppTypography.headingSmall.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<CareerPilotBloc, CareerPilotState>(
          builder: (context, state) {
            if (state is JobDetailsLoading || state is CareerPilotLoading) {
              return const Center(
                child: LoadingIndicator(),
              );
            }

            if (state is JobDetailsError) {
              return _buildErrorView(context, state.message);
            }

            if (state is JobDetailsLoaded) {
              final job = state.job;
              final salary = _formatSalary(job);
              final postedDate = _formatPostedDate(job);
              final tagsList = job.tags != null && job.tags!.isNotEmpty
                  ? job.tags!.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList()
                  : <String>[];

              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Center(
                        child: Container(
                          constraints: const BoxConstraints(
                            maxWidth: AppDimensions.maxContentWidth,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Main Info Header Card
                              Container(
                                padding: const EdgeInsets.all(AppSpacing.xl),
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
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 56,
                                          height: 56,
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withValues(alpha: AppDimensions.opacityLow),
                                            borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
                                          ),
                                          child: Center(
                                            child: Text(
                                              job.company.isNotEmpty ? job.company[0].toUpperCase() : 'J',
                                              style: AppTypography.headingMedium.copyWith(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: AppSpacing.lg),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                job.title,
                                                style: AppTypography.headingSmall.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.textPrimary,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                job.company,
                                                style: AppTypography.bodyLarge.copyWith(
                                                  color: AppColors.textSecondary,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: AppSpacing.lg),
                                    Divider(color: AppColors.border.withValues(alpha: AppDimensions.opacityBorder)),
                                    const SizedBox(height: AppSpacing.md),
                                    
                                    // Match Score Banner inside Card
                                    Container(
                                      padding: const EdgeInsets.all(AppSpacing.md),
                                      decoration: BoxDecoration(
                                        color: AppColors.success.withValues(alpha: AppDimensions.opacityLow),
                                        borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
                                        border: Border.all(
                                          color: AppColors.success.withValues(alpha: 0.3),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.stars_rounded,
                                            color: AppColors.success,
                                            size: 24,
                                          ),
                                          const SizedBox(width: AppSpacing.sm),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${job.matchScore}% Preference Match Score',
                                                  style: AppTypography.bodyLarge.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.success,
                                                  ),
                                                ),
                                                Text(
                                                  'Matched based on career preferences & skill profile',
                                                  style: AppTypography.bodyMedium.copyWith(
                                                    fontSize: 11,
                                                    color: AppColors.textSecondary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xl),

                              // Quick Info Grid
                              Text(
                                'Overview',
                                style: AppTypography.bodyLarge.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              GridView.count(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisCount: 2,
                                crossAxisSpacing: AppSpacing.md,
                                mainAxisSpacing: AppSpacing.md,
                                childAspectRatio: 2.3,
                                children: [
                                  _buildInfoTile(
                                    icon: Icons.location_on_outlined,
                                    title: 'Location',
                                    value: job.location ?? 'Remote / Flexible',
                                  ),
                                  _buildInfoTile(
                                    icon: Icons.work_outline,
                                    title: 'Work Mode',
                                    value: job.workMode ?? 'Full-time',
                                  ),
                                  _buildInfoTile(
                                    icon: Icons.access_time,
                                    title: 'Employment Type',
                                    value: job.employmentType ?? 'Standard',
                                  ),
                                  _buildInfoTile(
                                    icon: Icons.attach_money,
                                    title: 'Salary Range',
                                    value: salary,
                                  ),
                                  _buildInfoTile(
                                    icon: Icons.calendar_today_outlined,
                                    title: 'Posted Date',
                                    value: postedDate,
                                  ),
                                  if (job.provider != null)
                                    _buildInfoTile(
                                      icon: Icons.cloud_queue_outlined,
                                      title: 'Provider',
                                      value: job.provider!,
                                    ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.xl),

                              // Skills & Tags Section
                              if (tagsList.isNotEmpty) ...[
                                Text(
                                  'Required Skills & Tags',
                                  style: AppTypography.bodyLarge.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                Wrap(
                                  spacing: AppSpacing.sm,
                                  runSpacing: AppSpacing.xs,
                                  children: tagsList.map((tag) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.md,
                                      vertical: AppSpacing.xs,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: AppDimensions.opacityLow),
                                      borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
                                      border: Border.all(
                                        color: AppColors.primary.withValues(alpha: 0.2),
                                      ),
                                    ),
                                    child: Text(
                                      tag,
                                      style: AppTypography.bodyMedium.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  )).toList(),
                                ),
                                const SizedBox(height: AppSpacing.xl),
                              ],

                              // Description Section
                              Text(
                                'Job Description',
                                style: AppTypography.bodyLarge.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(AppSpacing.xl),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                                  border: Border.all(
                                    color: AppColors.border.withValues(alpha: AppDimensions.opacityBorder),
                                  ),
                                ),
                                child: Text(
                                  job.description.isNotEmpty
                                      ? job.description
                                      : 'No detailed description available for this job posting.',
                                  style: AppTypography.bodyLarge.copyWith(
                                    color: AppColors.textPrimary,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xxl),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Bottom Fixed Action Bar for Apply Now
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -4),
                        ),
                      ],
                      border: Border(
                        top: BorderSide(
                          color: AppColors.border.withValues(alpha: AppDimensions.opacityBorder),
                        ),
                      ),
                    ),
                    child: SafeArea(
                      top: false,
                      child: Center(
                        child: Container(
                          constraints: const BoxConstraints(
                            maxWidth: AppDimensions.maxContentWidth,
                          ),
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
                              ),
                            ),
                            onPressed: () => _openApplyUrl(context, job.applyUrl),
                            icon: const Icon(Icons.open_in_new_rounded, color: AppColors.white),
                            label: Text(
                              'Apply Now',
                              style: AppTypography.bodyLarge.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(
          color: AppColors.border.withValues(alpha: AppDimensions.opacityBorder),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: AppDimensions.opacityLow),
              borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Failed to load job details',
              style: AppTypography.headingSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.md,
                ),
              ),
              onPressed: () {
                context.read<CareerPilotBloc>().add(FetchJobDetailsRequested(jobId));
              },
              child: const Text('Retry', style: TextStyle(color: AppColors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
