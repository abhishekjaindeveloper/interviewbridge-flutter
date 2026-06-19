// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';
import '../theme/app_dimensions.dart';
import '../constants/app_constants.dart';
import 'custom_button.dart';

enum DialogType {
  error,
  success,
  warning,
  info,
}

class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final DialogType type;
  final VoidCallback? onConfirm;

  static bool _isShowing = false;

  const ErrorDialog({
    super.key,
    required this.title,
    required this.message,
    this.type = DialogType.error,
    this.onConfirm,
  });

  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
    DialogType type = DialogType.error,
    VoidCallback? onConfirm,
  }) {
    if (_isShowing) return Future.value();
    _isShowing = true;

    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: AppColors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return ErrorDialog(
          title: title,
          message: message,
          type: type,
          onConfirm: onConfirm,
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        final curve = CurvedAnimation(parent: anim1, curve: Curves.easeOutBack);
        return ScaleTransition(
          scale: curve,
          child: FadeTransition(
            opacity: anim1,
            child: child,
          ),
        );
      },
    ).then((_) {
      _isShowing = false;
    });
  }

  IconData _getIcon() {
    switch (type) {
      case DialogType.success:
        return Icons.check_circle_outline;
      case DialogType.warning:
        return Icons.warning_amber_outlined;
      case DialogType.info:
        return Icons.info_outline;
      case DialogType.error:
        return Icons.error_outline;
    }
  }

  Color _getColor() {
    switch (type) {
      case DialogType.success:
        return AppColors.success;
      case DialogType.warning:
        return AppColors.warning;
      case DialogType.info:
        return AppColors.primary;
      case DialogType.error:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = _getColor();
    final themeIcon = _getIcon();

    return Dialog(
      backgroundColor: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
      ),
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: AppDimensions.maxContentWidth - 100,
        ),
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: themeColor.withOpacity(AppDimensions.opacityLow),
                shape: BoxShape.circle,
              ),
              child: Icon(
                themeIcon,
                color: themeColor,
                size: AppDimensions.iconMedium,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: AppTypography.headingSmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
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
            CustomButton(
              text: AppConstants.okButton,
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm?.call();
              },
            ),
          ],
        ),
      ),
    );
  }
}