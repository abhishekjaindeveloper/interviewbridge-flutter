// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/error_dialog.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../experience/presentation/bloc/experience_bloc.dart';
import '../../../experience/presentation/bloc/experience_event.dart';
import '../../../experience/presentation/bloc/experience_state.dart';
import '../../../experience/domain/entities/experience_entity.dart';

class ExperienceMasterWidget extends StatefulWidget {
  const ExperienceMasterWidget({super.key});

  @override
  State<ExperienceMasterWidget> createState() => _ExperienceMasterWidgetState();
}

class _ExperienceMasterWidgetState extends State<ExperienceMasterWidget> {
  final TextEditingController _searchController = TextEditingController();
  List<ExperienceEntity>? _experiences;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _labelController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadExperiences();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  void _loadExperiences() {
    context.read<ExperienceBloc>().add(LoadExperiences());
  }

  void _onSearchChanged() {
    setState(() {});
  }

  void _showAddEditDialog({ExperienceEntity? experience}) {
    final isEdit = experience != null;
    if (isEdit) {
      _labelController.text = experience.experienceLabel;
    } else {
      _labelController.clear();
    }
    final expBloc = context.read<ExperienceBloc>();

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: AppColors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (dialogContext, anim1, anim2) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        isEdit ? AppConstants.editExpTitle : AppConstants.addExpTitle,
                        style: AppTypography.headingSmall.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      CustomTextField(
                        controller: _labelController,
                        labelText: AppConstants.expLabelLabel,
                        hintText: AppConstants.expLabelLabel,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return AppConstants.expLabelRequired;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.of(dialogContext).pop(),
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
                            child: CustomButton(
                              text: AppConstants.btnSave,
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  Navigator.of(dialogContext).pop();
                                  if (isEdit) {
                                    expBloc.add(
                                      UpdateExperience(
                                        id: experience.id,
                                        label: _labelController.text.trim(),
                                      ),
                                    );
                                  } else {
                                    expBloc.add(
                                      CreateExperience(
                                        label: _labelController.text.trim(),
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
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

  void _confirmToggleStatus(ExperienceEntity experience) {
    final expBloc = context.read<ExperienceBloc>();
    final isActivating = !experience.isActive;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: AppColors.black.withOpacity(0.5),
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
                  isActivating
                      ? '${AppConstants.expActivateConfirmMsg}\n\n${experience.experienceLabel}'
                      : '${AppConstants.expDeactivateConfirmMsg}\n\n${experience.experienceLabel}',
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
                          backgroundColor: isActivating ? AppColors.success : AppColors.error,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          if (isActivating) {
                            expBloc.add(ActivateExperience(experience.id));
                          } else {
                            expBloc.add(DeactivateExperience(experience.id));
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
    return BlocConsumer<ExperienceBloc, ExperienceState>(
      listener: (context, state) {
        if (state is ExperienceLoaded) {
          setState(() {
            _experiences = state.experiences;
          });
        } else if (state is ExperienceActionSuccess) {
          ErrorDialog.show(
            context: context,
            title: AppConstants.dialogTitleSuccess,
            message: state.message,
            type: DialogType.success,
          );
        } else if (state is ExperienceError) {
          if (_experiences != null) {
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
        final isLoading = state is ExperienceLoading || state is ExperienceInitial;

        if (isLoading && _experiences == null) {
          return _buildShimmerLoader();
        }

        if (state is ExperienceError && _experiences == null) {
          return _buildErrorState(state.message);
        }

        final fullList = _experiences ?? [];
        final query = _searchController.text.trim().toLowerCase();
        final filteredList = fullList.where((exp) {
          if (query.isEmpty) return true;
          return exp.experienceLabel.toLowerCase().contains(query);
        }).toList();

        return Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: FloatingActionButton(
            backgroundColor: AppColors.primary,
            onPressed: () => _showAddEditDialog(),
            child: const Icon(Icons.add, color: AppColors.white),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Search and Filter Bar
              _buildSearchBar(),
              const SizedBox(height: AppSpacing.md),
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
                    _loadExperiences();
                  },
                  child: filteredList.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.4,
                              child: _buildEmptyState(query.isNotEmpty),
                            ),
                          ],
                        )
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            final isWide = constraints.maxWidth >= 600;
                            if (isWide) {
                              return ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: [
                                  _buildTableLayout(context, filteredList, isLoading),
                                ],
                              );
                            } else {
                              return _buildCardLayout(filteredList, isLoading);
                            }
                          },
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Card(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        child: Row(
          children: [
            Icon(Icons.search, color: AppColors.textSecondary),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: TextField(
                key: const Key('exp_search_input'),
                controller: _searchController,
                style: AppTypography.bodyLarge,
                decoration: InputDecoration(
                  hintText: AppConstants.searchPlaceholder,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            if (_searchController.text.isNotEmpty)
              IconButton(
                icon: Icon(Icons.clear, color: AppColors.textSecondary),
                onPressed: () {
                  _searchController.clear();
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoader() {
    return ListView.builder(
      itemCount: 4,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) => const _ShimmerCard(),
    );
  }

  Widget _buildEmptyState(bool isFiltered) {
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
            child: Icon(
              Icons.trending_down,
              color: AppColors.textSecondary,
              size: AppDimensions.iconLarge,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            isFiltered ? 'No search results found.' : AppConstants.expNoRecords,
            style: AppTypography.headingSmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          if (!isFiltered)
            TextButton.icon(
              onPressed: _loadExperiences,
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
              AppConstants.expLoadFailed,
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
              onPressed: _loadExperiences,
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

  Widget _buildCardLayout(List<ExperienceEntity> exps, bool actionsDisabled) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: exps.length,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        final exp = exps[index];
        return Card(
          color: AppColors.surface,
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          shape: RoundedRectangleBorder(
            side: BorderSide(color: AppColors.border),
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
                        exp.experienceLabel,
                        style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    _buildStatusBadge(exp.isActive),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: AppColors.primary),
                      onPressed: actionsDisabled ? null : () => _showAddEditDialog(experience: exp),
                    ),
                    IconButton(
                      icon: Icon(
                        exp.isActive ? Icons.toggle_on : Icons.toggle_off_outlined,
                        color: exp.isActive ? AppColors.success : AppColors.textSecondary,
                        size: 28,
                      ),
                      onPressed: actionsDisabled ? null : () => _confirmToggleStatus(exp),
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

  Widget _buildTableLayout(BuildContext context, List<ExperienceEntity> exps, bool actionsDisabled) {
    return Card(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: AppColors.border),
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
              columns: [
                DataColumn(label: Text('Experience Label', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Status', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Actions', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold))),
              ],
              rows: exps.map((exp) {
                return DataRow(
                  cells: [
                    DataCell(Text(exp.experienceLabel, style: TextStyle(color: AppColors.textPrimary))),
                    DataCell(_buildStatusBadge(exp.isActive)),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: actionsDisabled ? null : () => _showAddEditDialog(experience: exp),
                            icon: const Icon(Icons.edit, color: AppColors.primary),
                          ),
                          IconButton(
                            onPressed: actionsDisabled ? null : () => _confirmToggleStatus(exp),
                            icon: Icon(
                              exp.isActive ? Icons.check_circle : Icons.radio_button_unchecked,
                              color: exp.isActive ? AppColors.success : AppColors.textSecondary,
                            ),
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

  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: (isActive ? AppColors.success : AppColors.textSecondary).withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isActive ? AppConstants.statusActive : AppConstants.statusInactive,
        style: TextStyle(
          color: isActive ? AppColors.success : AppColors.textSecondary,
          fontWeight: FontWeight.bold,
          fontSize: 11,
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
              side: BorderSide(color: AppColors.border),
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}