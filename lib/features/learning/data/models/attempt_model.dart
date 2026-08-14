import '../../domain/entities/attempt.dart';

class AttemptModel extends Attempt {
  const AttemptModel({
    required super.id,
    required super.quizId,
    super.courseId,
    super.courseTitle,
    required super.score,
    required super.passed,
    required super.createdAt,
  });

  factory AttemptModel.fromJson(Map<String, dynamic> j) => AttemptModel(
    id: j['id'] as int,
    quizId: j['quiz_id'] as int,
    courseId: j['course_id'] as int?,
    courseTitle: j['course_title'] as String?,
    score: ((j['score'] ?? 0) as num).toDouble(),
    passed: (j['passed'] ?? false) as bool,
    createdAt: (j['created_at'] ?? '') as String,
  );
}
