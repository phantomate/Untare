import 'package:untare/blocs/abstract_state.dart';

abstract class AuthenticationState extends AbstractState {}

class AuthenticationInitial extends AuthenticationState {}

class AuthenticationLoading extends AuthenticationState {}

class AuthenticationNotAuthenticated extends AuthenticationState {}

class AuthenticationAuthenticated extends AuthenticationState {
  final String token;
  final String url;

  AuthenticationAuthenticated({required this.token, required this.url});

  @override
  List<Object> get props => [token, url];
}

class AuthenticationFailure extends AuthenticationState {
  final String message;

  AuthenticationFailure({required this.message});

  @override
  List<Object> get props => [message];
}