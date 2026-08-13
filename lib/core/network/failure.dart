/// Единый тип ошибки прикладного уровня.
///
/// Датасорсы бросают [Failure] при ошибках сети/сервера, контроллеры ловят
/// и показывают [message] пользователю.
class Failure implements Exception {
  final String message;
  final int? statusCode;

  const Failure(this.message, {this.statusCode});

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;

  @override
  String toString() => message;
}
