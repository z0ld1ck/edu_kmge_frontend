import '../../../../core/network/api_client.dart';
import '../models/course_model.dart';
import '../models/lesson_model.dart';
import '../models/quiz_model.dart';

class CourseRemoteDataSource {
  final ApiClient _api;

  CourseRemoteDataSource(this._api);

  Future<List<CourseModel>> list({
    String? q,
    String? category,
    bool publishedOnly = true,
  }) async {
    final data = await _api.get(
      '/api/courses',
      query: {
        if (q != null && q.isNotEmpty) 'q': q,
        if (category != null) 'category': category,
        'published_only': publishedOnly,
      },
    );
    return (data as List)
        .map((e) => CourseModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<String>> categories() async {
    final data = await _api.get('/api/courses/categories');
    return (data as List).map((e) => e.toString()).toList();
  }

  Future<CourseDetailModel> detail(int id) async {
    final data = await _api.get('/api/courses/$id');
    return CourseDetailModel.fromJson(data as Map<String, dynamic>);
  }

  Future<CourseDetailModel> create(Map<String, dynamic> body) async {
    final data = await _api.post('/api/courses', body: body);
    return CourseDetailModel.fromJson(data as Map<String, dynamic>);
  }

  Future<CourseDetailModel> update(int id, Map<String, dynamic> body) async {
    final data = await _api.patch('/api/courses/$id', body: body);
    return CourseDetailModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> deleteCourse(int id) => _api.delete('/api/courses/$id');

  Future<LessonModel> addLesson(int courseId, Map<String, dynamic> body) async {
    final data = await _api.post('/api/courses/$courseId/lessons', body: body);
    return LessonModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> updateLesson(int lessonId, Map<String, dynamic> body) =>
      _api.patch('/api/courses/lessons/$lessonId', body: body);

  Future<void> deleteLesson(int lessonId) =>
      _api.delete('/api/courses/lessons/$lessonId');

  Future<LessonModel> addMaterialLink(
    int lessonId,
    Map<String, dynamic> body,
  ) async {
    final data = await _api.post(
      '/api/courses/lessons/$lessonId/materials/link',
      body: body,
    );
    return LessonModel.fromJson(data as Map<String, dynamic>);
  }

  Future<LessonModel> uploadMaterial(
    int lessonId, {
    required List<int> bytes,
    required String filename,
    required String title,
  }) async {
    final data = await _api.uploadFile(
      '/api/courses/lessons/$lessonId/materials/upload',
      bytes: bytes,
      filename: filename,
      fields: {'title': title},
    );
    return LessonModel.fromJson(data as Map<String, dynamic>);
  }

  Future<LessonModel> deleteMaterial(int lessonId, String materialId) async {
    final data = await _api.delete(
      '/api/courses/lessons/$lessonId/materials/$materialId',
    );
    return LessonModel.fromJson(data as Map<String, dynamic>);
  }

  Future<QuizModel> quiz(int courseId) async {
    final data = await _api.get('/api/courses/$courseId/quiz');
    return QuizModel.fromJson(data as Map<String, dynamic>);
  }

  Future<QuizModel> setQuiz(int courseId, Map<String, dynamic> body) async {
    final data = await _api.put('/api/courses/$courseId/quiz', body: body);
    return QuizModel.fromJson(data as Map<String, dynamic>);
  }
}
