import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:tare/blocs/authentication/authentication_bloc.dart';
import 'package:tare/blocs/authentication/authentication_event.dart';
import 'package:tare/exceptions/api_exception.dart';
import 'package:tare/models/user.dart';
import 'package:tare/models/userToken.dart';

import 'package:tare/services/api/api_user.dart';

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
      final UserToken userToken = await apiUser.createAuthToken(event.username, event.password);

      box.put('token', userToken.token);

      final response = await apiUser.getUsers();
      User loggedInUser = response.firstWhere((element) => element.id == userToken.userId);

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
    } catch (err) {
      emit(LoginFailure(error: err.toString()));
    }
  }
}