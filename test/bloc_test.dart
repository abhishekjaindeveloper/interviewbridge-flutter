import 'package:flutter_test/flutter_test.dart';
import 'package:interview_bridge_app/core/exceptions/app_exceptions.dart';
import 'package:interview_bridge_app/features/technology/domain/entities/technology_entity.dart';
import 'package:interview_bridge_app/features/technology/domain/usecases/get_technologies_usecase.dart';
import 'package:interview_bridge_app/features/technology/presentation/bloc/technology_bloc.dart';
import 'package:interview_bridge_app/features/technology/presentation/bloc/technology_event.dart';
import 'package:interview_bridge_app/features/technology/presentation/bloc/technology_state.dart';
import 'package:interview_bridge_app/features/experience/domain/entities/experience_entity.dart';
import 'package:interview_bridge_app/features/experience/domain/usecases/get_experiences_usecase.dart';
import 'package:interview_bridge_app/features/experience/presentation/bloc/experience_bloc.dart';
import 'package:interview_bridge_app/features/experience/presentation/bloc/experience_event.dart';
import 'package:interview_bridge_app/features/experience/presentation/bloc/experience_state.dart';
import 'package:interview_bridge_app/features/profile/domain/entities/profile_entity.dart';
import 'package:interview_bridge_app/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:interview_bridge_app/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:interview_bridge_app/features/profile/domain/usecases/setup_profile_usecase.dart';
import 'package:interview_bridge_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:interview_bridge_app/features/profile/presentation/bloc/profile_event.dart';
import 'package:interview_bridge_app/features/profile/presentation/bloc/profile_state.dart';

// ============================================================================
// MANUAL MOCKS
// ============================================================================

class MockGetTechnologiesUseCase implements GetTechnologiesUseCase {
  List<TechnologyEntity>? result;
  AppException? error;


  @override
  Future<List<TechnologyEntity>> call() async {
    if (error != null) {
      throw error!;
    }
    return result ?? [];
  }
}

class MockGetExperiencesUseCase implements GetExperiencesUseCase {
  List<ExperienceEntity>? result;
  AppException? error;


  @override
  Future<List<ExperienceEntity>> call() async {
    if (error != null) {
      throw error!;
    }
    return result ?? [];
  }
}

class MockGetProfileUseCase implements GetProfileUseCase {
  ProfileEntity? result;
  AppException? error;


  @override
  Future<ProfileEntity> call() async {
    if (error != null) {
      throw error!;
    }
    return result!;
  }
}

class MockUpdateProfileUseCase implements UpdateProfileUseCase {
  ProfileEntity? result;
  AppException? error;


  @override
  Future<ProfileEntity> call(String name, String technologyId, String experienceId) async {
    if (error != null) {
      throw error!;
    }
    return result!;
  }
}

class MockSetupProfileUseCase implements SetupProfileUseCase {
  ProfileEntity? result;
  AppException? error;


  @override
  Future<ProfileEntity> call(String technologyId, String experienceId) async {
    if (error != null) {
      throw error!;
    }
    return result!;
  }
}

// ============================================================================
// TESTS
// ============================================================================

void main() {
  group('TechnologyBloc', () {
    late MockGetTechnologiesUseCase mockGetTechnologies;
    late TechnologyBloc bloc;

    setUp(() {
      mockGetTechnologies = MockGetTechnologiesUseCase();
      bloc = TechnologyBloc(getTechnologiesUseCase: mockGetTechnologies);
    });

    test('initial state should be TechnologyInitial', () {
      expect(bloc.state, equals(TechnologyInitial()));
    });

    test('should emit [TechnologyLoading, TechnologyLoaded] when FetchTechnologies is successful', () async {
      final list = [
        const TechnologyEntity(id: '1', name: 'Flutter', description: 'Cross-platform SDK'),
      ];
      mockGetTechnologies.result = list;

      final expectedStates = [
        TechnologyLoading(),
        TechnologyLoaded(list),
      ];

      expectLater(bloc.stream, emitsInOrder(expectedStates));
      bloc.add(FetchTechnologies());
    });

    test('should emit [TechnologyLoading, TechnologyError] when FetchTechnologies fails', () async {
      mockGetTechnologies.error = NetworkException('Connection Error');

      final expectedStates = [
        TechnologyLoading(),
        const TechnologyError('Connection Error'),
      ];

      expectLater(bloc.stream, emitsInOrder(expectedStates));
      bloc.add(FetchTechnologies());
    });
  });

  group('ExperienceBloc', () {
    late MockGetExperiencesUseCase mockGetExperiences;
    late ExperienceBloc bloc;

    setUp(() {
      mockGetExperiences = MockGetExperiencesUseCase();
      bloc = ExperienceBloc(getExperiencesUseCase: mockGetExperiences);
    });

    test('initial state should be ExperienceInitial', () {
      expect(bloc.state, equals(ExperienceInitial()));
    });

    test('should emit [ExperienceLoading, ExperienceLoaded] when FetchExperiences is successful', () async {
      final list = [
        const ExperienceEntity(id: '1', experienceLabel: 'Mid Level'),
      ];
      mockGetExperiences.result = list;

      final expectedStates = [
        ExperienceLoading(),
        ExperienceLoaded(list),
      ];

      expectLater(bloc.stream, emitsInOrder(expectedStates));
      bloc.add(FetchExperiences());
    });

    test('should emit [ExperienceLoading, ExperienceError] when FetchExperiences fails', () async {
      mockGetExperiences.error = NetworkException('Connection Error');

      final expectedStates = [
        ExperienceLoading(),
        const ExperienceError('Connection Error'),
      ];

      expectLater(bloc.stream, emitsInOrder(expectedStates));
      bloc.add(FetchExperiences());
    });
  });

  group('ProfileBloc', () {
    late MockGetProfileUseCase mockGetProfile;
    late MockUpdateProfileUseCase mockUpdateProfile;
    late MockSetupProfileUseCase mockSetupProfile;
    late ProfileBloc bloc;

    final dummyProfile = const ProfileEntity(
      userId: '123',
      name: 'John Doe',
      email: 'john@example.com',
      role: 'USER',
    );

    setUp(() {
      mockGetProfile = MockGetProfileUseCase();
      mockUpdateProfile = MockUpdateProfileUseCase();
      mockSetupProfile = MockSetupProfileUseCase();
      bloc = ProfileBloc(
        getProfileUseCase: mockGetProfile,
        updateProfileUseCase: mockUpdateProfile,
        setupProfileUseCase: mockSetupProfile,
      );
    });

    test('initial state should be ProfileInitial', () {
      expect(bloc.state, equals(ProfileInitial()));
    });

    test('should emit [ProfileLoading, ProfileLoaded] when LoadProfile is successful', () async {
      mockGetProfile.result = dummyProfile;

      final expectedStates = [
        ProfileLoading(),
        ProfileLoaded(dummyProfile),
      ];

      expectLater(bloc.stream, emitsInOrder(expectedStates));
      bloc.add(LoadProfile());
    });

    test('should emit [ProfileUpdating, ProfileUpdateSuccess, ProfileLoaded] when UpdateProfile is successful', () async {
      final updatedProfile = const ProfileEntity(
        userId: '123',
        name: 'Jane Doe',
        email: 'john@example.com',
        role: 'USER',
      );
      mockUpdateProfile.result = updatedProfile;

      final expectedStates = [
        ProfileUpdating(),
        ProfileUpdateSuccess(updatedProfile),
        ProfileLoaded(updatedProfile),
      ];

      expectLater(bloc.stream, emitsInOrder(expectedStates));
      bloc.add(const UpdateProfileRequested(
        name: 'Jane Doe',
        technologyId: '1',
        experienceId: '2',
      ));
    });

    test('should emit [ProfileLoading, ProfileSetupSuccess, ProfileLoaded] when SetupProfileSelection is successful', () async {
      final configuredProfile = const ProfileEntity(
        userId: '123',
        name: 'John Doe',
        email: 'john@example.com',
        role: 'USER',
        technology: TechnologyEntity(id: '1', name: 'Flutter', description: 'Cross-platform SDK'),
        experience: ExperienceEntity(id: '2', experienceLabel: 'Mid Level'),
      );
      mockSetupProfile.result = configuredProfile;

      final expectedStates = [
        ProfileLoading(),
        ProfileSetupSuccess(configuredProfile),
        ProfileLoaded(configuredProfile),
      ];

      expectLater(bloc.stream, emitsInOrder(expectedStates));
      bloc.add(const SetupProfileSelection(
        technologyId: '1',
        experienceId: '2',
      ));
    });
  });
}
