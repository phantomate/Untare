// ignore_for_file: depend_on_referenced_packages

import 'package:bloc/bloc.dart';
import 'package:hive/hive.dart';
import 'package:untare/blocs/authentication/authentication_bloc.dart';
import 'package:untare/blocs/authentication/authentication_event.dart';
import 'package:untare/exceptions/api_connection_exception.dart';
import 'package:untare/exceptions/api_exception.dart';
import 'package:untare/models/user.dart';
import 'package:untare/models/userToken.dart';

import 'package:untare/services/api/api_user.dart';

import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  var box = Hive.box('unTaReBox');
  final AuthenticationBloc authenticationBloc;

  LoginBloc({required this.authenticationBloc}): super(LoginInitial()) {
    on<LoginWithUsernameAndPassword>(_onLoginWithToken);
  }

  Future<void> _onLoginWithToken(LoginWithUsernameAndPassword event, Emitter<LoginState> emit) async {
    emit(LoginLoading());
    try {
      String url = event.url.trim();
      if (url.endsWith('/')) {
        url = url.substring(0, url.length - 1);
      }

      box.put('url', url);

      final apiUser = ApiUser();
      try {
        final UserToken userToken = await apiUser.createAuthToken(event.username, event.password);
        box.put('token', userToken.token);
      } on ApiException catch(e) {
        // User/pass don't work, is the password an API Token? If it's not it'll fail at next step anyway.
        box.put('token', event.password);
      }

      final response = await apiUser.getUsers();
      User loggedInUser = response.firstWhere((element) => element.username == event.username);

      box.put('user', loggedInUser);
      box.put('users', response);

      authenticationBloc.add(UserLoggedIn(token: userToken.token, url: url));
      emit(LoginSuccess());
    } on ApiException catch(e) {
      if (e.statusCode == 400) {
        emit(LoginFailure(error: 'Unable to log in with provided credentials'));
      } else {
        emit(LoginFailure(error: e.message ?? e.toString()));
      }
    } on ApiConnectionException catch(e) {
      emit(LoginFailure(error: e.message));
    } catch (err) {
      emit(LoginFailure(error: err.toString()));
    }
  }
}