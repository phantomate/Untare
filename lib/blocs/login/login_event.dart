import 'package:tare/blocs/abstract_event.dart';

abstract class LoginEvent extends AbstractEvent {}

class LoginWithTokenButtonPressed extends LoginEvent {
  final String url;
  final String token;

  LoginWithTokenButtonPressed({required this.url, required this.token});

  @override
  List<Object> get props => [url, token];
}