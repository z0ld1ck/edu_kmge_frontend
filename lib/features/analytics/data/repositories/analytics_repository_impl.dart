import '../../domain/entities/analytics.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../sources//analytics_remote_datasource.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final AnalyticsRemoteDataSource _remote;

  AnalyticsRepositoryImpl(this._remote);

  @override
  Future<OverviewStats> overview() => _remote.overview();

  @override
  Future<List<CourseStat>> courseStats() => _remote.courseStats();

  @override
  Future<List<UserProgressStat>> userStats() => _remote.userStats();

  @override
  Future<void> exportUsersXlsx() => _remote.exportUsersXlsx();
}
