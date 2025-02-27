/// Exception dédiée à la compression/décompression
class ZipperException implements Exception {
  final String message;
  final dynamic source;

  ZipperException(this.message, [this.source]);

  @override
  String toString() => 'ZipperException: $message${source != null ? ', Source: $source' : ''}';
}

/// Exception pour les validations
class ValidationException implements Exception {
  final String message;

  ValidationException(this.message);

  @override
  String toString() => 'ValidationException: $message';
}

/// Exception pour les opérations sur les fichiers
class FileOperationException implements Exception {
  final String message;
  final dynamic source;

  FileOperationException(this.message, [this.source]);

  @override
  String toString() => 'FileOperationException: $message${source != null ? ', Source: $source' : ''}';
}