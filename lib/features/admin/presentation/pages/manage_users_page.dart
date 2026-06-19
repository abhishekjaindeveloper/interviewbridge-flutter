import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/error_dialog.dart';
import '../../domain/entities/admin_entity.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';

class ManageUsersPage extends StatefulWidget {
  const ManageUsersPage({super.key});

  @override
  State<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  final TextEditingController _searchController = TextEditingController();
  int _page = 0;
  final int _size = 10;
  String _selectedFilter = AppConstants.filterAll;
  
  String? _searchQuery;
  String? _approvalStatusFilter;
  bool? _isActiveFilter;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadUsers() {
    context.read<AdminBloc>().add(
          LoadUsersList(
            page: _page,
            size: _size,
            search: _searchQuery,
            approvalStatus: _approvalStatusFilter,
            isActive: _isActiveFilter,
          ),
        );
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value.trim().isEmpty ? null : value.trim();
      _page = 0; // Reset to first page
    });
    _loadUsers();
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
      _page = 0; // Reset to first page

      if (filter == AppConstants.filterAll) {
        _approvalStatusFilter = null;
        _isActiveFilter = null;
      } else if (filter == AppConstants.filterActive) {
        _approvalStatusFilter = null;
        _isActiveFilter = true;
      } else if (filter == AppConstants.filterInactive) {
        _approvalStatusFilter = null;
        _isActiveFilter = false;
      } else if (filter == AppConstants.filterPending) {
        _approvalStatusFilter = 'PENDING';
        _isActiveFilter = null;
      }
    });
    _loadUsers();
  }

  void _showStatusToggleConfirmation(AdminEntity user, bool newStatus) {
    final title = newStatus
        ? AppConstants.activateUserDialogTitle
        : AppConstants.deactivateUserDialogTitle;
    final message = newStatus
        ? AppConstants.activateUserDialogMessage
        : AppConstants.deactivateUserDialogMessage;
    final confirmBtnLabel = newStatus
        ? AppConstants.activateButtonLabel
        : AppConstants.deactivateButtonLabel;
    final themeColor = newStatus ? AppColors.success : AppColors.error;

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
                    color: themeColor.withValues(alpha: AppDimensions.opacityLow),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    newStatus ? Icons.check_circle_outline : Icons.block_outlined,
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
                          backgroundColor: themeColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          if (newStatus) {
                            context.read<AdminBloc>().add(ActivateUserAccount(user.id));
                          } else {
                            context.read<AdminBloc>().add(DeactivateUserAccount(user.id));
                          }
                        },
                        child: Text(
                          confirmBtnLabel,
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

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return AppConstants.notAvailablePlaceholder;
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dateTime.day} ${months[dateTime.month - 1]}, ${dateTime.year}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AdminBloc, AdminState>(
      listener: (context, state) {
        if (state is UserStatusToggledSuccess) {
          ErrorDialog.show(
            context: context,
            title: AppConstants.dialogTitleSuccess,
            message: state.message,
            type: DialogType.success,
          );
          _loadUsers();
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 768;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Search & Filter Header Card
              Card(
                color: AppColors.surface,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: AppColors.border),
                  borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Search field
                      TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        decoration: InputDecoration(
                          hintText: AppConstants.userSearchHint,
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: AppColors.background,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
                            borderSide: BorderSide(color: AppColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
                            borderSide: BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
                            borderSide: const BorderSide(color: AppColors.primary),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      // Filter chips scroll list
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            AppConstants.filterAll,
                            AppConstants.filterActive,
                            AppConstants.filterInactive,
                            AppConstants.filterPending,
                          ].map((filter) {
                            final isSelected = _selectedFilter == filter;
                            return Padding(
                              padding: const EdgeInsets.only(right: AppSpacing.xs),
                              child: ChoiceChip(
                                label: Text(filter),
                                selected: isSelected,
                                onSelected: (_) => _onFilterChanged(filter),
                                selectedColor: AppColors.primary,
                                labelStyle: AppTypography.bodyMedium.copyWith(
                                  color: isSelected ? AppColors.white : AppColors.textPrimary,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              // User list area
              Expanded(
                child: BlocBuilder<AdminBloc, AdminState>(
                  buildWhen: (previous, current) =>
                      current is AdminUsersListLoading ||
                      current is AdminUsersListLoaded ||
                      current is AdminUsersListError,
                  builder: (context, state) {
                    if (state is AdminUsersListLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is AdminUsersListError) {
                      return _buildErrorState(state.message);
                    }
                    if (state is AdminUsersListLoaded) {
                      final paginated = state.paginatedUsers;
                      if (paginated.content.isEmpty) {
                        return _buildEmptyState();
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: isMobile
                                ? _buildMobileList(paginated.content)
                                : _buildDesktopTable(paginated.content),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _buildPaginationControls(
                            paginated.pageNumber,
                            paginated.totalPages,
                          ),
                        ],
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDesktopTable(List<AdminEntity> users) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Card(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        ),
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(AppColors.surfaceLight),
          columns: const [
            DataColumn(label: Text(AppConstants.columnUserName)),
            DataColumn(label: Text(AppConstants.columnUserEmail)),
            DataColumn(label: Text(AppConstants.columnUserPhone)),
            DataColumn(label: Text(AppConstants.columnUserRole)),
            DataColumn(label: Text(AppConstants.columnUserApproval)),
            DataColumn(label: Text(AppConstants.columnUserStatus)),
            DataColumn(label: Text(AppConstants.columnUserCreated)),
          ],
          rows: users.map((user) {
            return DataRow(
              cells: [
                DataCell(Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                DataCell(Text(user.email)),
                DataCell(Text(user.phoneNumber ?? AppConstants.notAvailablePlaceholder)),
                DataCell(Text(user.role.replaceAll('ROLE_', ''))),
                DataCell(_buildApprovalChip(user.approvalStatus)),
                DataCell(
                  Switch(
                    value: user.isActive,
                    onChanged: (val) => _showStatusToggleConfirmation(user, val),
                    activeThumbColor: AppColors.success,
                  ),
                ),
                DataCell(Text(_formatDate(user.createdAt))),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMobileList(List<AdminEntity> users) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return Card(
          color: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: AppColors.border),
            borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          ),
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      user.name,
                      style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                    ),
                    _buildApprovalChip(user.approvalStatus),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  user.email,
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                ),
                if (user.phoneNumber != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    user.phoneNumber!,
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                  ),
                ],
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Role: ${user.role.replaceAll('ROLE_', '')}',
                      style: AppTypography.bodyMedium,
                    ),
                    Row(
                      children: [
                        Text(
                          user.isActive ? AppConstants.filterActive : AppConstants.filterInactive,
                          style: AppTypography.bodyMedium.copyWith(
                            color: user.isActive ? AppColors.success : AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Switch(
                          value: user.isActive,
                          onChanged: (val) => _showStatusToggleConfirmation(user, val),
                          activeThumbColor: AppColors.success,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Registered: ${_formatDate(user.createdAt)}',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildApprovalChip(String status) {
    Color chipColor;
    Color textColor;
    if (status == 'APPROVED') {
      chipColor = AppColors.success.withValues(alpha: AppDimensions.opacityLow);
      textColor = AppColors.success;
    } else if (status == 'PENDING') {
      chipColor = AppColors.warning.withValues(alpha: AppDimensions.opacityLow);
      textColor = AppColors.warning;
    } else {
      chipColor = AppColors.error.withValues(alpha: AppDimensions.opacityLow);
      textColor = AppColors.error;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildPaginationControls(int currentPage, int totalPages) {
    final hasPrev = currentPage > 0;
    final hasNext = currentPage < totalPages - 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton.icon(
          onPressed: hasPrev
              ? () {
                  setState(() {
                    _page = currentPage - 1;
                  });
                  _loadUsers();
                }
              : null,
          icon: const Icon(Icons.chevron_left),
          label: const Text('< Previous'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
          ),
        ),
        Text(
          'Page ${currentPage + 1} of ${totalPages == 0 ? 1 : totalPages}',
          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
        ),
        TextButton.icon(
          onPressed: hasNext
              ? () {
                  setState(() {
                    _page = currentPage + 1;
                  });
                  _loadUsers();
                }
              : null,
          icon: const Icon(Icons.chevron_right),
          label: const Text('Next >'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.group_off_outlined, size: 64, color: AppColors.textSecondary),
          const SizedBox(height: AppSpacing.md),
          Text(
            AppConstants.noUsersFound,
            style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: AppSpacing.md),
          Text(
            message,
            style: AppTypography.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          ElevatedButton.icon(
            onPressed: _loadUsers,
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
    );
  }
}
