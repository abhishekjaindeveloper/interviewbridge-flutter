// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/constants/app_constants.dart';

class AnswerInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  final String? errorText;

  const AnswerInputWidget({
    super.key,
    required this.controller,
    required this.enabled,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
            border: Border.all(
              color: errorText != null
                  ? AppColors.error
                  : AppColors.border.withOpacity(AppDimensions.opacityBorder),
              width: errorText != null ? 1.5 : 1.0,
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: TextField(
            controller: controller,
            maxLines: 8,
            minLines: 4,
            enabled: enabled,
            maxLength: 5000,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: AppConstants.answerInputPlaceholder,
              hintStyle: TextStyle(color: AppColors.textSecondary),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Text(
              errorText!,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.error,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ],
    );
  }
}