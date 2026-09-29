import '../entities/matched_job_entity.dart';
import '../repositories/career_pilot_repository.dart';

class GetJobDetailsUseCase {
  final CareerPilotRepository _repository;

  GetJobDetailsUseCase(this._repository);

  Future<MatchedJobEntity> call(String jobId) async {
    return await _repository.getJobDetails(jobId);
  }
}
