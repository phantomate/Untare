import 'package:bloc/bloc.dart';
import 'package:hive/hive.dart';

import 'authentication_event.dart';
import 'authentication_state.dart';

class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  var box = Hive.box('unTaReBox');

  AuthenticationBloc(): super(AuthenticationInitial()) {
    on<AppLoaded>(_onAppLoaded);
    on<UserLoggedIn>(_onUserLoggedIn);
    on<UserLoggedOut>(_onUserLoggedOut);
    on((AuthenticationError event, Emitter<AuthenticationState> emit) => emit(AuthenticationNotAuthenticated()));
  }

  Future<void> _onAppLoaded(AppLoaded event, Emitter<AuthenticationState> emit) async {
    emit(AuthenticationLoading());
    final token = box.get('token');
    final url = box.get('url');

    if (token != null && url != null) {
      emit(AuthenticationAuthenticated(token: token, url: url));
    } else {
      emit(AuthenticationNotAuthenticated());
    }
  }

  Future<void> _onUserLoggedIn(UserLoggedIn event, Emitter<AuthenticationState> emit) async {
    emit(AuthenticationAuthenticated(token: event.token, url: event.url));
  }

  Future<void> _onUserLoggedOut(UserLoggedOut event, Emitter<AuthenticationState> emit) async {
    box.clear();
    emit(AuthenticationNotAuthenticated());
  }
}