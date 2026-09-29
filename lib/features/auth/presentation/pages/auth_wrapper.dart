import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/routes/route_constants.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'login_page.dart';
import 'pending_approval_page.dart';
import '../../../admin/presentation/pages/admin_dashboard_page.dart';
import '../../../practice_session/presentation/pages/user_dashboard_page.dart';
import '../../../practice_session/presentation/bloc/practice_session_bloc.dart';
import '../../../practice_session/presentation/bloc/practice_session_event.dart';
import '../../../question/presentation/bloc/question_bloc.dart';
import '../../../question/presentation/bloc/question_event.dart';
import '../../../evaluation/presentation/bloc/evaluation_bloc.dart';
import '../../../evaluation/presentation/bloc/evaluation_event.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_event.dart';
import '../../../profile/presentation/bloc/profile_state.dart';
import '../../../profile/presentation/pages/technology_experience_selection_page.dart';
import '../../../technology/presentation/bloc/technology_bloc.dart';
import '../../../technology/presentation/bloc/technology_event.dart';
import '../../../experience/presentation/bloc/experience_bloc.dart';
import '../../../experience/presentation/bloc/experience_event.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/error_dialog.dart';
import '../../../../core/widgets/loading_indicator.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _hasInitialCheckCompleted = false;
  bool _hasAdmittedToDashboard = false;

  @override
  void initState() {
    super.initState();
    final authBloc = context.read<AuthBloc>();
    if (authBloc.state is AuthInitial) {
      authBloc.add(AuthStarted());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated ||
            state is Authenticated ||
            state is AuthError ||
            state is AuthRejected ||
            state is PhoneAlreadyRegistered ||
            state is EmailAlreadyRegistered) {
          if (!_hasInitialCheckCompleted) {
            setState(() {
              _hasInitialCheckCompleted = true;
            });
          }
        }

        if (state is Unauthenticated) {
          _hasAdmittedToDashboard = false;
          _hasInitialCheckCompleted = false;

          context.read<PracticeSessionBloc>().add(ResetSessionState());
          context.read<QuestionBloc>().add(ResetQuestionState());
          context.read<EvaluationBloc>().add(ResetEvaluationState());
          context.read<ProfileBloc>().add(ResetProfileState());
          context.read<TechnologyBloc>().add(ResetTechnologyState());
          context.read<ExperienceBloc>().add(ResetExperienceState());
          
          Future.microtask(() {
            if (context.mounted) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                RouteConstants.landing,
                (route) => false,
              );
            }
          });
        } else if (state is AuthError) {
          final msg = state.message;
          final isInlineError = msg == AppConstants.errorUserNotFound ||
              msg == AppConstants.errorIncorrectPassword;

          if (!isInlineError) {
            final isNetworkError = msg == AppConstants.noConnection;
            final isPendingError = msg == AppConstants.pendingUserMessage;
            ErrorDialog.show(
              context: context,
              title: isNetworkError
                  ? AppConstants.dialogTitleNetworkError
                  : (isPendingError
                      ? AppConstants.pendingUserTitle
                      : AppConstants.dialogTitleAuthError),
              message: msg,
              type: DialogType.error,
            );
          }
        } else if (state is AuthRejected) {
          final reason = state.rejectionReason;
          final isFallback = reason.isEmpty ||
              reason == 'N/A' ||
              reason == AppConstants.notAvailablePlaceholder;

          ErrorDialog.show(
            context: context,
            title: AppConstants.rejectionRequestRejectedTitle,
            message: isFallback
                ? AppConstants.rejectionRequestFallbackMessage
                : '${AppConstants.rejectionReasonPrefix}$reason\n\n${AppConstants.rejectionDialogContactSupport}',
            type: DialogType.error,
          );
        }
      },
      builder: (context, state) {
        if (state is AuthInitial || (state is AuthLoading && !_hasInitialCheckCompleted)) {
          return const Scaffold(
            body: LoadingIndicator(),
          );
        } else if (state is Authenticated) {
          if (state.user.approvalStatus == 'PENDING') {
            return const PendingApprovalPage();
          }
          if (state.user.role == 'ROLE_ADMIN') {
            return const AdminDashboardPage();
          }

          // Candidate User Flow: Avoid rebuild loops once admitted to Dashboard
          if (_hasAdmittedToDashboard) {
            return const UserDashboardPage();
          }

          final profileState = context.watch<ProfileBloc>().state;
          if (profileState is ProfileInitial) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                context.read<ProfileBloc>().add(LoadProfile());
              }
            });
            return const Scaffold(
              body: LoadingIndicator(),
            );
          } else if (profileState is ProfileLoading) {
            return const Scaffold(
              body: LoadingIndicator(),
            );
          } else if (profileState is ProfileLoaded) {
            final isComplete = profileState.profile.profileStatus == 'COMPLETED';
            if (isComplete) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && !_hasAdmittedToDashboard) {
                  setState(() {
                    _hasAdmittedToDashboard = true;
                  });
                }
              });
              return const UserDashboardPage();
            } else {
              return const TechnologyExperienceSelectionPage();
            }
          } else if (profileState is ProfileError) {
            // Safety fallback on ProfileError: admit to Dashboard to prevent stuck loading
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && !_hasAdmittedToDashboard) {
                setState(() {
                  _hasAdmittedToDashboard = true;
                });
              }
            });
            return const UserDashboardPage();
          }

          return const UserDashboardPage();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
