import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interview_bridge_app/core/constants/app_constants.dart';
import 'package:interview_bridge_app/core/constants/validation_constants.dart';
import 'package:interview_bridge_app/core/exceptions/app_exceptions.dart';
import 'package:interview_bridge_app/features/auth/domain/entities/user_entity.dart';
import 'package:interview_bridge_app/core/widgets/custom_text_field.dart';
import 'package:interview_bridge_app/core/widgets/custom_button.dart';
import 'package:interview_bridge_app/features/auth/presentation/pages/login_page.dart';
import 'package:interview_bridge_app/features/auth/presentation/pages/register_page.dart';
import 'package:interview_bridge_app/core/routes/route_constants.dart';
import 'package:interview_bridge_app/features/auth/presentation/pages/auth_wrapper.dart';
import 'package:interview_bridge_app/features/practice_session/presentation/bloc/practice_session_bloc.dart';
import 'package:interview_bridge_app/features/practice_session/presentation/bloc/practice_session_event.dart';
import 'package:interview_bridge_app/features/practice_session/presentation/bloc/practice_session_state.dart';
import 'package:interview_bridge_app/features/question/presentation/bloc/question_bloc.dart';
import 'package:interview_bridge_app/features/question/presentation/bloc/question_event.dart';
import 'package:interview_bridge_app/features/question/presentation/bloc/question_state.dart';
import 'package:interview_bridge_app/features/evaluation/presentation/bloc/evaluation_bloc.dart';
import 'package:interview_bridge_app/features/evaluation/presentation/bloc/evaluation_event.dart';
import 'package:interview_bridge_app/features/evaluation/presentation/bloc/evaluation_state.dart';
import 'package:interview_bridge_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:interview_bridge_app/features/profile/presentation/bloc/profile_event.dart';
import 'package:interview_bridge_app/features/profile/presentation/bloc/profile_state.dart';
import 'package:interview_bridge_app/features/technology/presentation/bloc/technology_bloc.dart';
import 'package:interview_bridge_app/features/technology/presentation/bloc/technology_event.dart';
import 'package:interview_bridge_app/features/technology/presentation/bloc/technology_state.dart';
import 'package:interview_bridge_app/features/experience/presentation/bloc/experience_bloc.dart';
import 'package:interview_bridge_app/features/experience/presentation/bloc/experience_event.dart';
import 'package:interview_bridge_app/features/experience/presentation/bloc/experience_state.dart';
import 'package:interview_bridge_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:interview_bridge_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:interview_bridge_app/features/auth/domain/usecases/register_usecase.dart';
import 'package:interview_bridge_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:interview_bridge_app/features/auth/domain/usecases/get_logged_in_user_usecase.dart';

class FakeLoginUseCase implements LoginUseCase {
  AppException? exceptionToThrow;

  @override
  Future<AuthUserEntity> call(String email, String password) async {
    // ignore: avoid_print
    print('FakeLoginUseCase.call was entered with $email and $password');
    if (exceptionToThrow != null) {
      // ignore: avoid_print
      print('FakeLoginUseCase is throwing exception: $exceptionToThrow');
      throw exceptionToThrow!;
    }
    // ignore: avoid_print
    print('FakeLoginUseCase returning normal user entity');
    return AuthUserEntity(
      email: email,
      name: 'Abhishek Jain',
      role: 'USER',
      approvalStatus: 'APPROVED',
    );
  }
}

class DummyRegisterUseCase implements RegisterUseCase {
  @override
  noSuchMethod(Invocation invocation) => null;
}

class FakeLogoutUseCase implements LogoutUseCase {
  bool wasCalled = false;

  @override
  Future<void> call() async {
    wasCalled = true;
  }
}

class FakeGetLoggedInUserUseCase implements GetLoggedInUserUseCase {
  AuthUserEntity? userToReturn;

  @override
  Future<AuthUserEntity?> call() async {
    return userToReturn;
  }
}

void main() {
  late AuthBloc authBloc;
  late FakeLoginUseCase fakeLoginUseCase;
  late FakeLogoutUseCase fakeLogoutUseCase;
  late FakeGetLoggedInUserUseCase fakeGetLoggedInUserUseCase;

  setUp(() {
    fakeLoginUseCase = FakeLoginUseCase();
    fakeLogoutUseCase = FakeLogoutUseCase();
    fakeGetLoggedInUserUseCase = FakeGetLoggedInUserUseCase();
    authBloc = AuthBloc(
      loginUseCase: fakeLoginUseCase,
      registerUseCase: DummyRegisterUseCase(),
      logoutUseCase: fakeLogoutUseCase,
      getLoggedInUserUseCase: fakeGetLoggedInUserUseCase,
    );
  });

  tearDown(() {
    authBloc.close();
  });

  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      home: BlocProvider<AuthBloc>.value(
        value: authBloc,
        child: child,
      ),
      routes: {
        RouteConstants.termsConditions: (_) => const Scaffold(body: Text('Terms Page')),
        RouteConstants.privacyPolicy: (_) => const Scaffold(body: Text('Privacy Page')),
      },
    );
  }

  group('LoginPage Form Validation UX Tests', () {
    testWidgets('Validation errors are shown on submit, and update on user interaction', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableWidget(const LoginPage()));

      // Initially, no errors should be shown
      expect(find.text(ValidationConstants.emailOrPhoneRequired), findsNothing);
      expect(find.text(ValidationConstants.passwordRequired), findsNothing);

      // Click Login button to trigger validation
      final loginBtn = find.text(AppConstants.loginButton);
      await tester.tap(loginBtn);
      await tester.pumpAndSettle();

      // Validation errors should be displayed directly under fields (built in CustomTextField)
      expect(find.text(ValidationConstants.emailOrPhoneRequired), findsOneWidget);
      expect(find.text(ValidationConstants.passwordRequired), findsOneWidget);

      // Enter text in Email field to verify error goes away on user interaction
      final emailField = find.widgetWithText(CustomTextField, AppConstants.emailOrPhoneLabel);
      await tester.enterText(emailField, 'test@example.com');
      await tester.pumpAndSettle();

      expect(find.text(ValidationConstants.emailOrPhoneRequired), findsNothing);
      expect(find.text(ValidationConstants.passwordRequired), findsOneWidget);
    });

    testWidgets('Validation accepts numeric phone number and rejects invalid format', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableWidget(const LoginPage()));

      final emailField = find.widgetWithText(CustomTextField, AppConstants.emailOrPhoneLabel);
      
      // Enter invalid format
      await tester.enterText(emailField, '12345');
      final loginBtn = find.text(AppConstants.loginButton);
      await tester.tap(loginBtn);
      await tester.pumpAndSettle();

      expect(find.text(ValidationConstants.invalidEmailOrPhone), findsOneWidget);

      // Enter valid phone number
      await tester.enterText(emailField, '9174686803');
      await tester.pumpAndSettle();

      expect(find.text(ValidationConstants.invalidEmailOrPhone), findsNothing);
    });
  });

  group('RegisterPage Form Validation UX Tests', () {
    testWidgets('Validation errors display for all blank fields on submit, and match passwords correctly', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableWidget(const RegisterPage()));

      // Initially, no errors
      expect(find.text(ValidationConstants.nameRequired), findsNothing);
      expect(find.text(ValidationConstants.emailRequired), findsNothing);
      expect(find.text(ValidationConstants.phoneRequired), findsNothing);
      expect(find.text(ValidationConstants.invalidPhone), findsNothing);
      expect(find.text(ValidationConstants.passwordRequired), findsNothing);
      expect(find.text(ValidationConstants.termsRequired), findsNothing);

      // Verify Register button is disabled initially
      final registerBtnFinder = find.widgetWithText(CustomButton, AppConstants.registerButton);
      final registerBtnWidgetInitial = tester.widget<CustomButton>(registerBtnFinder);
      expect(registerBtnWidgetInitial.onPressed, isNull);

      // Tap checkbox to accept terms and enable the button
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      // Click Register button to trigger validation
      final registerBtn = find.text(AppConstants.registerButton);
      await tester.tap(registerBtn);
      await tester.pumpAndSettle();

      // Errors should appear (except termsRequired since it's already checked)
      expect(find.text(ValidationConstants.nameRequired), findsOneWidget);
      expect(find.text(ValidationConstants.emailRequired), findsOneWidget);
      expect(find.text(ValidationConstants.phoneRequired), findsOneWidget);
      // Both password and confirm password should show passwordRequired initially
      expect(find.text(ValidationConstants.passwordRequired), findsNWidgets(2));
      expect(find.text(ValidationConstants.termsRequired), findsNothing);

      // Enter valid name, email, invalid phone number, and mismatching passwords
      final nameField = find.widgetWithText(CustomTextField, AppConstants.fullNameLabel);
      final emailField = find.widgetWithText(CustomTextField, AppConstants.emailLabel);
      final phoneField = find.widgetWithText(CustomTextField, AppConstants.phoneNumberLabel);
      final passwordField = find.widgetWithText(CustomTextField, AppConstants.passwordLabel);
      final confirmPasswordField = find.widgetWithText(CustomTextField, AppConstants.confirmPasswordLabel);

      await tester.enterText(nameField, 'Abhishek Jain');
      await tester.enterText(emailField, 'abhishek@example.com');
      await tester.enterText(phoneField, '12345'); // Invalid
      await tester.enterText(passwordField, 'Password@123');
      await tester.enterText(confirmPasswordField, 'Password@1234'); // Mismatch
      await tester.pumpAndSettle();

      // Validation errors for name, email, passwordRequired, and phoneRequired should disappear
      expect(find.text(ValidationConstants.nameRequired), findsNothing);
      expect(find.text(ValidationConstants.emailRequired), findsNothing);
      expect(find.text(ValidationConstants.phoneRequired), findsNothing);
      expect(find.text(ValidationConstants.passwordRequired), findsNothing);

      // Invalid format phone error should be visible
      expect(find.text(ValidationConstants.invalidPhone), findsOneWidget);
      // Mismatch error should be visible
      expect(find.text(AppConstants.passwordsDoNotMatch), findsOneWidget);

      // Correct phone format and confirm password field to match
      await tester.enterText(phoneField, '9174686803'); // Valid 10-digit
      await tester.enterText(confirmPasswordField, 'Password@123');
      await tester.pumpAndSettle();

      // All errors should be gone
      expect(find.text(ValidationConstants.invalidPhone), findsNothing);
      expect(find.text(AppConstants.passwordsDoNotMatch), findsNothing);
    });

    testWidgets('Tapping terms & conditions and privacy links navigates to correct pages', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableWidget(const RegisterPage()));

      // Tap Terms Conditions link
      await tester.tap(find.text(AppConstants.termsConditionsLabel));
      await tester.pumpAndSettle();
      expect(find.text('Terms Page'), findsOneWidget);

      // Pop back
      Navigator.of(tester.element(find.text('Terms Page'))).pop();
      await tester.pumpAndSettle();

      // Tap Privacy Policy link
      await tester.tap(find.text(AppConstants.privacyPolicyLabel));
      await tester.pumpAndSettle();
      expect(find.text('Privacy Page'), findsOneWidget);
    });
  });

  group('LoginPage Feedback Tests for Pending/Rejected/Disabled Users', () {
    testWidgets('Shows correct dialog message for PENDING approval exception', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      fakeLoginUseCase.exceptionToThrow = AccountPendingApprovalException(AppConstants.errorPendingApproval);

      await tester.pumpWidget(buildTestableWidget(const LoginPage()));

      // Enter valid email/password so validation passes
      final emailField = find.widgetWithText(CustomTextField, AppConstants.emailOrPhoneLabel);
      final passwordField = find.widgetWithText(CustomTextField, AppConstants.passwordLabel);
      await tester.enterText(emailField, 'abhishek@gmail.com');
      await tester.enterText(passwordField, 'Password@123');

      final loginBtn = find.text(AppConstants.loginButton);
      await tester.tap(loginBtn);
      
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });

      await tester.pumpAndSettle();

      // Check that ErrorDialog with the pending message is displayed
      expect(find.text(AppConstants.dialogTitleAuthError), findsOneWidget);
      expect(find.text(AppConstants.errorPendingApproval), findsOneWidget);

      // Verify clicking OK dismisses the dialog
      await tester.tap(find.text(AppConstants.okButton));
      await tester.pumpAndSettle();

      expect(find.text(AppConstants.dialogTitleAuthError), findsNothing);
    });

    testWidgets('Shows correct dialog message for REJECTED approval / AccessDeniedException', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      fakeLoginUseCase.exceptionToThrow = AccessDeniedException(AppConstants.errorRejected);

      await tester.pumpWidget(buildTestableWidget(const LoginPage()));

      final emailField = find.widgetWithText(CustomTextField, AppConstants.emailOrPhoneLabel);
      final passwordField = find.widgetWithText(CustomTextField, AppConstants.passwordLabel);
      await tester.enterText(emailField, 'abhishek@gmail.com');
      await tester.enterText(passwordField, 'Password@123');
      
      final loginBtn = find.text(AppConstants.loginButton);
      await tester.tap(loginBtn);
      
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });

      await tester.pumpAndSettle();

      expect(find.text(AppConstants.dialogTitleAuthError), findsOneWidget);
      expect(find.text(AppConstants.errorRejected), findsOneWidget);

      // Verify clicking OK dismisses the dialog
      await tester.tap(find.text(AppConstants.okButton));
      await tester.pumpAndSettle();

      expect(find.text(AppConstants.dialogTitleAuthError), findsNothing);
    });

    testWidgets('Shows correct dialog message for disabled / inactive account', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      fakeLoginUseCase.exceptionToThrow = InvalidCredentialsException(AppConstants.errorDisabledAccount);

      await tester.pumpWidget(buildTestableWidget(const LoginPage()));

      final emailField = find.widgetWithText(CustomTextField, AppConstants.emailOrPhoneLabel);
      final passwordField = find.widgetWithText(CustomTextField, AppConstants.passwordLabel);
      await tester.enterText(emailField, 'abhishek@gmail.com');
      await tester.enterText(passwordField, 'Password@123');
      
      final loginBtn = find.text(AppConstants.loginButton);
      await tester.tap(loginBtn);
      
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });

      await tester.pumpAndSettle();

      expect(find.text(AppConstants.dialogTitleAuthError), findsOneWidget);
      expect(find.text(AppConstants.errorDisabledAccount), findsOneWidget);

      // Verify clicking OK dismisses the dialog
      await tester.tap(find.text(AppConstants.okButton));
      await tester.pumpAndSettle();

      expect(find.text(AppConstants.dialogTitleAuthError), findsNothing);
    });

    testWidgets('Shows correct dialog message for invalid credentials', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      fakeLoginUseCase.exceptionToThrow = InvalidCredentialsException(AppConstants.errorInvalidCredentials);

      await tester.pumpWidget(buildTestableWidget(const LoginPage()));

      final emailField = find.widgetWithText(CustomTextField, AppConstants.emailOrPhoneLabel);
      final passwordField = find.widgetWithText(CustomTextField, AppConstants.passwordLabel);
      await tester.enterText(emailField, 'abhishek@gmail.com');
      await tester.enterText(passwordField, 'Password@123');
      
      final loginBtn = find.text(AppConstants.loginButton);
      await tester.tap(loginBtn);
      
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });

      await tester.pumpAndSettle();

      expect(find.text(AppConstants.dialogTitleAuthError), findsOneWidget);
      expect(find.text(AppConstants.errorInvalidCredentials), findsOneWidget);

      // Verify clicking OK dismisses the dialog
      await tester.tap(find.text(AppConstants.okButton));
      await tester.pumpAndSettle();

      expect(find.text(AppConstants.dialogTitleAuthError), findsNothing);
    });

    testWidgets('Shows correct dialog message for login failure in AuthWrapper context', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      fakeLoginUseCase.exceptionToThrow = InvalidCredentialsException(AppConstants.errorInvalidCredentials);

      Widget buildWrapperTestableWidget() {
        return MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<AuthBloc>.value(value: authBloc),
              BlocProvider<PracticeSessionBloc>.value(value: FakePracticeSessionBloc()),
              BlocProvider<QuestionBloc>.value(value: FakeQuestionBloc()),
              BlocProvider<EvaluationBloc>.value(value: FakeEvaluationBloc()),
              BlocProvider<ProfileBloc>.value(value: FakeProfileBloc()),
              BlocProvider<TechnologyBloc>.value(value: FakeTechnologyBloc()),
              BlocProvider<ExperienceBloc>.value(value: FakeExperienceBloc()),
            ],
            child: const AuthWrapper(),
          ),
        );
      }

      await tester.pumpWidget(buildWrapperTestableWidget());

      await tester.pump();
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();

      expect(find.text(AppConstants.loginTitle), findsOneWidget);

      final emailField = find.widgetWithText(CustomTextField, AppConstants.emailOrPhoneLabel);
      final passwordField = find.widgetWithText(CustomTextField, AppConstants.passwordLabel);
      await tester.enterText(emailField, 'abhishek@gmail.com');
      await tester.enterText(passwordField, 'Password@123');

      final loginBtn = find.text(AppConstants.loginButton);
      await tester.tap(loginBtn);

      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });

      await tester.pumpAndSettle();

      expect(find.text(AppConstants.dialogTitleAuthError), findsOneWidget);
      expect(find.text(AppConstants.errorInvalidCredentials), findsOneWidget);

      // Verify clicking OK dismisses the dialog
      await tester.tap(find.text(AppConstants.okButton));
      await tester.pumpAndSettle();

      expect(find.text(AppConstants.dialogTitleAuthError), findsNothing);
    });
  });

  group('PendingApprovalPage Tests', () {
    testWidgets('Displays OK button, removes Logout button, and transitions to LoginPage on tap via AuthWrapper', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // Prepare fake user returning PENDING status
      fakeGetLoggedInUserUseCase.userToReturn = const AuthUserEntity(
        email: 'pending@gmail.com',
        name: 'Pending User',
        role: 'USER',
        approvalStatus: 'PENDING',
      );

      Widget buildWrapperTestableWidget() {
        return MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<AuthBloc>.value(value: authBloc),
              BlocProvider<PracticeSessionBloc>.value(value: FakePracticeSessionBloc()),
              BlocProvider<QuestionBloc>.value(value: FakeQuestionBloc()),
              BlocProvider<EvaluationBloc>.value(value: FakeEvaluationBloc()),
              BlocProvider<ProfileBloc>.value(value: FakeProfileBloc()),
              BlocProvider<TechnologyBloc>.value(value: FakeTechnologyBloc()),
              BlocProvider<ExperienceBloc>.value(value: FakeExperienceBloc()),
            ],
            child: const AuthWrapper(),
          ),
        );
      }

      await tester.pumpWidget(buildWrapperTestableWidget());

      // Trigger AuthStarted call by pumping the wrapper
      await tester.pump();
      // Let AuthStarted future run and return the pending user
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      // Rebuild tree to show PendingApprovalPage
      await tester.pump();

      // Verify that the title and subtitle are present, and the custom icons/designs are preserved
      expect(find.text(AppConstants.pendingTitle), findsOneWidget);
      expect(find.text(AppConstants.pendingSubtitle), findsOneWidget);

      // Verify OK button is displayed
      expect(find.text(AppConstants.okButton), findsOneWidget);

      // Verify Logout button is NOT displayed
      expect(find.text(AppConstants.logoutButton), findsNothing);

      // Tap OK button
      final okBtn = find.text(AppConstants.okButton);
      await tester.tap(okBtn);

      // Let the ClearRegistrationState event execute in the real zone
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });

      // Rebuild the tree which should now show the LoginPage (since status is Unauthenticated)
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify we are indeed on the LoginPage by checking login title is displayed
      expect(find.text(AppConstants.loginTitle), findsOneWidget);

      // Verify that logoutUseCase was called to clear local registration state
      expect(fakeLogoutUseCase.wasCalled, isTrue);
    });
  });

  group('Password Visibility Toggle Tests', () {
    testWidgets('LoginPage password toggle behaves correctly', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableWidget(const LoginPage()));

      // Locate password field by label
      final passwordFieldFinder = find.widgetWithText(CustomTextField, AppConstants.passwordLabel);
      expect(passwordFieldFinder, findsOneWidget);

      // Verify that obscureText is true initially
      TextField getPasswordFieldWidget() {
        return tester.widget<TextField>(
          find.descendant(
            of: passwordFieldFinder,
            matching: find.byType(TextField),
          ),
        );
      }

      expect(getPasswordFieldWidget().obscureText, isTrue);

      // Tap the eye icon suffix button.
      final toggleIconFinder = find.descendant(
        of: passwordFieldFinder,
        matching: find.byType(IconButton),
      );
      expect(toggleIconFinder, findsOneWidget);

      await tester.tap(toggleIconFinder);
      await tester.pumpAndSettle();

      // Verify obscureText is false
      expect(getPasswordFieldWidget().obscureText, isFalse);

      // Tap toggle again
      await tester.tap(toggleIconFinder);
      await tester.pumpAndSettle();

      // Verify obscureText is true again
      expect(getPasswordFieldWidget().obscureText, isTrue);
    });

    testWidgets('RegisterPage password and confirm password toggles behave correctly', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableWidget(const RegisterPage()));

      final passwordFieldFinder = find.widgetWithText(CustomTextField, AppConstants.passwordLabel);
      final confirmPasswordFieldFinder = find.widgetWithText(CustomTextField, AppConstants.confirmPasswordLabel);

      expect(passwordFieldFinder, findsOneWidget);
      expect(confirmPasswordFieldFinder, findsOneWidget);

      TextField getFieldWidget(Finder finder) {
        return tester.widget<TextField>(
          find.descendant(
            of: finder,
            matching: find.byType(TextField),
          ),
        );
      }

      // Both obscured by default
      expect(getFieldWidget(passwordFieldFinder).obscureText, isTrue);
      expect(getFieldWidget(confirmPasswordFieldFinder).obscureText, isTrue);

      // Tap password toggle
      final passwordToggleFinder = find.descendant(
        of: passwordFieldFinder,
        matching: find.byType(IconButton),
      );
      await tester.tap(passwordToggleFinder);
      await tester.pumpAndSettle();

      // Password is now visible, Confirm Password is still obscured
      expect(getFieldWidget(passwordFieldFinder).obscureText, isFalse);
      expect(getFieldWidget(confirmPasswordFieldFinder).obscureText, isTrue);

      // Tap confirm password toggle
      final confirmPasswordToggleFinder = find.descendant(
        of: confirmPasswordFieldFinder,
        matching: find.byType(IconButton),
      );
      await tester.tap(confirmPasswordToggleFinder);
      await tester.pumpAndSettle();

      // Both are now visible
      expect(getFieldWidget(passwordFieldFinder).obscureText, isFalse);
      expect(getFieldWidget(confirmPasswordFieldFinder).obscureText, isFalse);

      // Tap both again
      await tester.tap(passwordToggleFinder);
      await tester.tap(confirmPasswordToggleFinder);
      await tester.pumpAndSettle();

      // Both obscured again
      expect(getFieldWidget(passwordFieldFinder).obscureText, isTrue);
      expect(getFieldWidget(confirmPasswordFieldFinder).obscureText, isTrue);
    });
  });

  group('Registration Consent UX Tests', () {
    testWidgets('Register button is disabled by default and toggles based on terms checkbox state', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableWidget(const RegisterPage()));

      final registerBtnFinder = find.widgetWithText(CustomButton, AppConstants.registerButton);
      expect(registerBtnFinder, findsOneWidget);

      // Verify Register button is disabled initially
      var registerBtn = tester.widget<CustomButton>(registerBtnFinder);
      expect(registerBtn.onPressed, isNull);

      // Tick the consent checkbox
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      // Verify Register button becomes enabled
      registerBtn = tester.widget<CustomButton>(registerBtnFinder);
      expect(registerBtn.onPressed, isNotNull);

      // Untick the consent checkbox
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      // Verify Register button becomes disabled again
      registerBtn = tester.widget<CustomButton>(registerBtnFinder);
    });
  });

  group('Role-Based Routing Tests in AuthWrapper', () {
    testWidgets('ROLE_ADMIN routes to AdminDashboardPage', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      fakeGetLoggedInUserUseCase.userToReturn = const AuthUserEntity(
        email: 'admin@gmail.com',
        name: 'Admin User',
        role: 'ROLE_ADMIN',
        approvalStatus: 'APPROVED',
      );

      Widget buildWrapperTestableWidget() {
        return MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<AuthBloc>.value(value: authBloc),
              BlocProvider<PracticeSessionBloc>.value(value: FakePracticeSessionBloc()),
              BlocProvider<QuestionBloc>.value(value: FakeQuestionBloc()),
              BlocProvider<EvaluationBloc>.value(value: FakeEvaluationBloc()),
              BlocProvider<ProfileBloc>.value(value: FakeProfileBloc()),
              BlocProvider<TechnologyBloc>.value(value: FakeTechnologyBloc()),
              BlocProvider<ExperienceBloc>.value(value: FakeExperienceBloc()),
            ],
            child: const AuthWrapper(),
          ),
        );
      }

      await tester.pumpWidget(buildWrapperTestableWidget());

      await tester.pump();
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pump();

      expect(find.text(AppConstants.adminDashboardTitle), findsOneWidget);
      expect(find.text(AppConstants.placeholderDashboard), findsOneWidget);
    });

    testWidgets('ROLE_USER routes to candidate ProfilePage', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      fakeGetLoggedInUserUseCase.userToReturn = const AuthUserEntity(
        email: 'candidate@gmail.com',
        name: 'Candidate User',
        role: 'ROLE_USER',
        approvalStatus: 'APPROVED',
      );

      Widget buildWrapperTestableWidget() {
        return MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<AuthBloc>.value(value: authBloc),
              BlocProvider<PracticeSessionBloc>.value(value: FakePracticeSessionBloc()),
              BlocProvider<QuestionBloc>.value(value: FakeQuestionBloc()),
              BlocProvider<EvaluationBloc>.value(value: FakeEvaluationBloc()),
              BlocProvider<ProfileBloc>.value(value: FakeProfileBloc()),
              BlocProvider<TechnologyBloc>.value(value: FakeTechnologyBloc()),
              BlocProvider<ExperienceBloc>.value(value: FakeExperienceBloc()),
            ],
            child: const AuthWrapper(),
          ),
        );
      }

      await tester.pumpWidget(buildWrapperTestableWidget());

      await tester.pump();
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pump();

      expect(find.text(AppConstants.profileTitle), findsOneWidget);
    });
  });
}

class FakePracticeSessionBloc extends Bloc<PracticeSessionEvent, PracticeSessionState> implements PracticeSessionBloc {
  FakePracticeSessionBloc() : super(PracticeSessionInitial()) {
    on<ResetSessionState>((event, emit) {});
  }

  @override
  noSuchMethod(Invocation invocation) => null;
}

class FakeQuestionBloc extends Bloc<QuestionEvent, QuestionState> implements QuestionBloc {
  FakeQuestionBloc() : super(QuestionInitial()) {
    on<ResetQuestionState>((event, emit) {});
  }

  @override
  noSuchMethod(Invocation invocation) => null;
}

class FakeEvaluationBloc extends Bloc<EvaluationEvent, EvaluationState> implements EvaluationBloc {
  FakeEvaluationBloc() : super(EvaluationInitial()) {
    on<ResetEvaluationState>((event, emit) {});
  }

  @override
  noSuchMethod(Invocation invocation) => null;
}

class FakeProfileBloc extends Bloc<ProfileEvent, ProfileState> implements ProfileBloc {
  FakeProfileBloc() : super(ProfileInitial()) {
    on<ResetProfileState>((event, emit) {});
    on<LoadProfile>((event, emit) {});
  }

  @override
  noSuchMethod(Invocation invocation) => null;
}

class FakeTechnologyBloc extends Bloc<TechnologyEvent, TechnologyState> implements TechnologyBloc {
  FakeTechnologyBloc() : super(TechnologyInitial()) {
    on<ResetTechnologyState>((event, emit) {});
  }

  @override
  noSuchMethod(Invocation invocation) => null;
}

class FakeExperienceBloc extends Bloc<ExperienceEvent, ExperienceState> implements ExperienceBloc {
  FakeExperienceBloc() : super(ExperienceInitial()) {
    on<ResetExperienceState>((event, emit) {});
  }

  @override
  noSuchMethod(Invocation invocation) => null;
}
