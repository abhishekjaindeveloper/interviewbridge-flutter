import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/entities/matched_job_entity.dart';

class JobCardWidget extends StatelessWidget {
  final MatchedJobEntity job;
  final VoidCallback onTap;

  const JobCardWidget({
    super.key,
    required this.job,
    required this.onTap,
  });

  String _formatSalary() {
    if (job.salaryMin != null && job.salaryMax != null) {
      return '\$${job.salaryMin!.toStringAsFixed(0)} - \$${job.salaryMax!.toStringAsFixed(0)}';
    } else if (job.salaryMin != null) {
      return 'From \$${job.salaryMin!.toStringAsFixed(0)}';
    } else if (job.salaryMax != null) {
      return 'Up to \$${job.salaryMax!.toStringAsFixed(0)}';
    }
    return '';
  }

  String _formatPostedDate() {
    if (job.postedAt == null) return '';
    final dt = job.postedAt!;
    final diffDays = DateTime.now().difference(dt).inDays;
    if (diffDays == 0) return 'Today';
    if (diffDays == 1) return 'Yesterday';
    if (diffDays < 30) return '${diffDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final salary = _formatSalary();
    final dateStr = _formatPostedDate();

    return Card(
      color: AppColors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: AppColors.border.withValues(alpha: AppDimensions.opacityBorder),
        ),
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: AppDimensions.opacityLow),
                      borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
                    ),
                    child: Center(
                      child: Text(
                        job.company.isNotEmpty ? job.company[0].toUpperCase() : 'J',
                        style: AppTypography.headingSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.title,
                          style: AppTypography.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          job.company,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: AppDimensions.opacityLow),
                      borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
                      border: Border.all(
                        color: AppColors.success.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.stars_rounded,
                          size: 14,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${job.matchScore}% Match',
                          style: AppTypography.bodyMedium.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: [
                  if (job.location != null && job.location!.isNotEmpty)
                    _buildChip(Icons.location_on_outlined, job.location!),
                  if (job.workMode != null && job.workMode!.isNotEmpty)
                    _buildChip(Icons.work_outline, job.workMode!),
                  if (job.employmentType != null && job.employmentType!.isNotEmpty)
                    _buildChip(Icons.access_time, job.employmentType!),
                  if (salary.isNotEmpty)
                    _buildChip(Icons.attach_money, salary, isHighlight: true),
                ],
              ),
              if (job.description.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  job.description,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (dateStr.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Posted $dateStr',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary.withValues(alpha: 0.7),
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(IconData icon, String label, {bool isHighlight = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
      decoration: BoxDecoration(
        color: isHighlight
            ? AppColors.primary.withValues(alpha: AppDimensions.opacityLow)
            : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: isHighlight ? AppColors.primary : AppColors.textSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              fontSize: 11,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
              color: isHighlight ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
