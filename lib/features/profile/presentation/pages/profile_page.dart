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
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
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
  bool _isEditingName = false;

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
      context.read<ProfileBloc>().add(
            UpdateProfileRequested(
              name: _nameController.text.trim(),
              technologyId: techId,
              experienceId: expId,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
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

    return Scaffold(
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
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      drawer: const UserDrawer(currentRoute: RouteConstants.profile),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUpdateSuccess) {
            setState(() {
              _isEditingName = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppConstants.profileUpdateSuccess,
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.white),
                ),
                backgroundColor: AppColors.success,
              ),
            );
            // Refresh currentUser in AuthBloc so name updates globally
            context.read<AuthBloc>().add(LoadCurrentUser());
          } else if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.white),
                ),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isProfileLoading = state is ProfileLoading;
          final isUpdating = state is ProfileUpdating;

          if (isProfileLoading && state is! ProfileLoaded) {
            return const Center(child: LoadingIndicator());
          }

          // Fallback fields if profile not set up yet
          String displayName = _nameController.text.isNotEmpty ? _nameController.text : initialName;
          String techLabel = 'Not Configured';
          String expLabel = 'Not Configured';
          String techId = '';
          String expId = '';
          bool isSelectionConfigured = false;

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
          }

          if (!_isEditingName && _nameController.text != displayName) {
            _nameController.text = displayName;
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
                    if (_isEditingName) ...[
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
                                        _isEditingName = false;
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
                        trailing: isSelectionConfigured
                            ? IconButton(
                                icon: const Icon(Icons.edit, color: AppColors.primaryLight),
                                onPressed: () {
                                  setState(() {
                                    _isEditingName = true;
                                  });
                                },
                              )
                            : null, // Disable editing name until profile is configured
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
    );
  }
}