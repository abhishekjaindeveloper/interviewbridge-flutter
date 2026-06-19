import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class AdminProfilePage extends StatelessWidget {
  final VoidCallback onLogout;
  const AdminProfilePage({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    String name = 'Admin';
    String email = 'admin@example.com';
    String phoneNumber = AppConstants.notAvailablePlaceholder;
    String role = AppConstants.adminRoleLabel;
    String status = AppConstants.adminStatusActive;

    if (authState is Authenticated) {
      name = authState.user.name;
      email = authState.user.email;
      phoneNumber = authState.user.phoneNumber.isNotEmpty
          ? authState.user.phoneNumber
          : AppConstants.notAvailablePlaceholder;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: AppDimensions.maxContentWidth,
            ),
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Avatar & Profile Header
                Card(
                  color: AppColors.surface,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: AppColors.border),
                    borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                          child: CircleAvatar(
                            radius: 42,
                            backgroundColor: AppColors.primary,
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : 'A',
                              style: AppTypography.headingLarge.copyWith(
                                color: AppColors.white,
                                fontSize: 36,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          name,
                          style: AppTypography.headingMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            role,
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.primaryLight,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // 2. Profile Details Section
                Card(
                  color: AppColors.surface,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: AppColors.border),
                    borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppConstants.adminProfileTitle,
                          style: AppTypography.headingSmall.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Divider(color: AppColors.border, height: 1),
                        const SizedBox(height: AppSpacing.md),
                        _buildProfileField(
                          label: AppConstants.profileLabelName,
                          value: name,
                          icon: Icons.person_outline,
                        ),
                        _buildProfileField(
                          label: AppConstants.profileLabelEmail,
                          value: email,
                          icon: Icons.email_outlined,
                        ),
                        _buildProfileField(
                          label: AppConstants.profileLabelPhone,
                          value: phoneNumber,
                          icon: Icons.phone_android_outlined,
                        ),
                        _buildProfileField(
                          label: AppConstants.profileLabelRole,
                          value: role,
                          icon: Icons.badge_outlined,
                        ),
                        _buildProfileField(
                          label: AppConstants.profileLabelStatus,
                          value: status,
                          icon: Icons.verified_user_outlined,
                          isStatus: true,
                        ),
                        _buildProfileField(
                          label: AppConstants.profileLabelCreated,
                          value: AppConstants.adminJoinedDate,
                          icon: Icons.calendar_today_outlined,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // 3. Actions Card
                Card(
                  color: AppColors.surface,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: AppColors.border),
                    borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () {
                            // Future-ready edit profile callback placeholder
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppDimensions.inputRadius,
                              ),
                            ),
                          ),
                          icon: const Icon(Icons.edit_outlined),
                          label: Text(
                            AppConstants.btnEditProfile,
                            style: AppTypography.bodyLarge.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        OutlinedButton.icon(
                          onPressed: () {
                            // Future-ready change password callback placeholder
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppDimensions.inputRadius,
                              ),
                            ),
                          ),
                          icon: const Icon(Icons.lock_outline),
                          label: Text(
                            AppConstants.btnChangePassword,
                            style: AppTypography.bodyLarge.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        ElevatedButton.icon(
                          onPressed: onLogout,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                            foregroundColor: AppColors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppDimensions.inputRadius,
                              ),
                            ),
                          ),
                          icon: const Icon(Icons.logout),
                          label: Text(
                            AppConstants.menuLogout,
                            style: AppTypography.bodyLarge.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileField({
    required String label,
    required String value,
    required IconData icon,
    bool isStatus = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.bodyMedium.copyWith(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                if (isStatus)
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      value,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  )
                else
                  Text(
                    value,
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}