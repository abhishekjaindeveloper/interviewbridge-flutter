import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';
import '../theme/app_dimensions.dart';
import '../constants/app_constants.dart';
import '../routes/route_constants.dart';
import 'theme_selection_bottom_sheet.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/bloc/auth_event.dart';

class UserDrawer extends StatelessWidget {
  final String currentRoute;
  final BuildContext parentContext;

  const UserDrawer({
    super.key,
    required this.currentRoute,
    required this.parentContext,
  });

  void _showLogoutConfirmationDialog(BuildContext context, AuthBloc authBloc) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: AppColors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (dialogContext, anim1, anim2) {
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
                    color: AppColors.error.withValues(alpha: AppDimensions.opacityLow),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: AppColors.error,
                    size: AppDimensions.iconMedium,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  AppConstants.logoutTitle,
                  style: AppTypography.headingSmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  AppConstants.logoutConfirmationMessage,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        child: Text(
                          AppConstants.cancelButtonLabel,
                          style: AppTypography.bodyLarge.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          authBloc.add(LogoutRequested());
                        },
                        child: Text(
                          AppConstants.logoutButtonLabel,
                          style: AppTypography.bodyLarge.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    String userName = 'User';
    String userRole = AppConstants.candidateLabel;
    if (authState is Authenticated) {
      userName = authState.user.name;
      userRole = AppConstants.formatRole(authState.user.role);
    }

    return Drawer(
      backgroundColor: AppColors.surface,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: AppColors.surfaceLight),
            accountName: Text(
              userName,
              style: AppTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            accountEmail: Text(
              userRole,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            currentAccountPicture: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: CircleAvatar(
                backgroundColor: AppColors.surface,
                backgroundImage: const AssetImage('assets/icon/app_icon.png'),
                onBackgroundImageError: (exception, stackTrace) {},
                child: Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                  style: AppTypography.headingMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
          ListTile(
            leading: Icon(
              currentRoute == RouteConstants.home
                  ? Icons.dashboard
                  : Icons.dashboard_outlined,
              color: currentRoute == RouteConstants.home
                  ? AppColors.primary
                  : AppColors.textSecondary,
            ),
            title: Text(
              AppConstants.menuDashboardLabel,
              style: AppTypography.bodyLarge.copyWith(
                color: currentRoute == RouteConstants.home
                    ? AppColors.primary
                    : AppColors.textPrimary,
                fontWeight: currentRoute == RouteConstants.home
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
            onTap: () {
              Navigator.of(context).pop();
              if (currentRoute != RouteConstants.home) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
          ),
          ListTile(
            leading: Icon(
              currentRoute == RouteConstants.sessionStart
                  ? Icons.forum
                  : Icons.forum_outlined,
              color: currentRoute == RouteConstants.sessionStart
                  ? AppColors.primary
                  : AppColors.textSecondary,
            ),
            title: Text(
              'Practice Session',
              style: AppTypography.bodyLarge.copyWith(
                color: currentRoute == RouteConstants.sessionStart
                    ? AppColors.primary
                    : AppColors.textPrimary,
                fontWeight: currentRoute == RouteConstants.sessionStart
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
            onTap: () {
              Navigator.of(context).pop();
              if (currentRoute != RouteConstants.sessionStart) {
                Navigator.of(context).popUntil((route) => route.isFirst);
                Navigator.of(context).pushNamed(RouteConstants.sessionStart);
              }
            },
          ),
          ListTile(
            leading: Icon(
              Icons.history_rounded,
              color: currentRoute == RouteConstants.sessionHistory
                  ? AppColors.primary
                  : AppColors.textSecondary,
            ),
            title: Text(
              AppConstants.menuSessionHistoryLabel,
              style: AppTypography.bodyLarge.copyWith(
                color: currentRoute == RouteConstants.sessionHistory
                    ? AppColors.primary
                    : AppColors.textPrimary,
                fontWeight: currentRoute == RouteConstants.sessionHistory
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
            onTap: () {
              Navigator.of(context).pop();
              if (currentRoute != RouteConstants.sessionHistory) {
                Navigator.of(context).popUntil((route) => route.isFirst);
                Navigator.of(context).pushNamed(RouteConstants.sessionHistory);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.palette_outlined, color: AppColors.primary),
            title: Text(
              AppConstants.themeLabel,
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              Navigator.of(context).pop();
              showThemeSelectionBottomSheet(parentContext);
            },
          ),
          const Spacer(),
          Divider(color: AppColors.border),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: Text(
              AppConstants.menuLogout,
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              final authBloc = context.read<AuthBloc>();
              Navigator.of(context).pop();
              _showLogoutConfirmationDialog(parentContext, authBloc);
            },
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}