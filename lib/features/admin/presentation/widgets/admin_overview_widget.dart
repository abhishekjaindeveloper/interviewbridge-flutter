import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';

class AdminOverviewWidget extends StatefulWidget {
  final Function(int) onNavigate;

  const AdminOverviewWidget({
    super.key,
    required this.onNavigate,
  });

  @override
  State<AdminOverviewWidget> createState() => _AdminOverviewWidgetState();
}

class _AdminOverviewWidgetState extends State<AdminOverviewWidget> {
  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  void _loadStatistics() {
    context.read<AdminBloc>().add(LoadAdminStatistics());
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final weekDays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    final weekDay = weekDays[now.weekday - 1];
    final month = months[now.month - 1];
    return '$weekDay, $month ${now.day}, ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    // Read state values
    final authState = context.watch<AuthBloc>().state;
    String adminName = 'Admin';
    if (authState is Authenticated) {
      adminName = authState.user.name;
    }

    final adminState = context.watch<AdminBloc>().state;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Welcome Banner Card
          _buildWelcomeBanner(adminName),
          const SizedBox(height: AppSpacing.lg),

          // 2. Summary Statistics Section
          if (adminState is AdminError)
            _buildErrorState(adminState.message)
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth < 600 ? 2 : 4;
                final childAspectRatio = constraints.maxWidth < 600 ? 1.2 : 1.4;

                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.md,
                  childAspectRatio: childAspectRatio,
                  children: [
                    _buildStatCard(
                      title: AppConstants.adminTotalUsers,
                      icon: Icons.group_outlined,
                      iconColor: AppColors.primary,
                      state: adminState,
                      countExtractor: (state) {
                        if (state is AdminStatisticsLoaded) {
                          return state.statistics.totalUsers.toString();
                        }
                        return null;
                      },
                    ),
                    _buildStatCard(
                      title: AppConstants.adminActiveUsers,
                      icon: Icons.check_circle_outline,
                      iconColor: AppColors.success,
                      state: adminState,
                      countExtractor: (state) {
                        if (state is AdminStatisticsLoaded) {
                          return state.statistics.activeUsers.toString();
                        }
                        return null;
                      },
                    ),
                    _buildStatCard(
                      title: AppConstants.adminInactiveUsers,
                      icon: Icons.block_outlined,
                      iconColor: AppColors.error,
                      state: adminState,
                      countExtractor: (state) {
                        if (state is AdminStatisticsLoaded) {
                          return state.statistics.inactiveUsers.toString();
                        }
                        return null;
                      },
                    ),
                    _buildStatCard(
                      title: AppConstants.adminTotalPendingUsers,
                      icon: Icons.people_outline,
                      iconColor: AppColors.warning,
                      state: adminState,
                      countExtractor: (state) {
                        if (state is AdminStatisticsLoaded) {
                          return state.statistics.pendingUsers.toString();
                        }
                        return null;
                      },
                    ),
                  ],
                );
              },
            ),
          const SizedBox(height: AppSpacing.xl),

          // 3. Quick Actions Section
          Text(
            AppConstants.adminQuickActions,
            style: AppTypography.headingSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildQuickActionsList(),
        ],
      ),
    );
  }

  Widget _buildWelcomeBanner(String adminName) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.7),
            AppColors.secondary.withValues(alpha: 0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          const Positioned(
            right: -20,
            bottom: -20,
            child: Opacity(
              opacity: 0.15,
              child: Icon(
                Icons.admin_panel_settings,
                size: 160,
                color: AppColors.white,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${AppConstants.adminWelcomeBack} ',
                      style: AppTypography.headingMedium.copyWith(
                        color: AppColors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    const Text(
                      '👋',
                      style: TextStyle(fontSize: 24),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  adminName,
                  style: AppTypography.headingLarge.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _getFormattedDate(),
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.white.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                const Divider(color: Colors.white24),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  AppConstants.adminSystemSummary,
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required dynamic state,
    required String? Function(dynamic) countExtractor,
  }) {
    final count = countExtractor(state);
    final isLoading = count == null && (state is AdminLoading || state is AdminInitial);

    return Card(
      color: AppColors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: AppDimensions.opacityLow),
                    borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 24,
                  ),
                ),
                if (isLoading)
                  const SkeletonLoader(width: 40, height: 24)
                else
                  Text(
                    count ?? '0',
                    style: AppTypography.headingMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              title,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Card(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppColors.error),
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            const Row(
              children: [
                Icon(Icons.error_outline, color: AppColors.error),
                SizedBox(width: AppSpacing.sm),
                Text(
                  'Failed to load statistics',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: AppTypography.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton.icon(
              onPressed: _loadStatistics,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsList() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 600;

        final children = [
          _buildQuickActionCard(
            title: AppConstants.adminActionReviewPending,
            subtitle: 'Approve or reject candidate registrations',
            icon: Icons.people_outline,
            color: AppColors.warning,
            onTap: () => widget.onNavigate(1),
          ),
          _buildQuickActionCard(
            title: AppConstants.menuManageUsers,
            subtitle: 'Activate, deactivate, and search user accounts',
            icon: Icons.manage_accounts_outlined,
            color: AppColors.success,
            onTap: () => widget.onNavigate(2),
          ),
          _buildQuickActionCard(
            title: AppConstants.adminActionManageTech,
            subtitle: 'Configure available technology tags',
            icon: Icons.code,
            color: AppColors.primary,
            onTap: () => widget.onNavigate(3),
          ),
          _buildQuickActionCard(
            title: AppConstants.adminActionManageExp,
            subtitle: 'Update candidate practice levels',
            icon: Icons.trending_up,
            color: AppColors.secondary,
            onTap: () => widget.onNavigate(4),
          ),
        ];

        if (isWide) {
          return GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            childAspectRatio: 2.8,
            children: children,
          );
        } else {
          return Column(
            children: children.map((card) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: card,
            )).toList(),
          );
        }
      },
    );
  }

  Widget _buildQuickActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return HoverScaleWidget(
      onTap: onTap,
      child: Card(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.lg,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: AppDimensions.opacityLow),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTypography.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HoverScaleWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const HoverScaleWidget({
    super.key,
    required this.child,
    this.onTap,
  });

  @override
  State<HoverScaleWidget> createState() => _HoverScaleWidgetState();
}

class _HoverScaleWidgetState extends State<HoverScaleWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        child: AnimatedScale(
          scale: _isHovered ? 1.02 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          child: widget.child,
        ),
      ),
    );
  }
}

class SkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 4.0,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 0.8).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
          ),
        );
      },
    );
  }
}