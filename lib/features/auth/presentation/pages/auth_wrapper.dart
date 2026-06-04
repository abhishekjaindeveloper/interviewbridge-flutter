import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'login_page.dart';
import 'pending_approval_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
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
    return BlocBuilder<AuthBloc, AuthState>(
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
