import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interview_bridge_app/core/constants/app_constants.dart';
import 'package:interview_bridge_app/features/admin/domain/entities/admin_entity.dart';
import 'package:interview_bridge_app/features/admin/presentation/widgets/pending_users_widget.dart';
import 'package:interview_bridge_app/features/admin/presentation/bloc/admin_bloc.dart';
//import 'package:interview_bridge_app/features/admin/presentation/bloc/admin_event.dart';
import 'package:interview_bridge_app/features/admin/domain/usecases/get_pending_users_usecase.dart';
import 'package:interview_bridge_app/features/admin/domain/usecases/approve_user_usecase.dart';
import 'package:interview_bridge_app/features/admin/domain/usecases/reject_user_usecase.dart';
import 'package:interview_bridge_app/features/admin/domain/repositories/admin_repository.dart';

class FakeGetPendingUsersUseCase implements GetPendingUsersUseCase {
  List<AdminEntity> usersToReturn = [];
  bool throwsError = false;
  Completer<List<AdminEntity>>? completer;

  @override
  AdminRepository get repository => throw UnimplementedError();

  @override
  Future<List<AdminEntity>> call() async {
    if (throwsError) {
      throw Exception('Mock Loading Failed');
    }
    if (completer != null) {
      return completer!.future;
    }
    return usersToReturn;
  }
}

class FakeApproveUserUseCase implements ApproveUserUseCase {
  String? approvedUserId;
  bool throwsError = false;

  @override
  AdminRepository get repository => throw UnimplementedError();

  @override
  Future<void> call(String id) async {
    if (throwsError) {
      throw Exception('Mock Approve Failed');
    }
    approvedUserId = id;
  }
}

class FakeRejectUserUseCase implements RejectUserUseCase {
  String? rejectedUserId;
  bool throwsError = false;

  @override
  AdminRepository get repository => throw UnimplementedError();

  @override
  Future<void> call(String id) async {
    if (throwsError) {
      throw Exception('Mock Reject Failed');
    }
    rejectedUserId = id;
  }
}

void main() {
  late AdminBloc adminBloc;
  late FakeGetPendingUsersUseCase fakeGetPendingUsersUseCase;
  late FakeApproveUserUseCase fakeApproveUserUseCase;
  late FakeRejectUserUseCase fakeRejectUserUseCase;

  setUp(() {
    fakeGetPendingUsersUseCase = FakeGetPendingUsersUseCase();
    fakeApproveUserUseCase = FakeApproveUserUseCase();
    fakeRejectUserUseCase = FakeRejectUserUseCase();
    adminBloc = AdminBloc(
      getPendingUsersUseCase: fakeGetPendingUsersUseCase,
      approveUserUseCase: fakeApproveUserUseCase,
      rejectUserUseCase: fakeRejectUserUseCase,
    );
  });

  tearDown(() {
    adminBloc.close();
  });

  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      home: BlocProvider<AdminBloc>.value(
        value: adminBloc,
        child: Scaffold(body: child),
      ),
    );
  }

  group('PendingUsersWidget Widget Tests', () {
    testWidgets('Shows loading shimmer on initial state', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1600, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final completer = Completer<List<AdminEntity>>();
      fakeGetPendingUsersUseCase.completer = completer;

      await tester.pumpWidget(buildTestableWidget(const PendingUsersWidget()));
      await tester.pump();

      // Check that cards are displayed as shimmer placeholders
      expect(find.byType(Card), findsWidgets);

      // Clean up completer
      completer.complete([]);
    });

    testWidgets('Displays pending users list correctly', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1600, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final mockUser = AdminEntity(
        id: '1',
        name: 'Abhishek Jain',
        email: 'abhishek@gmail.com',
        phoneNumber: '9174686803',
        role: 'ROLE_USER',
        approvalStatus: 'PENDING',
        createdAt: DateTime(2026, 6, 10),
      );
      fakeGetPendingUsersUseCase.usersToReturn = [mockUser];

      await tester.pumpWidget(buildTestableWidget(const PendingUsersWidget()));
      
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();

      // Assert values are displayed
      expect(find.text('Abhishek Jain'), findsOneWidget);
      expect(find.text('abhishek@gmail.com'), findsOneWidget);
      expect(find.text('9174686803'), findsOneWidget);
      expect(find.text('2026-06-10'), findsOneWidget);
    });

    testWidgets('Approve action displays confirmation dialog and succeeds on confirm', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1600, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final mockUser = AdminEntity(
        id: '1',
        name: 'Abhishek Jain',
        email: 'abhishek@gmail.com',
        phoneNumber: '9174686803',
        role: 'ROLE_USER',
        approvalStatus: 'PENDING',
        createdAt: DateTime(2026, 6, 10),
      );
      fakeGetPendingUsersUseCase.usersToReturn = [mockUser];

      await tester.pumpWidget(buildTestableWidget(const PendingUsersWidget()));
      
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();

      // Tap approve button (IconButton with tooltip)
      await tester.tap(find.byTooltip(AppConstants.adminApproveButton));
      await tester.pumpAndSettle();

      // Check confirmation dialog is displayed
      expect(find.text(AppConstants.adminConfirmActionTitle), findsOneWidget);

      // Tap confirm button
      await tester.tap(find.text(AppConstants.adminConfirmButton));
      
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();

      // Verify ApproveUserUseCase was called with the correct ID
      expect(fakeApproveUserUseCase.approvedUserId, equals('1'));
      
      // Success dialog should be shown
      expect(find.text(AppConstants.dialogTitleSuccess), findsOneWidget);

      // Dismiss success dialog
      await tester.tap(find.text(AppConstants.okButton));
      await tester.pumpAndSettle();
    });

    testWidgets('Reject action displays confirmation dialog and succeeds on confirm', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1600, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final mockUser = AdminEntity(
        id: '1',
        name: 'Abhishek Jain',
        email: 'abhishek@gmail.com',
        phoneNumber: '9174686803',
        role: 'ROLE_USER',
        approvalStatus: 'PENDING',
        createdAt: DateTime(2026, 6, 10),
      );
      fakeGetPendingUsersUseCase.usersToReturn = [mockUser];

      await tester.pumpWidget(buildTestableWidget(const PendingUsersWidget()));
      
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();

      // Tap reject button (IconButton with tooltip)
      await tester.tap(find.byTooltip(AppConstants.adminRejectButton));
      await tester.pumpAndSettle();

      // Check confirmation dialog is displayed
      expect(find.text(AppConstants.adminConfirmActionTitle), findsOneWidget);

      // Tap confirm button
      await tester.tap(find.text(AppConstants.adminConfirmButton));
      
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();

      // Verify RejectUserUseCase was called with the correct ID
      expect(fakeRejectUserUseCase.rejectedUserId, equals('1'));
      
      // Success dialog should be shown
      expect(find.text(AppConstants.dialogTitleSuccess), findsOneWidget);

      // Dismiss success dialog
      await tester.tap(find.text(AppConstants.okButton));
      await tester.pumpAndSettle();
    });

    testWidgets('Displays empty state UI when there are no pending users', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1600, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      fakeGetPendingUsersUseCase.usersToReturn = [];

      await tester.pumpWidget(buildTestableWidget(const PendingUsersWidget()));
      
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();

      expect(find.text(AppConstants.adminNoPendingUsers), findsOneWidget);
    });

    testWidgets('Displays error state UI on load failure and retries successfully', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1600, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      fakeGetPendingUsersUseCase.throwsError = true;

      await tester.pumpWidget(buildTestableWidget(const PendingUsersWidget()));
      
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();

      // Check error message is displayed
      expect(find.text(AppConstants.adminLoadPendingFailed), findsOneWidget);

      // Fix the throwsError flag and mock user list
      fakeGetPendingUsersUseCase.throwsError = false;
      fakeGetPendingUsersUseCase.usersToReturn = [
        AdminEntity(
          id: '1',
          name: 'Abhishek Jain',
          email: 'abhishek@gmail.com',
          phoneNumber: '9174686803',
          role: 'ROLE_USER',
          approvalStatus: 'PENDING',
          createdAt: DateTime(2026, 6, 10),
        )
      ];

      // Tap retry button
      await tester.tap(find.widgetWithText(ElevatedButton, AppConstants.adminRetryButton));
      
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();

      // Assert values are displayed after retry success
      expect(find.text('Abhishek Jain'), findsOneWidget);
    });
  });
}
