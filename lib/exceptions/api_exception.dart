class ApiException implements Exception{
  final String? message;
  final int statusCode;

  ApiException({this.message = 'Api error', required this.statusCode});
}