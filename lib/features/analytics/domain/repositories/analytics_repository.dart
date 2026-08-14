import '../entities/analytics.dart';

abstract class AnalyticsRepository {
  Future<OverviewStats> overview();

  Future<List<CourseStat>> courseStats();

  Future<List<UserProgressStat>> userStats();

  Future<void> exportUsersXlsx();
}
