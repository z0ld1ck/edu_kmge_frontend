class Attempt {
  final int id;
  final int quizId;
  final int? courseId;
  final String? courseTitle;
  final double score;
  final bool passed;
  final String createdAt;

  const Attempt({
    required this.id,
    required this.quizId,
    this.courseId,
    this.courseTitle,
    required this.score,
    required this.passed,
    required this.createdAt,
  });
}
