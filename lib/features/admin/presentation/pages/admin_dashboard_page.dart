import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:interview_bridge_app/injection_container.dart';
import 'package:interview_bridge_app/features/admin/presentation/bloc/admin_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../widgets/pending_users_widget.dart';
import '../../../technology/presentation/bloc/technology_bloc.dart';
import '../../../technology/presentation/bloc/technology_event.dart';
import '../../../experience/presentation/bloc/experience_bloc.dart';
import '../../../experience/presentation/bloc/experience_event.dart';
import '../widgets/technology_master_widget.dart';
import '../widgets/experience_master_widget.dart';

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

  void _onLogout() {
    context.read<AuthBloc>().add(LogoutRequested());
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

          return LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < AppDimensions.maxContentWidth;

              if (isMobile) {
                return _buildMobileLayout(adminName, adminEmail);
              } else {
                return _buildDesktopLayout(adminName, adminEmail);
              }
            },
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
          activeOption['title'] as String,
          style: AppTypography.headingSmall,
        ),
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.account_circle, color: AppColors.textPrimary),
            onSelected: (value) {
              if (value == 4) {
                _onMenuSelected(4); // Profile
              } else if (value == 5) {
                _onLogout();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 4,
                child: Text(
                  AppConstants.menuProfile,
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
                ),
              ),
              PopupMenuItem(
                value: 5,
                child: Text(
                  AppConstants.menuLogout,
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.error),
                ),
              ),
            ],
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: AppColors.surface,
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: AppColors.surfaceLight),
              accountName: Text(
                adminName,
                style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
              ),
              accountEmail: Text(
                adminEmail,
                style: AppTypography.bodyMedium,
              ),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Icon(Icons.admin_panel_settings, color: AppColors.white),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _menuOptions.length,
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
            const Divider(color: AppColors.border),
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
            decoration: const BoxDecoration(
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
                const Divider(color: AppColors.border),
                // Menu Items
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: _menuOptions.length,
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
                // Profile & Logout Footer Section
                const Divider(color: AppColors.border),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: AppColors.primary,
                        child: Icon(Icons.admin_panel_settings, color: AppColors.white),
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
                              adminEmail,
                              style: AppTypography.bodyMedium,
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
                child: _buildMainContent(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    if (_currentIndex == 1) {
      return const PendingUsersWidget();
    }
    if (_currentIndex == 2) {
      return const TechnologyMasterWidget();
    }
    if (_currentIndex == 3) {
      return const ExperienceMasterWidget();
    }
    final activeOption = _menuOptions[_currentIndex];
    return Center(
      child: Card(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppColors.border),
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
