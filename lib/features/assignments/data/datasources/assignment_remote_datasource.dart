import '../../../../core/network/api_client.dart';
import '../models/assignment_model.dart';

class AssignmentRemoteDataSource {
  final ApiClient _api;

  AssignmentRemoteDataSource(this._api);

  Future<List<AssignmentModel>> list({
    int? courseId,
    String? department,
    String? status,
  }) async {
    final data = await _api.get('/api/admin/assignments', query: {
      if (courseId != null) 'course_id': courseId,
      if (department != null && department.isNotEmpty) 'department': department,
      if (status != null && status.isNotEmpty) 'status': status,
    });
    return (data as List)
        .map((e) => AssignmentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<int> create(Map<String, dynamic> body) async {
    final data = await _api.post('/api/admin/assignments', body: body);
    return ((data as Map)['assigned'] ?? 0) as int;
  }

  Future<void> remove(int enrollmentId) =>
      _api.delete('/api/admin/assignments/$enrollmentId');
}
