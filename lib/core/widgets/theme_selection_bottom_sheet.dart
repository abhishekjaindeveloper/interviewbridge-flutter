import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../theme/theme_cubit.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';
import '../theme/app_dimensions.dart';
import '../constants/app_constants.dart';

void showThemeSelectionBottomSheet(BuildContext context) {
  final themeCubit = context.read<ThemeCubit>();
  final currentMode = themeCubit.state;

  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(AppDimensions.cardRadius),
        topRight: Radius.circular(AppDimensions.cardRadius),
      ),
    ),
    builder: (sheetContext) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppConstants.selectThemeTitle,
              style: AppTypography.headingSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildThemeOption(
              sheetContext,
              themeCubit: themeCubit,
              title: AppConstants.lightThemeLabel,
              icon: Icons.light_mode_outlined,
              mode: ThemeMode.light,
              isSelected: currentMode == ThemeMode.light,
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildThemeOption(
              sheetContext,
              themeCubit: themeCubit,
              title: AppConstants.darkThemeLabel,
              icon: Icons.dark_mode_outlined,
              mode: ThemeMode.dark,
              isSelected: currentMode == ThemeMode.dark,
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildThemeOption(
              sheetContext,
              themeCubit: themeCubit,
              title: AppConstants.systemThemeLabel,
              icon: Icons.settings_brightness_outlined,
              mode: ThemeMode.system,
              isSelected: currentMode == ThemeMode.system,
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      );
    },
  );
}

Widget _buildThemeOption(
  BuildContext context, {
  required ThemeCubit themeCubit,
  required String title,
  required IconData icon,
  required ThemeMode mode,
  required bool isSelected,
}) {
  return InkWell(
    onTap: () {
      Navigator.of(context).pop();
      Future.microtask(() => themeCubit.setTheme(mode));
    },
    borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
    child: Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              title,
              style: AppTypography.bodyLarge.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          if (isSelected)
            const Icon(
              Icons.check_circle_rounded,
              color: AppColors.primary,
            ),
        ],
      ),
    ),
  );
}
