import '../../domain/entities/attempt.dart';
import '../../domain/entities/enrollment.dart';
import '../../domain/entities/my_course.dart';
import '../../domain/entities/quiz_result.dart';
import '../../domain/repositories/learning_repository.dart';
import '../sources/learning_remote_datasource.dart';

class LearningRepositoryImpl implements LearningRepository {
  final LearningRemoteDataSource _remote;

  LearningRepositoryImpl(this._remote);

  @override
  Future<void> enroll(int courseId) => _remote.enroll(courseId);

  @override
  Future<List<MyCourse>> myCourses() => _remote.myCourses();

  @override
  Future<List<int>> completedLessonIds(int courseId) =>
      _remote.completedLessonIds(courseId);

  @override
  Future<Enrollment> completeLesson(int lessonId) =>
      _remote.completeLesson(lessonId);

  @override
  Future<QuizResult> submitQuiz(int courseId, Map<int, int> answers) {
    final payload = answers.entries
        .map((e) => {'question_id': e.key, 'answer_id': e.value})
        .toList();
    return _remote.submitQuiz(courseId, payload);
  }

  @override
  Future<List<Attempt>> myAttempts() => _remote.myAttempts();
}
