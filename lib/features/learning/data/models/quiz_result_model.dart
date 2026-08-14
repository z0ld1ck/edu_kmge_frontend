import '../../domain/entities/quiz_result.dart';

class QuizResultModel extends QuizResult {
  const QuizResultModel({
    required super.score,
    required super.passed,
    required super.correct,
    required super.total,
    super.certificateId,
  });

  factory QuizResultModel.fromJson(Map<String, dynamic> j) => QuizResultModel(
    score: ((j['score'] ?? 0) as num).toDouble(),
    passed: (j['passed'] ?? false) as bool,
    correct: (j['correct'] ?? 0) as int,
    total: (j['total'] ?? 0) as int,
    certificateId: j['certificate_id'] as int?,
  );
}
