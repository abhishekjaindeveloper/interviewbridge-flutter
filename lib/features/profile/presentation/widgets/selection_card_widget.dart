// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_dimensions.dart';

class SelectionCardWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const SelectionCardWidget({
    super.key,
    required this.title,
    this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(AppDimensions.opacityLow)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.border.withOpacity(AppDimensions.opacityBorder),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(AppDimensions.opacityHigh),
                    blurRadius: AppSpacing.md,
                    offset: const Offset(0, AppDimensions.shadowDYSmall),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.primaryLight : AppColors.textPrimary,
                    ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      subtitle!,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Container(
              height: AppSpacing.xl,
              width: AppSpacing.xl,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  width: 2,
                ),
                color: isSelected ? AppColors.primary : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: AppSpacing.md,
                      color: AppColors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
