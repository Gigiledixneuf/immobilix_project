
class HttpRequestException implements Exception {
  final int statusCode;
  final String message;
  final String? body;

  HttpRequestException(this.statusCode, this.message, this.body);

  @override
  String toString() => 'HttpRequestException: $statusCode - $message';
}
