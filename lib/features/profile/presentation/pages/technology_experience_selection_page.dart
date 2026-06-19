import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../technology/presentation/bloc/technology_bloc.dart';
import '../../../technology/presentation/bloc/technology_event.dart';
import '../../../technology/presentation/bloc/technology_state.dart';
import '../../../experience/presentation/bloc/experience_bloc.dart';
import '../../../experience/presentation/bloc/experience_event.dart';
import '../../../experience/presentation/bloc/experience_state.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../widgets/selection_card_widget.dart';

class TechnologyExperienceSelectionPage extends StatefulWidget {
  const TechnologyExperienceSelectionPage({super.key});

  @override
  State<TechnologyExperienceSelectionPage> createState() => _TechnologyExperienceSelectionPageState();
}

class _TechnologyExperienceSelectionPageState extends State<TechnologyExperienceSelectionPage> {
  String? _selectedTechnologyId;
  String? _selectedExperienceId;

  @override
  void initState() {
    super.initState();
    context.read<TechnologyBloc>().add(FetchTechnologies());
    context.read<ExperienceBloc>().add(FetchExperiences());
    
    // Pre-populate selections from current profile loaded state if possible
    final profileState = context.read<ProfileBloc>().state;
    if (profileState is ProfileLoaded) {
      _selectedTechnologyId = profileState.profile.technology?.id;
      _selectedExperienceId = profileState.profile.experience?.id;
    }
  }

  void _onSubmitPressed() {
    if (_selectedTechnologyId == null || _selectedExperienceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppConstants.selectionValidationWarning,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.white),
          ),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    context.read<ProfileBloc>().add(
          SetupProfileSelection(
            technologyId: _selectedTechnologyId!,
            experienceId: _selectedExperienceId!,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          AppConstants.selectionTitle,
          style: AppTypography.headingMedium,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileSetupSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppConstants.selectionSuccess,
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.white),
                ),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.of(context).pop();
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
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, profileState) {
            final isSubmitting = profileState is ProfileLoading || profileState is ProfileUpdating;

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      AppConstants.selectionSubtitle,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Technology Section
                            Text(
                              AppConstants.selectTechLabel,
                              style: AppTypography.bodyLarge.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            BlocBuilder<TechnologyBloc, TechnologyState>(
                              builder: (context, state) {
                                if (state is TechnologyLoading) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                                    child: Center(child: LoadingIndicator()),
                                  );
                                } else if (state is TechnologyError) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                                    child: Center(
                                      child: Text(
                                        state.message,
                                        style: AppTypography.bodyMedium.copyWith(color: AppColors.error),
                                      ),
                                    ),
                                  );
                                } else if (state is TechnologyLoaded) {
                                  if (state.technologies.isEmpty) {
                                    return const Padding(
                                      padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                                      child: Center(child: Text(AppConstants.noTechAvailable)),
                                    );
                                  }
                                  return ListView.separated(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: state.technologies.length,
                                    separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
                                    itemBuilder: (context, index) {
                                      final tech = state.technologies[index];
                                      return SelectionCardWidget(
                                        title: tech.name,
                                        subtitle: tech.description,
                                        isSelected: _selectedTechnologyId == tech.id,
                                        onTap: isSubmitting
                                            ? () {}
                                            : () {
                                                setState(() {
                                                  _selectedTechnologyId = tech.id;
                                                });
                                              },
                                      );
                                    },
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),

                            const SizedBox(height: AppSpacing.xl),
                            Divider(color: AppColors.border),
                            const SizedBox(height: AppSpacing.xl),

                            // Experience Section
                            Text(
                              AppConstants.selectExpLabel,
                              style: AppTypography.bodyLarge.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            BlocBuilder<ExperienceBloc, ExperienceState>(
                              builder: (context, state) {
                                if (state is ExperienceLoading) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                                    child: Center(child: LoadingIndicator()),
                                  );
                                } else if (state is ExperienceError) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                                    child: Center(
                                      child: Text(
                                        state.message,
                                        style: AppTypography.bodyMedium.copyWith(color: AppColors.error),
                                      ),
                                    ),
                                  );
                                } else if (state is ExperienceLoaded) {
                                  if (state.experiences.isEmpty) {
                                    return const Padding(
                                      padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                                      child: Center(child: Text(AppConstants.noExpAvailable)),
                                    );
                                  }
                                  return ListView.separated(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: state.experiences.length,
                                    separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
                                    itemBuilder: (context, index) {
                                      final exp = state.experiences[index];
                                      return SelectionCardWidget(
                                        title: exp.experienceLabel,
                                        isSelected: _selectedExperienceId == exp.id,
                                        onTap: isSubmitting
                                            ? () {}
                                            : () {
                                                setState(() {
                                                  _selectedExperienceId = exp.id;
                                                });
                                              },
                                      );
                                    },
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                            const SizedBox(height: AppSpacing.xxl),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    CustomButton(
                      text: AppConstants.submitSelectionButton,
                      onPressed: isSubmitting ? null : _onSubmitPressed,
                      isLoading: isSubmitting,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}