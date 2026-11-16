/// Thrown by the models when a JSON value has the wrong shape.
class ContentFormatException implements Exception {
  final String field;
  final String message;

  const ContentFormatException(this.field, this.message);

  @override
  String toString() => '$field: $message';
}
