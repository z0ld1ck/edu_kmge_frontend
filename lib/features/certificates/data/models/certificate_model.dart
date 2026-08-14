import '../../domain/entities/certificate.dart';

class CertificateModel extends Certificate {
  const CertificateModel({
    required super.id,
    required super.serialNumber,
    required super.score,
    super.courseTitle,
    required super.issuedAt,
  });

  factory CertificateModel.fromJson(Map<String, dynamic> j) => CertificateModel(
    id: j['id'] as int,
    serialNumber: j['serial_number'] as String,
    score: ((j['score'] ?? 0) as num).toDouble(),
    courseTitle: j['course_title'] as String?,
    issuedAt: (j['issued_at'] ?? '') as String,
  );
}
