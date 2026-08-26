import '../../domain/entities/course.dart';
import '../../domain/entities/lesson.dart';
import '../../domain/entities/quiz.dart';
import '../../domain/entities/quiz_draft.dart';
import '../../domain/repositories/course_repository.dart';
import '../sources/course_remote_datasource.dart';

class CourseRepositoryImpl implements CourseRepository {
  final CourseRemoteDataSource _remote;

  CourseRepositoryImpl(this._remote);

  @override
  Future<List<Course>> list({
    String? q,
    String? category,
    bool publishedOnly = true,
  }) => _remote.list(q: q, category: category, publishedOnly: publishedOnly);

  @override
  Future<List<String>> categories() => _remote.categories();

  @override
  Future<CourseDetail> detail(int id) => _remote.detail(id);

  @override
  Future<CourseDetail> create({
    required String title,
    required String description,
    required String category,
    required int passScore,
    required bool certificateEnabled,
  }) => _remote.create({
    'title': title,
    'description': description,
    'category': category,
    'pass_score': passScore,
    'certificate_enabled': certificateEnabled,
  });

  @override
  Future<CourseDetail> update(
    int id, {
    String? title,
    String? description,
    String? category,
    int? passScore,
    bool? certificateEnabled,
    bool? isPublished,
  }) => _remote.update(id, {
    if (title != null) 'title': title,
    if (description != null) 'description': description,
    if (category != null) 'category': category,
    if (passScore != null) 'pass_score': passScore,
    if (certificateEnabled != null) 'certificate_enabled': certificateEnabled,
    if (isPublished != null) 'is_published': isPublished,
  });

  @override
  Future<void> deleteCourse(int id) => _remote.deleteCourse(id);

  @override
  Future<Lesson> addLesson(
    int courseId, {
    required String title,
    required String content,
    String? videoUrl,
    required int order,
    List<LessonMaterial> materials = const [],
  }) => _remote.addLesson(courseId, {
    'title': title,
    'content': content,
    'video_url': videoUrl,
    'order': order,
    'materials': [for (final m in materials) m.toJson()],
  });

  @override
  Future<void> updateLesson(
    int lessonId, {
    String? title,
    String? content,
    String? videoUrl,
    List<LessonMaterial>? materials,
  }) => _remote.updateLesson(lessonId, {
    if (title != null) 'title': title,
    if (content != null) 'content': content,
    'video_url': videoUrl,
    if (materials != null) 'materials': [for (final m in materials) m.toJson()],
  });

  @override
  Future<void> deleteLesson(int lessonId) => _remote.deleteLesson(lessonId);

  Future<void> reorderLessons(int courseId, List<int> lessonIds) =>
      _remote.reorderLessons(courseId, lessonIds);

  @override
  Future<Lesson> addMaterialLink(
    int lessonId, {
    required String title,
    required String url,
    String type = 'link',
  }) => _remote.addMaterialLink(lessonId, {
    'title': title,
    'url': url,
    'type': type,
  });

  @override
  Future<Lesson> uploadMaterial(
    int lessonId, {
    required List<int> bytes,
    required String filename,
    required String title,
  }) => _remote.uploadMaterial(
    lessonId,
    bytes: bytes,
    filename: filename,
    title: title,
  );

  @override
  Future<Lesson> deleteMaterial(int lessonId, String materialId) =>
      _remote.deleteMaterial(lessonId, materialId);

  @override
  Future<Quiz> quiz(int courseId) => _remote.quiz(courseId);

  @override
  Future<Quiz> setQuiz(
    int courseId, {
    required String title,
    required int timeLimitMinutes,
    required List<QuestionDraft> questions,
  }) => _remote.setQuiz(courseId, {
    'title': title,
    'time_limit_minutes': timeLimitMinutes,
    'questions': [
      for (final q in questions)
        {
          'text': q.text,
          'order': 0,
          'answers': [
            for (final a in q.answers)
              {'text': a.text, 'is_correct': a.isCorrect},
          ],
        },
    ],
  });
}
