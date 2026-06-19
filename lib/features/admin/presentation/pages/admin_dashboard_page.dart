import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:interview_bridge_app/injection_container.dart';
import 'package:interview_bridge_app/features/admin/presentation/bloc/admin_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/theme_selection_bottom_sheet.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../widgets/pending_users_widget.dart';
import '../widgets/admin_overview_widget.dart';
import '../../../technology/presentation/bloc/technology_bloc.dart';
import '../../../technology/presentation/bloc/technology_event.dart';
import '../../../experience/presentation/bloc/experience_bloc.dart';
import '../../../experience/presentation/bloc/experience_event.dart';
import '../widgets/technology_master_widget.dart';
import '../widgets/experience_master_widget.dart';
import 'admin_profile_page.dart';
import 'manage_users_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _menuOptions = [
    {
      'title': AppConstants.menuDashboard,
      'icon': Icons.dashboard_outlined,
      'activeIcon': Icons.dashboard,
      'placeholder': AppConstants.placeholderDashboard,
    },
    {
      'title': AppConstants.menuPendingUsers,
      'icon': Icons.people_outline,
      'activeIcon': Icons.people,
      'placeholder': AppConstants.placeholderPendingUsers,
    },
    {
      'title': AppConstants.menuManageUsers,
      'icon': Icons.manage_accounts_outlined,
      'activeIcon': Icons.manage_accounts,
      'placeholder': AppConstants.placeholderManageUsers,
    },
    {
      'title': AppConstants.menuTechnologyMaster,
      'icon': Icons.code,
      'activeIcon': Icons.code_rounded,
      'placeholder': AppConstants.placeholderTechnologyMaster,
    },
    {
      'title': AppConstants.menuExperienceMaster,
      'icon': Icons.trending_up,
      'activeIcon': Icons.trending_up_rounded,
      'placeholder': AppConstants.placeholderExperienceMaster,
    },
    {
      'title': AppConstants.menuProfile,
      'icon': Icons.person_outline,
      'activeIcon': Icons.person,
      'placeholder': AppConstants.placeholderProfile,
    },
  ];

  void _onMenuSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Widget _buildProfileHeaderWidget(String adminName) {
    return InkWell(
      onTap: () => _onMenuSelected(5),
      borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  adminName,
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  AppConstants.administratorLabel,
                  style: AppTypography.bodyMedium.copyWith(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(width: AppSpacing.sm),
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary,
              child: Text(
                adminName.isNotEmpty ? adminName[0].toUpperCase() : 'A',
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
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
                          context.read<AuthBloc>().add(LogoutRequested());
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

  Future<bool?> _showExitConfirmationDialog(BuildContext context) {
    return showGeneralDialog<bool>(
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
                    color: AppColors.primary.withValues(alpha: AppDimensions.opacityLow),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.exit_to_app_rounded,
                    color: AppColors.primary,
                    size: AppDimensions.iconMedium,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  AppConstants.exitTitle,
                  style: AppTypography.headingSmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  AppConstants.exitMessage,
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
                        onPressed: () => Navigator.of(dialogContext).pop(false),
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
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(dialogContext).pop(true);
                        },
                        child: Text(
                          AppConstants.exitButtonLabel,
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

  void _onLogout() {
    _showLogoutConfirmationDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AdminBloc>(
          create: (_) => sl<AdminBloc>(),
        ),
        BlocProvider<TechnologyBloc>(
          create: (_) => sl<TechnologyBloc>()..add(LoadTechnologies()),
        ),
        BlocProvider<ExperienceBloc>(
          create: (_) => sl<ExperienceBloc>()..add(LoadExperiences()),
        ),
      ],
      child: Builder(
        builder: (context) {
          final authState = context.watch<AuthBloc>().state;
          String adminName = 'Admin';
          String adminEmail = 'admin@example.com';
          if (authState is Authenticated) {
            adminName = authState.user.name;
            adminEmail = authState.user.email;
          }

          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) async {
              if (didPop) return;
              if (_currentIndex != 0) {
                setState(() {
                  _currentIndex = 0;
                });
              } else {
                final shouldExit = await _showExitConfirmationDialog(context);
                if (shouldExit == true) {
                  SystemNavigator.pop();
                }
              }
            },
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < AppDimensions.maxContentWidth;

                if (isMobile) {
                  return _buildMobileLayout(adminName, adminEmail);
                } else {
                  return _buildDesktopLayout(adminName, adminEmail);
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildMobileLayout(String adminName, String adminEmail) {
    final activeOption = _menuOptions[_currentIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          _currentIndex == 0
              ? AppConstants.adminDashboardTitle
              : activeOption['title'] as String,
          style: AppTypography.headingSmall,
        ),
        actions: [
          _buildProfileHeaderWidget(adminName),
        ],
      ),
      drawer: Drawer(
        backgroundColor: AppColors.surface,
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: AppColors.surfaceLight),
              accountName: Text(
                adminName,
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              accountEmail: Text(
                AppConstants.administratorLabel,
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
                  backgroundImage: AssetImage('assets/icon/app_icon.png'),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _menuOptions.length - 1,
                itemBuilder: (context, index) {
                  final option = _menuOptions[index];
                  final isSelected = _currentIndex == index;
                  return ListTile(
                    leading: Icon(
                      (isSelected ? option['activeIcon'] : option['icon']) as IconData,
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    ),
                    title: Text(
                      option['title'] as String,
                      style: AppTypography.bodyLarge.copyWith(
                        color: isSelected ? AppColors.primary : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    onTap: () {
                      _onMenuSelected(index);
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
            Divider(color: AppColors.border),
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
                showThemeSelectionBottomSheet(context);
              },
            ),
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
                Navigator.of(context).pop();
                _onLogout();
              },
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: _buildMainContent(),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(String adminName, String adminEmail) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          // Sidebar Left Navigation
          Container(
            width: 280,
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(
                right: BorderSide(color: AppColors.border),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Branding Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.xl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppConstants.appName,
                        style: AppTypography.headingMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        AppConstants.adminDashboardTitle,
                        style: AppTypography.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Divider(color: AppColors.border),
                // Menu Items
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: _menuOptions.length - 1,
                    itemBuilder: (context, index) {
                      final option = _menuOptions[index];
                      final isSelected = _currentIndex == index;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                        child: InkWell(
                          onTap: () => _onMenuSelected(index),
                          borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.md,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(
                                AppDimensions.inputRadius,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  (isSelected ? option['activeIcon'] : option['icon']) as IconData,
                                  color: isSelected
                                      ? AppColors.white
                                      : AppColors.textSecondary,
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Text(
                                    option['title'] as String,
                                    style: AppTypography.bodyLarge.copyWith(
                                      color: isSelected
                                          ? AppColors.white
                                          : AppColors.textPrimary,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
                  child: InkWell(
                    onTap: () => showThemeSelectionBottomSheet(context),
                    borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.md,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.palette_outlined,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Text(
                            AppConstants.themeLabel,
                            style: AppTypography.bodyLarge.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Profile & Logout Footer Section
                Divider(color: AppColors.border),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: [
                      Container(
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
                          radius: 18,
                          backgroundColor: AppColors.surface,
                          backgroundImage: AssetImage('assets/icon/app_icon.png'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              adminName,
                              style: AppTypography.bodyLarge.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              AppConstants.administratorLabel,
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.primaryLight,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout, color: AppColors.error),
                        onPressed: _onLogout,
                        tooltip: AppConstants.menuLogout,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Right Main Content
          Expanded(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top Header Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _currentIndex == 0
                              ? AppConstants.adminDashboardTitle
                              : _menuOptions[_currentIndex]['title'] as String,
                          style: AppTypography.headingMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        _buildProfileHeaderWidget(adminName),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    // Main Content Area
                    Expanded(
                      child: _buildMainContent(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    if (_currentIndex == 0) {
      return AdminOverviewWidget(onNavigate: _onMenuSelected);
    }
    if (_currentIndex == 1) {
      return const PendingUsersWidget();
    }
    if (_currentIndex == 2) {
      return const ManageUsersPage();
    }
    if (_currentIndex == 3) {
      return const TechnologyMasterWidget();
    }
    if (_currentIndex == 4) {
      return const ExperienceMasterWidget();
    }
    if (_currentIndex == 5) {
      return AdminProfilePage(onLogout: _onLogout);
    }
    final activeOption = _menuOptions[_currentIndex];
    return Center(
      child: Card(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                activeOption['activeIcon'] as IconData,
                size: AppDimensions.iconLarge,
                color: AppColors.primary,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                activeOption['title'] as String,
                style: AppTypography.headingMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                activeOption['placeholder'] as String,
                style: AppTypography.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}