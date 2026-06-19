import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class AuthFooterWidget extends StatelessWidget {
  final String message;
  final String actionText;
  final VoidCallback onTap;

  const AuthFooterWidget({
    super.key,
    required this.message,
    required this.actionText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: message,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          children: [
            TextSpan(
              text: ' $actionText',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
