class ServerException implements Exception {
  final String message;
  
  ServerException({required this.message});
}

class CacheException implements Exception {
  final String message;
  
  CacheException({required this.message});
}

class ConnectionException implements Exception {
  final String message;
  
  ConnectionException({required this.message});
}

class UnauthorizedException implements Exception {
  final String message;
  
  UnauthorizedException({required this.message});
}
