// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/app_constants.dart';

class QuestionStatusChipWidget extends StatelessWidget {
  final String status;

  const QuestionStatusChipWidget({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status.toUpperCase()) {
      case 'ANSWERED':
        color = AppColors.success;
        label = AppConstants.questionStatusAnswered;
        break;
      case 'SKIPPED':
        color = AppColors.warning;
        label = AppConstants.questionStatusSkipped;
        break;
      case 'PENDING':
      default:
        color = AppColors.textSecondary;
        label = AppConstants.questionStatusPending;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(AppDimensions.opacityLow),
        borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
        border: Border.all(
          color: color.withOpacity(AppDimensions.opacityBorder),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
