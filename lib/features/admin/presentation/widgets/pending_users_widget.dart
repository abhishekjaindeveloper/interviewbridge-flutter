// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/error_dialog.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';
import '../../domain/entities/admin_entity.dart';

class PendingUsersWidget extends StatefulWidget {
  const PendingUsersWidget({super.key});

  @override
  State<PendingUsersWidget> createState() => _PendingUsersWidgetState();
}

class _PendingUsersWidgetState extends State<PendingUsersWidget> {
  List<AdminEntity>? _users;

  @override
  void initState() {
    super.initState();
    _loadPendingUsers();
  }

  void _loadPendingUsers() {
    context.read<AdminBloc>().add(LoadPendingUsers());
  }

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return AppConstants.notAvailablePlaceholder;
    final year = dateTime.year;
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  void _confirmAction(BuildContext context, AdminEntity user, bool isApproval) {
    final adminBloc = context.read<AdminBloc>();
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: AppColors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Dialog(
          backgroundColor: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: AppColors.border),
            borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          ),
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: AppDimensions.maxContentWidth,
            ),
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(AppDimensions.opacityLow),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.help_outline,
                    color: AppColors.warning,
                    size: AppDimensions.iconMedium,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  AppConstants.adminConfirmActionTitle,
                  style: AppTypography.headingSmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  isApproval
                      ? '${AppConstants.adminApproveConfirmMsg}\n\n${user.name}\n${user.email}'
                      : '${AppConstants.adminRejectConfirmMsg}\n\n${user.name}\n${user.email}',
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
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          AppConstants.adminCancelButton,
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
                          backgroundColor: isApproval ? AppColors.success : AppColors.error,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          if (isApproval) {
                            adminBloc.add(ApproveUser(user.id));
                          } else {
                            adminBloc.add(RejectUser(user.id));
                          }
                        },
                        child: Text(
                          AppConstants.adminConfirmButton,
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
    return BlocConsumer<AdminBloc, AdminState>(
      listener: (context, state) {
        if (state is AdminLoaded) {
          setState(() {
            _users = state.pendingUsers;
          });
        } else if (state is AdminActionSuccess) {
          ErrorDialog.show(
            context: context,
            title: AppConstants.dialogTitleSuccess,
            message: state.message,
            type: DialogType.success,
          );
        } else if (state is AdminError) {
          if (_users != null) {
            ErrorDialog.show(
              context: context,
              title: AppConstants.dialogTitleError,
              message: state.message,
              type: DialogType.error,
            );
          }
        }
      },
      builder: (context, state) {
        final isLoading = state is AdminLoading || state is AdminInitial;

        // 1. Initial Loading State (Shimmer)
        if (isLoading && _users == null) {
          return _buildShimmerLoader();
        }

        // 2. Error State (Initial load failure)
        if (state is AdminError && _users == null) {
          return _buildErrorState(state.message);
        }

        final usersList = _users ?? [];

        // 3. Empty State UI
        if (usersList.isEmpty) {
          return _buildEmptyState();
        }

        // 4. Normal Loaded Content
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isLoading)
              const Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.sm),
                child: LinearProgressIndicator(
                  color: AppColors.primary,
                  backgroundColor: Colors.transparent,
                ),
              ),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                backgroundColor: AppColors.surface,
                onRefresh: () async {
                  _loadPendingUsers();
                },
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 600;
                    if (isWide) {
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          _buildTableLayout(context, usersList, isLoading),
                        ],
                      );
                    } else {
                      return _buildCardLayout(usersList, isLoading);
                    }
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildShimmerLoader() {
    return ListView.builder(
      itemCount: 4,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) => const _ShimmerCard(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight.withOpacity(AppDimensions.opacityLow),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.people_outline,
              color: AppColors.textSecondary,
              size: AppDimensions.iconLarge,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            AppConstants.adminNoPendingUsers,
            style: AppTypography.headingSmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          TextButton.icon(
            onPressed: _loadPendingUsers,
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            label: const Text(
              AppConstants.adminRetryButton,
              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(AppDimensions.opacityLow),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: AppColors.error,
                size: AppDimensions.iconLarge,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              AppConstants.adminLoadPendingFailed,
              style: AppTypography.headingSmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
                ),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              ),
              onPressed: _loadPendingUsers,
              icon: const Icon(Icons.refresh, color: AppColors.white),
              label: Text(
                AppConstants.adminRetryButton,
                style: AppTypography.bodyLarge.copyWith(color: AppColors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardLayout(List<AdminEntity> users, bool actionsDisabled) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: users.length,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        final user = users[index];
        return Card(
          color: AppColors.surface,
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: AppColors.border),
            borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        user.name,
                        style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        user.approvalStatus,
                        style: const TextStyle(
                          color: AppColors.warning,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                _buildCardField(Icons.email_outlined, AppConstants.emailLabel, user.email),
                const SizedBox(height: AppSpacing.xs),
                _buildCardField(Icons.phone_outlined, AppConstants.phoneNumberLabel, user.phoneNumber ?? 'N/A'),
                const SizedBox(height: AppSpacing.xs),
                _buildCardField(Icons.calendar_today_outlined, AppConstants.adminRegistrationDateLabel, _formatDate(user.createdAt)),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.error),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
                          ),
                        ),
                        onPressed: actionsDisabled ? null : () => _confirmAction(context, user, false),
                        child: Text(
                          AppConstants.adminRejectButton,
                          style: AppTypography.bodyMedium.copyWith(color: AppColors.error, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
                          ),
                        ),
                        onPressed: actionsDisabled ? null : () => _confirmAction(context, user, true),
                        child: Text(
                          AppConstants.adminApproveButton,
                          style: AppTypography.bodyMedium.copyWith(color: AppColors.white, fontWeight: FontWeight.bold),
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
    );
  }

  Widget _buildCardField(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '$label: ',
          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildTableLayout(BuildContext context, List<AdminEntity> users, bool actionsDisabled) {
    return Card(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        child: Theme(
          data: Theme.of(context).copyWith(
            cardColor: AppColors.surface,
            dividerColor: AppColors.border,
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(AppColors.surfaceLight.withOpacity(0.3)),
              dataRowColor: MaterialStateProperty.all(AppColors.surface),
              border: TableBorder.all(color: AppColors.border.withOpacity(0.2), width: 1),
              columns: const [
                DataColumn(label: Text('Name', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Email', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Phone Number', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Registration Date', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Status', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Actions', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold))),
              ],
              rows: users.map((user) {
                return DataRow(
                  cells: [
                    DataCell(Text(user.name, style: const TextStyle(color: AppColors.textPrimary))),
                    DataCell(Text(user.email, style: const TextStyle(color: AppColors.textPrimary))),
                    DataCell(Text(user.phoneNumber ?? 'N/A', style: const TextStyle(color: AppColors.textSecondary))),
                    DataCell(Text(_formatDate(user.createdAt), style: const TextStyle(color: AppColors.textSecondary))),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          user.approvalStatus,
                          style: const TextStyle(color: AppColors.warning, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: actionsDisabled ? null : () => _confirmAction(context, user, true),
                            icon: const Icon(Icons.check_circle_outline, color: AppColors.success),
                            tooltip: AppConstants.adminApproveButton,
                          ),
                          IconButton(
                            onPressed: actionsDisabled ? null : () => _confirmAction(context, user, false),
                            icon: const Icon(Icons.cancel_outlined, color: AppColors.error),
                            tooltip: AppConstants.adminRejectButton,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _ShimmerCard extends StatefulWidget {
  const _ShimmerCard();

  @override
  State<_ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<_ShimmerCard> with SingleTickerProviderStateMixin {
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
          child: Card(
            color: AppColors.surface,
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: AppColors.border),
              borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 140,
                        height: 18,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      Container(
                        width: 80,
                        height: 18,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    width: 260,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    width: 200,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    width: 160,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
