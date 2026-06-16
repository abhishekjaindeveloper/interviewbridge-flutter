import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interview_bridge_app/core/constants/app_constants.dart';
import 'package:interview_bridge_app/features/experience/domain/entities/experience_entity.dart';
import 'package:interview_bridge_app/features/experience/domain/usecases/get_experiences_usecase.dart';
import 'package:interview_bridge_app/features/experience/domain/usecases/get_all_experiences_usecase.dart';
import 'package:interview_bridge_app/features/experience/domain/usecases/create_experience_usecase.dart';
import 'package:interview_bridge_app/features/experience/domain/usecases/update_experience_usecase.dart';
import 'package:interview_bridge_app/features/experience/domain/usecases/activate_experience_usecase.dart';
import 'package:interview_bridge_app/features/experience/domain/usecases/deactivate_experience_usecase.dart';
import 'package:interview_bridge_app/features/experience/presentation/bloc/experience_bloc.dart';
import 'package:interview_bridge_app/features/admin/presentation/widgets/experience_master_widget.dart';

class FakeGetExperiencesUseCase implements GetExperiencesUseCase {
  @override
  Future<List<ExperienceEntity>> call() async => [];
}

class FakeGetAllExperiencesUseCase implements GetAllExperiencesUseCase {
  List<ExperienceEntity> list = [];
  bool throwsError = false;
  Completer<List<ExperienceEntity>>? completer;

  @override
  Future<List<ExperienceEntity>> call() async {
    if (throwsError) {
      throw Exception('Load Failed');
    }
    if (completer != null) {
      return completer!.future;
    }
    return list;
  }
}

class FakeCreateExperienceUseCase implements CreateExperienceUseCase {
  String? createdLabel;
  bool throwsError = false;

  @override
  Future<ExperienceEntity> call(String label) async {
    if (throwsError) {
      throw Exception('Create Failed');
    }
    createdLabel = label;
    return ExperienceEntity(id: 'new_id', experienceLabel: label, isActive: true);
  }
}

class FakeUpdateExperienceUseCase implements UpdateExperienceUseCase {
  String? updatedId;
  String? updatedLabel;
  bool throwsError = false;

  @override
  Future<ExperienceEntity> call(String id, String label) async {
    if (throwsError) {
      throw Exception('Update Failed');
    }
    updatedId = id;
    updatedLabel = label;
    return ExperienceEntity(id: id, experienceLabel: label, isActive: true);
  }
}

class FakeActivateExperienceUseCase implements ActivateExperienceUseCase {
  String? activatedId;
  bool throwsError = false;

  @override
  Future<void> call(String id) async {
    if (throwsError) {
      throw Exception('Activate Failed');
    }
    activatedId = id;
  }
}

class FakeDeactivateExperienceUseCase implements DeactivateExperienceUseCase {
  String? deactivatedId;
  bool throwsError = false;

  @override
  Future<void> call(String id) async {
    if (throwsError) {
      throw Exception('Deactivate Failed');
    }
    deactivatedId = id;
  }
}

void main() {
  late ExperienceBloc expBloc;
  late FakeGetExperiencesUseCase fakeGetExperiences;
  late FakeGetAllExperiencesUseCase fakeGetAllExperiences;
  late FakeCreateExperienceUseCase fakeCreateExperience;
  late FakeUpdateExperienceUseCase fakeUpdateExperience;
  late FakeActivateExperienceUseCase fakeActivateExperience;
  late FakeDeactivateExperienceUseCase fakeDeactivateExperience;

  setUp(() {
    fakeGetExperiences = FakeGetExperiencesUseCase();
    fakeGetAllExperiences = FakeGetAllExperiencesUseCase();
    fakeCreateExperience = FakeCreateExperienceUseCase();
    fakeUpdateExperience = FakeUpdateExperienceUseCase();
    fakeActivateExperience = FakeActivateExperienceUseCase();
    fakeDeactivateExperience = FakeDeactivateExperienceUseCase();

    expBloc = ExperienceBloc(
      getExperiencesUseCase: fakeGetExperiences,
      getAllExperiencesUseCase: fakeGetAllExperiences,
      createExperienceUseCase: fakeCreateExperience,
      updateExperienceUseCase: fakeUpdateExperience,
      activateExperienceUseCase: fakeActivateExperience,
      deactivateExperienceUseCase: fakeDeactivateExperience,
    );
  });

  tearDown(() {
    expBloc.close();
  });

  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider<ExperienceBloc>.value(
          value: expBloc,
          child: child,
        ),
      ),
    );
  }

  group('ExperienceMasterWidget Widget Tests', () {
    testWidgets('Shows loading shimmer on initial state', (WidgetTester tester) async {
      final completer = Completer<List<ExperienceEntity>>();
      fakeGetAllExperiences.completer = completer;

      await tester.pumpWidget(buildTestableWidget(const ExperienceMasterWidget()));
      await tester.pump();

      // Check shimmer cards are showing
      expect(find.byType(Card), findsWidgets);

      completer.complete([]);
    });

    testWidgets('Displays active and inactive experiences in table layout on desktop viewport', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1600, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      fakeGetAllExperiences.list = [
        const ExperienceEntity(id: '1', experienceLabel: 'Junior', isActive: true),
        const ExperienceEntity(id: '2', experienceLabel: 'Senior', isActive: false),
      ];

      await tester.pumpWidget(buildTestableWidget(const ExperienceMasterWidget()));
      
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();

      // Verify DataTable and columns are present
      expect(find.byType(DataTable), findsOneWidget);
      expect(find.text('Junior'), findsOneWidget);
      expect(find.text('Senior'), findsOneWidget);
      expect(find.text(AppConstants.statusActive), findsOneWidget);
      expect(find.text(AppConstants.statusInactive), findsOneWidget);
    });

    testWidgets('Searching and filtering locally working correctly', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1600, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      fakeGetAllExperiences.list = [
        const ExperienceEntity(id: '1', experienceLabel: 'Junior', isActive: true),
        const ExperienceEntity(id: '2', experienceLabel: 'Senior', isActive: false),
      ];

      await tester.pumpWidget(buildTestableWidget(const ExperienceMasterWidget()));
      
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();

      // Enter search query
      await tester.enterText(find.byKey(const Key('exp_search_input')), 'Junior');
      await tester.pumpAndSettle();

      // Verify Senior is filtered out
      expect(find.descendant(of: find.byType(DataTable), matching: find.text('Junior')), findsOneWidget);
      expect(find.text('Senior'), findsNothing);
    });

    testWidgets('Creating a record displays Add Dialog, validates form, submits and shows success', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1600, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      fakeGetAllExperiences.list = [];

      await tester.pumpWidget(buildTestableWidget(const ExperienceMasterWidget()));
      
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();

      // Tap floating add button
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Add Dialog should be showing
      expect(find.text(AppConstants.addExpTitle), findsOneWidget);

      // Try saving without entering anything (form validation trigger)
      await tester.tap(find.text(AppConstants.btnSave));
      await tester.pumpAndSettle();
      expect(find.text(AppConstants.expLabelRequired), findsOneWidget);

      // Fill form and save
      await tester.enterText(find.widgetWithText(TextFormField, AppConstants.expLabelLabel), 'Lead');
      await tester.tap(find.text(AppConstants.btnSave));

      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();

      // Verify Create Usecase called
      expect(fakeCreateExperience.createdLabel, equals('Lead'));

      // Success dialog should be showing
      expect(find.text(AppConstants.dialogTitleSuccess), findsOneWidget);
      expect(find.text(AppConstants.expCreateSuccess), findsOneWidget);

      // Close success dialog
      await tester.tap(find.text(AppConstants.okButton));
      await tester.pumpAndSettle();
    });

    testWidgets('Updating a record displays Edit Dialog, fills values, submits and shows success', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1600, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      fakeGetAllExperiences.list = [
        const ExperienceEntity(id: '1', experienceLabel: 'Junior', isActive: true),
      ];

      await tester.pumpWidget(buildTestableWidget(const ExperienceMasterWidget()));
      
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();

      // Tap edit button (Icons.edit)
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      // Verify values are pre-filled in fields
      expect(find.widgetWithText(TextFormField, 'Junior'), findsOneWidget);

      // Change label and save
      await tester.enterText(find.widgetWithText(TextFormField, AppConstants.expLabelLabel), 'Mid Level');
      await tester.tap(find.text(AppConstants.btnSave));

      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();

      // Verify Update Usecase called
      expect(fakeUpdateExperience.updatedId, equals('1'));
      expect(fakeUpdateExperience.updatedLabel, equals('Mid Level'));

      // Success dialog should show
      expect(find.text(AppConstants.dialogTitleSuccess), findsOneWidget);
      expect(find.text(AppConstants.expUpdateSuccess), findsOneWidget);

      // Close success dialog
      await tester.tap(find.text(AppConstants.okButton));
      await tester.pumpAndSettle();
    });

    testWidgets('Deactivating confirmation flow triggers and succeeds', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1600, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      fakeGetAllExperiences.list = [
        const ExperienceEntity(id: '1', experienceLabel: 'Junior', isActive: true),
      ];

      await tester.pumpWidget(buildTestableWidget(const ExperienceMasterWidget()));
      
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();

      // Tap toggle button (which will be Icons.check_circle in DataTable layout)
      await tester.tap(find.byIcon(Icons.check_circle));
      await tester.pumpAndSettle();

      // Verify confirmation dialog shows
      expect(find.text(AppConstants.adminConfirmActionTitle), findsOneWidget);
      expect(find.text('${AppConstants.expDeactivateConfirmMsg}\n\nJunior'), findsOneWidget);

      // Tap confirm button
      await tester.tap(find.text(AppConstants.adminConfirmButton));

      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();

      // Verify Deactivate Usecase called
      expect(fakeDeactivateExperience.deactivatedId, equals('1'));

      // Success dialog should show
      expect(find.text(AppConstants.dialogTitleSuccess), findsOneWidget);
      expect(find.text(AppConstants.expDeactivateSuccess), findsOneWidget);

      // Close success dialog
      await tester.tap(find.text(AppConstants.okButton));
      await tester.pumpAndSettle();
    });
  });
}
