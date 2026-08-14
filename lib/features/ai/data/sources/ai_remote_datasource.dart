import '../../../../core/network/api_client.dart';

class AiRemoteDataSource {
  final ApiClient _api;

  AiRemoteDataSource(this._api);

  Future<bool> status() async {
    final data = await _api.get('/api/ai/status');
    return (data['enabled'] ?? false) as bool;
  }

  Future<String> chat(
      int courseId, String message, List<Map<String, String>> history) async {
    final data = await _api.post('/api/ai/chat', body: {
      'course_id': courseId,
      'message': message,
      'history': history,
    });
    return data['reply'] as String;
  }

  Future<Map<String, dynamic>> generateQuiz(int courseId, int num) async {
    final data = await _api.post('/api/ai/generate-quiz', body: {
      'course_id': courseId,
      'num_questions': num,
    });
    return data as Map<String, dynamic>;
  }
}
