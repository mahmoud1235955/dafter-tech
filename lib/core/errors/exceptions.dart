/// استثناءات قاعدة البيانات السحابية والمحلية
class ServerException implements Exception {
  final String message;
  const ServerException([this.message = 'حدث خطأ في الاتصال بالخادم السحابي']);

  @override
  String toString() => 'ServerException: $message';
}

class DatabaseException implements Exception {
  final String message;
  const DatabaseException([this.message = 'حدث خطأ في قاعدة البيانات المحلية']);

  @override
  String toString() => 'DatabaseException: $message';
}

class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'حدث خطأ في الذاكرة المؤقتة']);

  @override
  String toString() => 'CacheException: $message';
}

class NetworkException implements Exception {
  final String message;
  const NetworkException([this.message = 'لا يوجد اتصال بالإنترنت']);

  @override
  String toString() => 'NetworkException: $message';
}

class AuthFlowException implements Exception {
  final String message;
  const AuthFlowException([this.message = 'حدث خطأ أثناء عملية المصادقة']);

  @override
  String toString() => 'AuthFlowException: $message';
}
