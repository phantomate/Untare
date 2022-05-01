import 'package:bloc/bloc.dart';
import 'package:hive/hive.dart';
import 'package:tare/blocs/authentication/authentication_bloc.dart';
import 'package:tare/blocs/authentication/authentication_event.dart';
import 'package:tare/services/api/api_recipe.dart';

import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  var box = Hive.box('appBox');
  final AuthenticationBloc authenticationBloc;

  LoginBloc({required this.authenticationBloc}): super(LoginInitial()) {
    on<LoginWithTokenButtonPressed>(_onLoginWithToken);
  }

  Future<void> _onLoginWithToken(LoginWithTokenButtonPressed event, Emitter<LoginState> emit) async {
    emit(LoginLoading());
    try {
      box.put('token', event.token);
      box.put('url', event.url);

      final apiRecipe = new ApiRecipe();
      final response = await apiRecipe.getRecipes('', false, 1, 1, null);

      if (response.isNotEmpty) {
        authenticationBloc.add(UserLoggedIn(token: event.token, url: event.url));
        emit(LoginSuccess());
      } else {
        emit(LoginFailure(error: 'Something very weird just happened'));
      }
    } catch (err) {
      emit(LoginFailure(error: err.toString()));
    }
  }
}