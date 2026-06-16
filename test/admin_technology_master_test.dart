import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interview_bridge_app/core/constants/app_constants.dart';
import 'package:interview_bridge_app/features/technology/domain/entities/technology_entity.dart';
import 'package:interview_bridge_app/features/technology/domain/usecases/get_technologies_usecase.dart';
import 'package:interview_bridge_app/features/technology/domain/usecases/get_all_technologies_usecase.dart';
import 'package:interview_bridge_app/features/technology/domain/usecases/create_technology_usecase.dart';
import 'package:interview_bridge_app/features/technology/domain/usecases/update_technology_usecase.dart';
import 'package:interview_bridge_app/features/technology/domain/usecases/activate_technology_usecase.dart';
import 'package:interview_bridge_app/features/technology/domain/usecases/deactivate_technology_usecase.dart';
import 'package:interview_bridge_app/features/technology/presentation/bloc/technology_bloc.dart';
import 'package:interview_bridge_app/features/admin/presentation/widgets/technology_master_widget.dart';

class FakeGetTechnologiesUseCase implements GetTechnologiesUseCase {
  @override
  Future<List<TechnologyEntity>> call() async => [];
}

class FakeGetAllTechnologiesUseCase implements GetAllTechnologiesUseCase {
  List<TechnologyEntity> list = [];
  bool throwsError = false;
  Completer<List<TechnologyEntity>>? completer;

  @override
  Future<List<TechnologyEntity>> call() async {
    if (throwsError) {
      throw Exception('Load Failed');
    }
    if (completer != null) {
      return completer!.future;
    }
    return list;
  }
}

class FakeCreateTechnologyUseCase implements CreateTechnologyUseCase {
  String? createdName;
  String? createdDesc;
  bool throwsError = false;

  @override
  Future<TechnologyEntity> call(String name, String description) async {
    if (throwsError) {
      throw Exception('Create Failed');
    }
    createdName = name;
    createdDesc = description;
    return TechnologyEntity(id: 'new_id', name: name, description: description, isActive: true);
  }
}

class FakeUpdateTechnologyUseCase implements UpdateTechnologyUseCase {
  String? updatedId;
  String? updatedName;
  String? updatedDesc;
  bool throwsError = false;

  @override
  Future<TechnologyEntity> call(String id, String name, String description) async {
    if (throwsError) {
      throw Exception('Update Failed');
    }
    updatedId = id;
    updatedName = name;
    updatedDesc = description;
    return TechnologyEntity(id: id, name: name, description: description, isActive: true);
  }
}

class FakeActivateTechnologyUseCase implements ActivateTechnologyUseCase {
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

class FakeDeactivateTechnologyUseCase implements DeactivateTechnologyUseCase {
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
  late TechnologyBloc techBloc;
  late FakeGetTechnologiesUseCase fakeGetTechnologies;
  late FakeGetAllTechnologiesUseCase fakeGetAllTechnologies;
  late FakeCreateTechnologyUseCase fakeCreateTechnology;
  late FakeUpdateTechnologyUseCase fakeUpdateTechnology;
  late FakeActivateTechnologyUseCase fakeActivateTechnology;
  late FakeDeactivateTechnologyUseCase fakeDeactivateTechnology;

  setUp(() {
    fakeGetTechnologies = FakeGetTechnologiesUseCase();
    fakeGetAllTechnologies = FakeGetAllTechnologiesUseCase();
    fakeCreateTechnology = FakeCreateTechnologyUseCase();
    fakeUpdateTechnology = FakeUpdateTechnologyUseCase();
    fakeActivateTechnology = FakeActivateTechnologyUseCase();
    fakeDeactivateTechnology = FakeDeactivateTechnologyUseCase();

    techBloc = TechnologyBloc(
      getTechnologiesUseCase: fakeGetTechnologies,
      getAllTechnologiesUseCase: fakeGetAllTechnologies,
      createTechnologyUseCase: fakeCreateTechnology,
      updateTechnologyUseCase: fakeUpdateTechnology,
      activateTechnologyUseCase: fakeActivateTechnology,
      deactivateTechnologyUseCase: fakeDeactivateTechnology,
    );
  });

  tearDown(() {
    techBloc.close();
  });

  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider<TechnologyBloc>.value(
          value: techBloc,
          child: child,
        ),
      ),
    );
  }

  group('TechnologyMasterWidget Widget Tests', () {
    testWidgets('Shows loading shimmer on initial state', (WidgetTester tester) async {
      final completer = Completer<List<TechnologyEntity>>();
      fakeGetAllTechnologies.completer = completer;

      await tester.pumpWidget(buildTestableWidget(const TechnologyMasterWidget()));
      await tester.pump();

      // Check shimmer cards are showing
      expect(find.byType(Card), findsWidgets);

      completer.complete([]);
    });

    testWidgets('Displays active and inactive technologies in table layout on desktop viewport', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1600, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      fakeGetAllTechnologies.list = [
        const TechnologyEntity(id: '1', name: 'Flutter', description: 'Cross-platform dev framework', isActive: true),
        const TechnologyEntity(id: '2', name: 'React', description: 'Web dev framework', isActive: false),
      ];

      await tester.pumpWidget(buildTestableWidget(const TechnologyMasterWidget()));
      
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();

      // Verify DataTable and columns are present
      expect(find.byType(DataTable), findsOneWidget);
      expect(find.text('Flutter'), findsOneWidget);
      expect(find.text('React'), findsOneWidget);
      expect(find.text('Cross-platform dev framework'), findsOneWidget);
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

      fakeGetAllTechnologies.list = [
        const TechnologyEntity(id: '1', name: 'Flutter', description: 'Cross-platform dev framework', isActive: true),
        const TechnologyEntity(id: '2', name: 'React', description: 'Web dev framework', isActive: false),
      ];

      await tester.pumpWidget(buildTestableWidget(const TechnologyMasterWidget()));
      
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();

      // Enter search query
      await tester.enterText(find.byKey(const Key('tech_search_input')), 'Flutter');
      await tester.pumpAndSettle();

      // Verify React is filtered out
      expect(find.descendant(of: find.byType(DataTable), matching: find.text('Flutter')), findsOneWidget);
      expect(find.text('React'), findsNothing);
    });

    testWidgets('Creating a record displays Add Dialog, validates form, submits and shows success', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1600, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      fakeGetAllTechnologies.list = [];

      await tester.pumpWidget(buildTestableWidget(const TechnologyMasterWidget()));
      
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();

      // Tap floating add button
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Add Dialog should be showing
      expect(find.text(AppConstants.addTechTitle), findsOneWidget);

      // Try saving without entering anything (form validation trigger)
      await tester.tap(find.text(AppConstants.btnSave));
      await tester.pumpAndSettle();
      expect(find.text(AppConstants.techNameRequired), findsOneWidget);

      // Fill form and save
      await tester.enterText(find.widgetWithText(TextFormField, AppConstants.techNameLabel), 'Vue.js');
      await tester.enterText(find.widgetWithText(TextFormField, AppConstants.techDescLabel), 'Progressive JS Framework');
      await tester.tap(find.text(AppConstants.btnSave));

      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();

      // Verify Create Usecase called
      expect(fakeCreateTechnology.createdName, equals('Vue.js'));
      expect(fakeCreateTechnology.createdDesc, equals('Progressive JS Framework'));

      // Success dialog should be showing
      expect(find.text(AppConstants.dialogTitleSuccess), findsOneWidget);
      expect(find.text(AppConstants.techCreateSuccess), findsOneWidget);

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

      fakeGetAllTechnologies.list = [
        const TechnologyEntity(id: '1', name: 'Flutter', description: 'Cross-platform dev framework', isActive: true),
      ];

      await tester.pumpWidget(buildTestableWidget(const TechnologyMasterWidget()));
      
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();

      // Tap edit button (Icons.edit)
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      // Verify values are pre-filled in fields
      expect(find.widgetWithText(TextFormField, 'Flutter'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Cross-platform dev framework'), findsOneWidget);

      // Change description and save
      await tester.enterText(find.widgetWithText(TextFormField, AppConstants.techDescLabel), 'Mobile, Web and Desktop SDK');
      await tester.tap(find.text(AppConstants.btnSave));

      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();

      // Verify Update Usecase called
      expect(fakeUpdateTechnology.updatedId, equals('1'));
      expect(fakeUpdateTechnology.updatedName, equals('Flutter'));
      expect(fakeUpdateTechnology.updatedDesc, equals('Mobile, Web and Desktop SDK'));

      // Success dialog should show
      expect(find.text(AppConstants.dialogTitleSuccess), findsOneWidget);
      expect(find.text(AppConstants.techUpdateSuccess), findsOneWidget);

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

      fakeGetAllTechnologies.list = [
        const TechnologyEntity(id: '1', name: 'Flutter', description: 'Cross-platform dev framework', isActive: true),
      ];

      await tester.pumpWidget(buildTestableWidget(const TechnologyMasterWidget()));
      
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();

      // Tap toggle button (which will be Icons.check_circle in DataTable layout)
      await tester.tap(find.byIcon(Icons.check_circle));
      await tester.pumpAndSettle();

      // Verify confirmation dialog shows
      expect(find.text(AppConstants.adminConfirmActionTitle), findsOneWidget);
      expect(find.text('${AppConstants.techDeactivateConfirmMsg}\n\nFlutter'), findsOneWidget);

      // Tap confirm button
      await tester.tap(find.text(AppConstants.adminConfirmButton));

      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();

      // Verify Deactivate Usecase called
      expect(fakeDeactivateTechnology.deactivatedId, equals('1'));

      // Success dialog should show
      expect(find.text(AppConstants.dialogTitleSuccess), findsOneWidget);
      expect(find.text(AppConstants.techDeactivateSuccess), findsOneWidget);

      // Close success dialog
      await tester.tap(find.text(AppConstants.okButton));
      await tester.pumpAndSettle();
    });
  });
}
