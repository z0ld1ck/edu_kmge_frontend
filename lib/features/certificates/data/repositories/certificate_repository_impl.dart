import '../../domain/entities/certificate.dart';
import '../../domain/repositories/certificate_repository.dart';
import '../sources/certificate_remote_datasource.dart';

class CertificateRepositoryImpl implements CertificateRepository {
  final CertificateRemoteDataSource _remote;

  CertificateRepositoryImpl(this._remote);

  @override
  Future<List<Certificate>> myCertificates() => _remote.myCertificates();

  @override
  Future<void> download(int id, String serialNumber) =>
      _remote.download(id, serialNumber);
}
