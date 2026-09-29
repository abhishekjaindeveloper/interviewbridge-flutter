import '../entities/matched_job_entity.dart';

abstract class CareerPilotRepository {
  Future<List<MatchedJobEntity>> getMatchedJobs();
  Future<MatchedJobEntity> getJobDetails(String jobId);
}
