import '../../../../core/network/api_client.dart';
import '../models/attempt_model.dart';
import '../models/enrollment_model.dart';
import '../models/my_course_model.dart';
import '../models/quiz_result_model.dart';

class LearningRemoteDataSource {
  final ApiClient _api;

  LearningRemoteDataSource(this._api);

  Future<void> enroll(int courseId) =>
      _api.post('/api/courses/$courseId/enroll');

  Future<List<MyCourseModel>> myCourses() async {
    final data = await _api.get('/api/my/courses');
    return (data as List)
        .map((e) => MyCourseModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<int>> completedLessonIds(int courseId) async {
    final data = await _api.get('/api/courses/$courseId/progress');
    return (data as List).map((e) => e as int).toList();
  }

  Future<EnrollmentModel> completeLesson(int lessonId) async {
    final data = await _api.post('/api/lessons/$lessonId/complete');
    return EnrollmentModel.fromJson(data as Map<String, dynamic>);
  }

  Future<QuizResultModel> submitQuiz(
      int courseId, List<Map<String, int>> answers) async {
    final data = await _api.post(
      '/api/courses/$courseId/quiz/submit',
      body: {'answers': answers},
    );
    return QuizResultModel.fromJson(data as Map<String, dynamic>);
  }

  Future<List<AttemptModel>> myAttempts() async {
    final data = await _api.get('/api/my/attempts');
    return (data as List)
        .map((e) => AttemptModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
