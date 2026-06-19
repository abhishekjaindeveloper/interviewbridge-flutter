// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import '../../domain/entities/practice_session_entity.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/constants/app_constants.dart';
import 'session_status_chip_widget.dart';

class SessionCardWidget extends StatelessWidget {
  final PracticeSessionEntity session;
  final VoidCallback? onTap;

  const SessionCardWidget({
    super.key,
    required this.session,
    this.onTap,
  });

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return '';
    return '${dateTime.month.toString().padLeft(2, '0')}/${dateTime.day.toString().padLeft(2, '0')}/${dateTime.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = session.sessionStatus.toUpperCase() == 'COMPLETED';
    final hasScore = isCompleted && session.averageScore > 0;

    return Card(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        side: BorderSide(
          color: AppColors.border.withOpacity(AppDimensions.opacityBorder),
        ),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      session.technologyName,
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SessionStatusChipWidget(status: session.sessionStatus),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                session.experienceLabel,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Divider(color: AppColors.border, height: 1),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppConstants.createdAtLabel,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        _formatDate(session.createdAt),
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        isCompleted ? AppConstants.averageScoreLabel : AppConstants.completedQuestionsLabel,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        isCompleted
                            ? (hasScore ? '${session.averageScore.toStringAsFixed(1)}/10.0' : AppConstants.notAvailablePlaceholder)
                            : '${session.completedQuestions}/${session.totalQuestions}',
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isCompleted ? AppColors.success : AppColors.primaryLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}