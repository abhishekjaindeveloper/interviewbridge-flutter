import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_matched_jobs_usecase.dart';
import '../../domain/usecases/get_job_details_usecase.dart';
import 'career_pilot_event.dart';
import 'career_pilot_state.dart';

class CareerPilotBloc extends Bloc<CareerPilotEvent, CareerPilotState> {
  final GetMatchedJobsUseCase getMatchedJobsUseCase;
  final GetJobDetailsUseCase getJobDetailsUseCase;

  CareerPilotBloc({
    required this.getMatchedJobsUseCase,
    required this.getJobDetailsUseCase,
  }) : super(CareerPilotInitial()) {
    on<FetchMatchedJobsRequested>(_onFetchMatchedJobsRequested);
    on<FetchJobDetailsRequested>(_onFetchJobDetailsRequested);
  }

  Future<void> _onFetchMatchedJobsRequested(
    FetchMatchedJobsRequested event,
    Emitter<CareerPilotState> emit,
  ) async {
    emit(CareerPilotLoading());
    try {
      final jobs = await getMatchedJobsUseCase();
      if (jobs.isEmpty) {
        emit(CareerPilotJobsEmpty());
      } else {
        emit(CareerPilotJobsLoaded(jobs));
      }
    } catch (e) {
      final message = e.toString().replaceFirst('AppException: ', '');
      emit(CareerPilotError(message));
    }
  }

  Future<void> _onFetchJobDetailsRequested(
    FetchJobDetailsRequested event,
    Emitter<CareerPilotState> emit,
  ) async {
    emit(JobDetailsLoading());
    try {
      final job = await getJobDetailsUseCase(event.jobId);
      emit(JobDetailsLoaded(job));
    } catch (e) {
      final message = e.toString().replaceFirst('AppException: ', '');
      emit(JobDetailsError(message));
    }
  }
}
