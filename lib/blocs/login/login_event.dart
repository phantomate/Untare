import 'package:untare/blocs/abstract_event.dart';

abstract class LoginEvent extends AbstractEvent {}

class LoginWithUsernameAndPassword extends LoginEvent {
  final String url;
  final String username;
  final String password;

  LoginWithUsernameAndPassword({required this.url, required this.username, required this.password});

  @override
  List<Object> get props => [url, username, password];
}
