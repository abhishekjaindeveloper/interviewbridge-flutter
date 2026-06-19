// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/error_dialog.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_card_widget.dart';

class PendingApprovalPage extends StatelessWidget {
  const PendingApprovalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            final isNetworkError = state.message == AppConstants.noConnection;
            ErrorDialog.show(
              context: context,
              title: isNetworkError
                  ? AppConstants.dialogTitleNetworkError
                  : AppConstants.dialogTitleAuthError,
              message: state.message,
              type: DialogType.error,
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SafeArea(
            child: AuthCardWidget(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Waiting status icon
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(AppDimensions.opacityLow),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.hourglass_empty_rounded,
                        color: AppColors.warning,
                        size: AppDimensions.iconLarge,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    AppConstants.pendingTitle,
                    style: AppTypography.headingMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    AppConstants.pendingSubtitle,
                    style: AppTypography.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                   CustomButton(
                    text: AppConstants.okButton,
                    onPressed: isLoading
                        ? null
                        : () {
                            context.read<AuthBloc>().add(ClearRegistrationState());
                          },
                    isLoading: isLoading,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}