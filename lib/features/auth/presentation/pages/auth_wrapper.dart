import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'login_page.dart';
import 'pending_approval_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../practice_session/presentation/bloc/practice_session_bloc.dart';
import '../../../practice_session/presentation/bloc/practice_session_event.dart';
import '../../../question/presentation/bloc/question_bloc.dart';
import '../../../question/presentation/bloc/question_event.dart';
import '../../../evaluation/presentation/bloc/evaluation_bloc.dart';
import '../../../evaluation/presentation/bloc/evaluation_event.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_event.dart';
import '../../../technology/presentation/bloc/technology_bloc.dart';
import '../../../technology/presentation/bloc/technology_event.dart';
import '../../../experience/presentation/bloc/experience_bloc.dart';
import '../../../experience/presentation/bloc/experience_event.dart';
import '../../../../core/widgets/loading_indicator.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(AuthStarted());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          context.read<PracticeSessionBloc>().add(ResetSessionState());
          context.read<QuestionBloc>().add(ResetQuestionState());
          context.read<EvaluationBloc>().add(ResetEvaluationState());
          context.read<ProfileBloc>().add(ResetProfileState());
          context.read<TechnologyBloc>().add(ResetTechnologyState());
          context.read<ExperienceBloc>().add(ResetExperienceState());
        }
      },
      builder: (context, state) {
        if (state is AuthInitial || state is AuthLoading) {
          return const Scaffold(
            body: LoadingIndicator(),
          );
        } else if (state is Authenticated) {
          if (state.user.approvalStatus == 'PENDING') {
            return const PendingApprovalPage();
          }
          return const ProfilePage();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
