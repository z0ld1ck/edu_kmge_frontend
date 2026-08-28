import '../entities/course.dart';
import '../entities/lesson.dart';
import '../entities/quiz.dart';
import '../entities/quiz_draft.dart';

abstract class CourseRepository {
  Future<List<Course>> list({String? q, String? category, bool publishedOnly});

  Future<List<String>> categories();

  Future<CourseDetail> detail(int id);

  Future<CourseDetail> create({
    required String title,
    required String description,
    required String category,
    required int passScore,
    required bool certificateEnabled,
  });

  Future<CourseDetail> update(
    int id, {
    String? title,
    String? description,
    String? category,
    int? passScore,
    bool? certificateEnabled,
    bool? isPublished,
  });

  Future<void> deleteCourse(int id);

  Future<Lesson> addLesson(
    int courseId, {
    required String title,
    required String content,
    String? videoUrl,
    required int order,
    List<LessonMaterial> materials,
  });

  Future<void> updateLesson(
    int lessonId, {
    String? title,
    String? content,
    String? videoUrl,
    List<LessonMaterial>? materials,
  });

  Future<void> deleteLesson(int lessonId);

  Future<void> reorderLessons(int courseId, List<int> lessonIds);

  Future<CourseDetail> uploadCover(
    int courseId,
    List<int> bytes,
    String filename,
  );

  Future<CourseDetail> setCoverUrl(int courseId, String? url);

  Future<Quiz> quiz(int courseId);

  Future<Lesson> addMaterialLink(
    int lessonId, {
    required String title,
    required String url,
    String type,
  });

  Future<Lesson> uploadMaterial(
    int lessonId, {
    required List<int> bytes,
    required String filename,
    required String title,
  });

  Future<Lesson> deleteMaterial(int lessonId, String materialId);

  Future<Quiz> setQuiz(
    int courseId, {
    required String title,
    required int timeLimitMinutes,
    required List<QuestionDraft> questions,
  });
}
