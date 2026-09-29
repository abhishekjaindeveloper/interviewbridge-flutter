import '../entities/matched_job_entity.dart';
import '../repositories/career_pilot_repository.dart';

class GetMatchedJobsUseCase {
  final CareerPilotRepository _repository;

  GetMatchedJobsUseCase(this._repository);

  Future<List<MatchedJobEntity>> call() async {
    return await _repository.getMatchedJobs();
  }
}
