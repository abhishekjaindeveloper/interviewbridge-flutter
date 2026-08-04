import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/routes/route_constants.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/user_drawer.dart';
import '../../../../core/widgets/error_dialog.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../domain/entities/profile_entity.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../widgets/profile_info_card_widget.dart';
import '../../../auth/presentation/widgets/auth_card_widget.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(LoadProfile());
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onSavePressed(String techId, String expId) {
    if (_formKey.currentState!.validate()) {
      final profileState = context.read<ProfileBloc>().state;
      if (profileState is ProfileLoaded) {
        context.read<ProfileBloc>().add(
              UpdateProfileRequested(
                name: _nameController.text.trim(),
                technologyId: techId,
                experienceId: expId,
                preferredJobRole: profileState.profile.preferredJobRole,
                preferredLocation: profileState.profile.preferredLocation,
                preferredWorkMode: profileState.profile.preferredWorkMode,
                expectedSalary: profileState.profile.expectedSalary,
                jobAlertEnabled: profileState.profile.jobAlertEnabled,
              ),
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final profileState = context.watch<ProfileBloc>().state;
    final isUpdating = profileState is ProfileUpdating;

    String userEmail = '';
    String userRole = '';
    String userStatus = '';
    String initialName = '';

    if (authState is Authenticated) {
      userEmail = authState.user.email;
      userRole = authState.user.role;
      userStatus = authState.user.approvalStatus;
      initialName = authState.user.name;
    }

    return PopScope(
      canPop: !isUpdating,
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: Text(
                AppConstants.profileTitle,
                style: AppTypography.headingMedium,
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: isUpdating
                    ? null
                    : () {
                        Navigator.of(context).pop();
                      },
              ),
            ),
            drawer: UserDrawer(
              currentRoute: RouteConstants.profile,
              parentContext: context,
            ),
            body: BlocConsumer<ProfileBloc, ProfileState>(
              listener: (context, state) {
                if (state is ProfileUpdateSuccess) {
                  setState(() {
                    _isEditing = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(AppConstants.profileUpdateSuccess),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  // Refresh currentUser in AuthBloc so name updates globally
                  context.read<AuthBloc>().add(LoadCurrentUser());
                } else if (state is ProfileError) {
                  ErrorDialog.show(
                    context: context,
                    title: 'Error',
                    message: state.message,
                  );
                }
              },
              builder: (context, state) {
                final isProfileLoading = state is ProfileLoading;

                if (isProfileLoading && state is! ProfileLoaded) {
                  return const Center(child: LoadingIndicator());
                }

                // Fallback fields if profile not set up yet
                String displayName = _nameController.text.isNotEmpty ? _nameController.text : initialName;
                String techLabel = AppConstants.notConfigured;
                String expLabel = AppConstants.notConfigured;
                String techId = '';
                String expId = '';
                bool isSelectionConfigured = false;

                String preferredJobRole = '';
                String preferredLocation = '';
                String preferredWorkMode = 'Remote';
                double expectedSalary = 0.0;
                bool jobAlertEnabled = false;

                if (state is ProfileLoaded) {
                  displayName = state.profile.name;
                  if (state.profile.technology != null) {
                    techLabel = state.profile.technology!.name;
                    techId = state.profile.technology!.id;
                  }
                  if (state.profile.experience != null) {
                    expLabel = state.profile.experience!.experienceLabel;
                    expId = state.profile.experience!.id;
                  }
                  isSelectionConfigured = state.profile.technology != null && state.profile.experience != null;
                  preferredJobRole = state.profile.preferredJobRole ?? '';
                  preferredLocation = state.profile.preferredLocation ?? '';
                  preferredWorkMode = state.profile.preferredWorkMode ?? 'Remote';
                  expectedSalary = state.profile.expectedSalary ?? 0.0;
                  jobAlertEnabled = state.profile.jobAlertEnabled ?? false;
                }

                if (!_isEditing) {
                  if (_nameController.text != displayName) {
                    _nameController.text = displayName;
                  }
                }

                return SafeArea(
                  child: AuthCardWidget(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Center(
                            child: CircleAvatar(
                              radius: 40,
                              backgroundColor: AppColors.primary,
                              child: Icon(
                                Icons.person,
                                size: 40,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            AppConstants.profileSubtitle,
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.xl),

                          // Editable Name Section
                          if (_isEditing) ...[
                            CustomTextField(
                              labelText: AppConstants.nameLabel,
                              hintText: AppConstants.nameLabel,
                              controller: _nameController,
                              enabled: !isUpdating,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return AppConstants.nameRequired;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              children: [
                                Expanded(
                                  child: CustomButton(
                                    text: AppConstants.saveChangesButton,
                                    onPressed: isUpdating ? null : () => _onSavePressed(techId, expId),
                                    isLoading: isUpdating,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: isUpdating
                                        ? null
                                        : () {
                                            setState(() {
                                              _isEditing = false;
                                              _nameController.text = displayName;
                                            });
                                          },
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                                      side: BorderSide(color: AppColors.border),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
                                      ),
                                    ),
                                    child: Text(
                                      AppConstants.cancelChangesButton,
                                      style: TextStyle(color: AppColors.textPrimary),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ] else ...[
                            ProfileInfoCardWidget(
                              label: AppConstants.nameLabel,
                              value: displayName,
                              trailing: IconButton(
                                icon: const Icon(Icons.edit, color: AppColors.primaryLight),
                                onPressed: isUpdating
                                    ? null
                                    : () {
                                        setState(() {
                                          _isEditing = true;
                                        });
                                      },
                              ),
                            ),
                          ],

                          const SizedBox(height: AppSpacing.sm),
                          ProfileInfoCardWidget(
                            label: AppConstants.emailLabelReadonly,
                            value: userEmail,
                          ),
                          ProfileInfoCardWidget(
                            label: AppConstants.roleLabel,
                            value: userRole,
                          ),
                          ProfileInfoCardWidget(
                            label: AppConstants.approvalStatusLabel,
                            value: userStatus,
                          ),

                          const SizedBox(height: AppSpacing.lg),
                          Divider(color: AppColors.border),
                          const SizedBox(height: AppSpacing.lg),

                          // Career Preferences Section
                          Text(
                            'Career Preferences',
                            style: AppTypography.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),

                          InkWell(
                            onTap: isUpdating || state is! ProfileLoaded ? null : () => _showEditPreferencesDialog(context, state.profile),
                            borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
                            child: ProfileInfoCardWidget(
                              label: 'Preferred Job Role',
                              value: preferredJobRole.isNotEmpty ? preferredJobRole : AppConstants.notConfigured,
                            ),
                          ),
                          InkWell(
                            onTap: isUpdating || state is! ProfileLoaded ? null : () => _showEditPreferencesDialog(context, state.profile),
                            borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
                            child: ProfileInfoCardWidget(
                              label: 'Preferred Location',
                              value: preferredLocation.isNotEmpty ? preferredLocation : AppConstants.notConfigured,
                            ),
                          ),
                          InkWell(
                            onTap: isUpdating || state is! ProfileLoaded ? null : () => _showEditPreferencesDialog(context, state.profile),
                            borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
                            child: ProfileInfoCardWidget(
                              label: 'Preferred Work Mode',
                              value: preferredWorkMode.isNotEmpty ? preferredWorkMode : AppConstants.notConfigured,
                            ),
                          ),
                          InkWell(
                            onTap: isUpdating || state is! ProfileLoaded ? null : () => _showEditPreferencesDialog(context, state.profile),
                            borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
                            child: ProfileInfoCardWidget(
                              label: 'Expected Salary',
                              value: expectedSalary > 0 ? expectedSalary.toStringAsFixed(0) : AppConstants.notConfigured,
                            ),
                          ),
                          InkWell(
                            onTap: isUpdating || state is! ProfileLoaded ? null : () => _showEditPreferencesDialog(context, state.profile),
                            borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
                            child: ProfileInfoCardWidget(
                              label: 'Job Alert Status',
                              value: jobAlertEnabled ? 'Enabled' : 'Disabled',
                            ),
                          ),

                          const SizedBox(height: AppSpacing.lg),
                          Divider(color: AppColors.border),
                          const SizedBox(height: AppSpacing.lg),

                          // Technology & Experience Display
                          Text(
                            AppConstants.selectedTechAndExp,
                            style: AppTypography.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          ProfileInfoCardWidget(
                            label: AppConstants.technologyLabel,
                            value: techLabel,
                          ),
                          ProfileInfoCardWidget(
                            label: AppConstants.experienceLevelLabel,
                            value: expLabel,
                          ),

                          const SizedBox(height: AppSpacing.xl),

                          // Setup/Change Selection Button
                          if (isSelectionConfigured) ...[
                            CustomButton(
                              text: AppConstants.goToPracticeSessionsButton,
                              onPressed: isProfileLoading || isUpdating
                                  ? null
                                  : () {
                                      if (Navigator.of(context).canPop()) {
                                        Navigator.of(context).pop();
                                      } else {
                                        Navigator.of(context).pushReplacementNamed(RouteConstants.home);
                                      }
                                    },
                            ),
                            const SizedBox(height: AppSpacing.md),
                            OutlinedButton(
                              onPressed: isProfileLoading || isUpdating
                                  ? null
                                  : () {
                                      Navigator.of(context).pushNamed(RouteConstants.profileSetup);
                                    },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                                side: BorderSide(color: AppColors.border),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
                                ),
                              ),
                              child: Text(
                                AppConstants.changeSelectionButton,
                                style: TextStyle(color: AppColors.textPrimary),
                              ),
                            ),
                          ] else ...[
                            CustomButton(
                              text: AppConstants.setupSelectionButton,
                              onPressed: isProfileLoading || isUpdating
                                  ? null
                                  : () {
                                      Navigator.of(context).pushNamed(RouteConstants.profileSetup);
                                    },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (isUpdating)
            Positioned.fill(
              child: AbsorbPointer(
                child: Container(
                  color: AppColors.black.withValues(alpha: 0.3),
                  child: Center(
                    child: Card(
                      color: AppColors.surface,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const LoadingIndicator(),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              AppConstants.updatingProfile,
                              style: AppTypography.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showEditPreferencesDialog(BuildContext context, ProfileEntity profile) {
    final formKey = GlobalKey<FormState>();
    final jobRoleController = TextEditingController(text: profile.preferredJobRole ?? '');
    final locationController = TextEditingController(text: profile.preferredLocation ?? '');
    final expectedSalaryController = TextEditingController(
      text: (profile.expectedSalary != null && profile.expectedSalary! > 0)
          ? profile.expectedSalary!.toStringAsFixed(0)
          : '',
    );
    String selectedWorkMode = (profile.preferredWorkMode != null && profile.preferredWorkMode!.isNotEmpty)
        ? profile.preferredWorkMode!
        : 'Remote';
    bool jobAlertEnabled = profile.jobAlertEnabled ?? false;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: AppColors.black.withValues(alpha: 0.5),
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
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Edit Career Preferences',
                          style: AppTypography.headingSmall.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        CustomTextField(
                          controller: jobRoleController,
                          labelText: 'Preferred Job Role',
                          hintText: 'e.g. Senior Java Developer',
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Preferred job role is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        CustomTextField(
                          controller: locationController,
                          labelText: 'Preferred Location',
                          hintText: 'e.g. Bangalore, Remote',
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Preferred location is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Preferred Work Mode',
                              style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            DropdownButtonFormField<String>(
                              initialValue: selectedWorkMode,
                              style: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary),
                              dropdownColor: AppColors.surface,
                              decoration: const InputDecoration(
                                hintText: 'Select Work Mode',
                              ),
                              items: const [
                                DropdownMenuItem(value: 'Remote', child: Text('Remote')),
                                DropdownMenuItem(value: 'Hybrid', child: Text('Hybrid')),
                                DropdownMenuItem(value: 'Onsite', child: Text('Onsite')),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setDialogState(() {
                                    selectedWorkMode = value;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        CustomTextField(
                          controller: expectedSalaryController,
                          labelText: 'Expected Salary',
                          hintText: 'e.g. 1500000',
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Expected salary is required';
                            }
                            final salary = double.tryParse(value.trim());
                            if (salary == null || salary <= 0) {
                              return 'Please enter a positive number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
                            border: Border.all(
                              color: AppColors.border.withValues(alpha: AppDimensions.opacityBorder),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Job Alert Enabled',
                                      style: AppTypography.bodyMedium.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    Text(
                                      jobAlertEnabled ? 'Enabled' : 'Disabled',
                                      style: AppTypography.bodyLarge.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: jobAlertEnabled,
                                activeThumbColor: AppColors.primary,
                                onChanged: (value) {
                                  setDialogState(() {
                                    jobAlertEnabled = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () {
                                  Navigator.of(dialogContext).pop();
                                },
                                child: Text(
                                  AppConstants.cancelChangesButton,
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
                                  if (formKey.currentState!.validate()) {
                                    final double salary = double.parse(expectedSalaryController.text.trim());
                                    final techId = profile.technology?.id ?? '';
                                    final expId = profile.experience?.id ?? '';
                                    
                                    // Close Dialog
                                    Navigator.of(dialogContext).pop();

                                    // Dispatch Update Event
                                    context.read<ProfileBloc>().add(
                                      UpdateProfileRequested(
                                        name: profile.name,
                                        technologyId: techId,
                                        experienceId: expId,
                                        preferredJobRole: jobRoleController.text.trim(),
                                        preferredLocation: locationController.text.trim(),
                                        preferredWorkMode: selectedWorkMode,
                                        expectedSalary: salary,
                                        jobAlertEnabled: jobAlertEnabled,
                                      ),
                                    );
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
    ).then((_) {
      jobRoleController.dispose();
      locationController.dispose();
      expectedSalaryController.dispose();
    });
  }
}