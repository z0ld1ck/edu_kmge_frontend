import '../../../../core/network/api_client.dart';
import '../models/certificate_model.dart';

class CertificateRemoteDataSource {
  final ApiClient _api;

  CertificateRemoteDataSource(this._api);

  Future<List<CertificateModel>> myCertificates() async {
    final data = await _api.get('/api/certificates');
    return (data as List)
        .map((e) => CertificateModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> download(int id, String serialNumber) => _api.download(
    '/api/certificates/$id/download',
    'certificate-$serialNumber.pdf',
  );
}
