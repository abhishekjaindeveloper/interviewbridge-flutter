// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_dimensions.dart';

class AuthHeaderWidget extends StatelessWidget {
  final String title;
  final String subtitle;

  const AuthHeaderWidget({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Premium brand icon/logo placeholder
        Container(
          height: AppDimensions.logoSize,
          width: AppDimensions.logoSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.secondary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(AppDimensions.opacityHigh),
                blurRadius: AppSpacing.md,
                offset: const Offset(0, AppDimensions.shadowDYSmall),
              ),
            ],
          ),
          child: const Icon(
            Icons.school,
            color: AppColors.white,
            size: AppDimensions.iconMedium,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          title,
          style: AppTypography.headingLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          subtitle,
          style: AppTypography.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
