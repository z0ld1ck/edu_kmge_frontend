class QuizResult {
  final double score;
  final bool passed;
  final int correct;
  final int total;
  final int? certificateId;

  const QuizResult({
    required this.score,
    required this.passed,
    required this.correct,
    required this.total,
    this.certificateId,
  });
}
