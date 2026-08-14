import 'package:flutter/foundation.dart';

import '../../domain/entities/certificate.dart';
import '../../domain/repositories/certificate_repository.dart';

class CertificatesController extends ChangeNotifier {
  final CertificateRepository _repo;

  CertificatesController(this._repo);

  List<Certificate> items = [];
  bool loading = true;
  String? error;

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      items = await _repo.myCertificates();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> download(Certificate cert) =>
      _repo.download(cert.id, cert.serialNumber);
}
