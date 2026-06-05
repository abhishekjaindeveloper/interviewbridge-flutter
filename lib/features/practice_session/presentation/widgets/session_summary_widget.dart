// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import '../../domain/entities/practice_session_entity.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/constants/app_constants.dart';
import 'session_status_chip_widget.dart';

class SessionSummaryWidget extends StatelessWidget {
  final PracticeSessionEntity session;

  const SessionSummaryWidget({
    super.key,
    required this.session,
  });

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return '';
    return '${dateTime.month.toString().padLeft(2, '0')}/${dateTime.day.toString().padLeft(2, '0')}/${dateTime.year}';
  }

  Widget _buildRow(String label, String value, {Widget? customValue}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          customValue ??
              Text(
                value,
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                AppConstants.sessionSummaryTitle,
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SessionStatusChipWidget(status: session.sessionStatus),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(color: AppColors.border),
          const SizedBox(height: AppSpacing.sm),
          _buildRow(AppConstants.sessionIdLabel, '${session.id.substring(0, 8)}...'),
          _buildRow(AppConstants.technologyLabel, session.technologyName),
          _buildRow(AppConstants.experienceLevelLabel, session.experienceLabel),
          _buildRow(AppConstants.totalQuestionsLabel, '${session.totalQuestions}'),
          _buildRow(AppConstants.completedQuestionsLabelDetailed, '${session.completedQuestions}'),
          _buildRow(AppConstants.averageScoreLabel, '${session.averageScore.toStringAsFixed(1)}/10.0'),
          _buildRow(AppConstants.createdAtLabel, _formatDate(session.createdAt)),
        ],
      ),
    );
  }
}
