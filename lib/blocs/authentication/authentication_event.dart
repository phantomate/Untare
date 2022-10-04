import 'package:untare/blocs/abstract_event.dart';

abstract class AuthenticationEvent extends AbstractEvent {}

class AppLoaded extends AuthenticationEvent {}

class UserLoggedIn extends AuthenticationEvent {
  final String token;
  final String url;


  UserLoggedIn({required this.token, required this.url});

  @override
  List<Object> get props => [token, url];
}

class UserLoggedOut extends AuthenticationEvent {}

class AuthenticationError extends AuthenticationEvent {}