// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_dimensions.dart';

class AuthCardWidget extends StatelessWidget {
  final Widget child;

  const AuthCardWidget({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: AppDimensions.maxContentWidth,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
            border: Border.all(
              color: AppColors.border.withOpacity(AppDimensions.opacityBorder),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withOpacity(AppDimensions.opacityMedium),
                blurRadius: AppSpacing.lg,
                offset: const Offset(0, AppDimensions.shadowDYMedium),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: child,
          ),
        ),
      ),
    );
  }
}
