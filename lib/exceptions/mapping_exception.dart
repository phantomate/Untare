class MappingException implements Exception{
  final String? message;

  MappingException({this.message = 'Mapping error'});
}