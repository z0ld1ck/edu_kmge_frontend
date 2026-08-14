import '../../../../core/network/api_client.dart';
import '../models/analytics_models.dart';

class AnalyticsRemoteDataSource {
  final ApiClient _api;

  AnalyticsRemoteDataSource(this._api);

  Future<OverviewStatsModel> overview() async {
    final data = await _api.get('/api/analytics/overview');
    return OverviewStatsModel.fromJson(data as Map<String, dynamic>);
  }

  Future<List<CourseStatModel>> courseStats() async {
    final data = await _api.get('/api/analytics/courses');
    return (data as List)
        .map((e) => CourseStatModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<UserProgressStatModel>> userStats() async {
    final data = await _api.get('/api/analytics/users');
    return (data as List)
        .map((e) => UserProgressStatModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> exportUsersXlsx() => _api.download(
    '/api/analytics/export/users.xlsx',
    'users-progress.xlsx',
  );
}
