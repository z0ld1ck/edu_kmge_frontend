class Certificate {
  final int id;
  final String serialNumber;
  final double score;
  final String? courseTitle;
  final String issuedAt;

  const Certificate({
    required this.id,
    required this.serialNumber,
    required this.score,
    this.courseTitle,
    required this.issuedAt,
  });
}
