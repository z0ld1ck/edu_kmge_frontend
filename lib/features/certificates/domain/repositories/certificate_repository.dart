import '../entities/certificate.dart';

abstract class CertificateRepository {
  Future<List<Certificate>> myCertificates();

  /// Скачивание PDF в браузере.
  Future<void> download(int id, String serialNumber);
}
