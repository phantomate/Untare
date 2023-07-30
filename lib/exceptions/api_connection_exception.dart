class ApiConnectionException implements Exception{
  final String message;

  ApiConnectionException({this.message = 'Api error'});
}