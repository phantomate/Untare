import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untare/blocs/authentication/authentication_bloc.dart';
import 'package:untare/blocs/authentication/authentication_event.dart';
import 'package:untare/blocs/authentication/authentication_state.dart';
import 'package:untare/blocs/login/login_bloc.dart';
import 'package:untare/blocs/login/login_event.dart';
import 'package:untare/blocs/login/login_state.dart';
import 'package:flutter_gen/gen_l10n/app_locales.dart';

class StartingPage extends StatelessWidget {
  const StartingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          minimum: const EdgeInsets.fromLTRB(15, 15, 15, 0),
          child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
            builder: (context, state) {
              final authBloc = BlocProvider.of<AuthenticationBloc>(context);
              if (state is AuthenticationNotAuthenticated) {
                return const StartWidget(); // show authentication form
              }
              if (state is AuthenticationFailure) {
                // show error messages
                return Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(state.message),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0)),
                      ),
                      child: const Text('Retry'),
                      onPressed: () {
                        authBloc.add(AppLoaded());
                      },
                    )
                  ],
                ));
              }
              // show splash screen
              return Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).primaryColor,
                ),
              );
            },
          )),
    );
  }
}

class StartWidget extends StatelessWidget {
  const StartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final authBloc = BlocProvider.of<AuthenticationBloc>(context);

    return Container(
      alignment: Alignment.center,
      child: BlocProvider<LoginBloc>(
        create: (context) => LoginBloc(authenticationBloc: authBloc),
        child: _SignInForm(),
      ),
    );
  }
}

class _SignInForm extends StatefulWidget {
  @override
  __SignInFormState createState() => __SignInFormState();
}

class __SignInFormState extends State<_SignInForm> {
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _urlController = TextEditingController();
  AutovalidateMode _autoValidation = AutovalidateMode.disabled;

  @override
  Widget build(BuildContext context) {
    final loginBloc = BlocProvider.of<LoginBloc>(context);

    onLoginButtonPressed() {
      if (_key.currentState!.validate()) {
        loginBloc.add(LoginWithUsernameAndPassword(
            url: _urlController.text,
            username: _usernameController.text,
            password: _passwordController.text));
      } else {
        setState(() {
          _autoValidation = AutovalidateMode.always;
        });
      }
    }

    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is LoginFailure) {
          _showError(state.error);
        }
      },
      child: BlocBuilder<LoginBloc, LoginState>(
        builder: (context, state) {
          if (state is LoginLoading) {
            return Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Theme.of(context).primaryColor,
              ),
            );
          }
          return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.asset(
                    'images/tare_logo.png',
                    width: 180,
                    height: 180,
                  ),
                  const SizedBox(height: 40),
                  const Text('Unofficial Tandoor Recipes App',
                      style: TextStyle(fontSize: 24)),
                  const SizedBox(height: 30),
                  AutofillGroup(
                    child: Form(
                      key: _key,
                      autovalidateMode: _autoValidation,
                      child: FocusTraversalGroup(
                        policy: OrderedTraversalPolicy(),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Row(
                                children: [
                                  Flexible(
                                      child: FocusTraversalOrder(
                                    order: const NumericFocusOrder(1),
                                    child: TextFormField(
                                        decoration: const InputDecoration(
                                            isDense: true,
                                            hintText:
                                                'https://recipes.excample.com'),
                                        controller: _urlController,
                                        keyboardType: TextInputType.url,
                                        autocorrect: false,
                                        textInputAction: TextInputAction.next,
                                        validator: (value) =>
                                            value == null || value == ""
                                                ? 'Server url is required'
                                                : null),
                                  )),
                                  const SizedBox(width: 10),
                                  SizedBox(
                                    width: 80,
                                    child: MaterialButton(
                                      color: Theme.of(context).primaryColor,
                                      minWidth: double.maxFinite,
                                      padding: const EdgeInsets.fromLTRB(
                                          8, 4.5, 8, 4.5),
                                      child: Text(
                                          AppLocalizations.of(context)!
                                              .officialServer,
                                          style: const TextStyle(fontSize: 13),
                                          textAlign: TextAlign.center),
                                      onPressed: () {
                                        _urlController.text =
                                            'https://app.tandoor.dev';
                                      },
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: 15),
                              FocusTraversalOrder(
                                order: const NumericFocusOrder(2),
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    labelText:
                                        AppLocalizations.of(context)!.username,
                                    isDense: true,
                                  ),
                                  controller: _usernameController,
                                  textInputAction: TextInputAction.next,
                                  validator: (value) =>
                                      value == null || value == ""
                                          ? 'Username is required.'
                                          : null,
                                  autofillHints: const {AutofillHints.username},
                                ),
                              ),
                              const SizedBox(height: 15),
                              FocusTraversalOrder(
                                order: const NumericFocusOrder(3),
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    labelText:
                                        AppLocalizations.of(context)!.password,
                                  ),
                                  obscureText: true,
                                  controller: _passwordController,
                                  textInputAction: TextInputAction.send,
                                  validator: (value) =>
                                      value == null || value == ""
                                          ? 'Password is required.'
                                          : null,
                                  autofillHints: const {AutofillHints.password},
                                  onFieldSubmitted: (String _) =>
                                      onLoginButtonPressed(),
                                ),
                              ),
                              const SizedBox(height: 15),
                              MaterialButton(
                                color: Theme.of(context).primaryColor,
                                minWidth: double.maxFinite,
                                padding: const EdgeInsets.fromLTRB(8, 5, 8, 5),
                                onPressed: onLoginButtonPressed,
                                child: const Text('LOGIN'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),
                  const Text(
                      'This product uses the Tandoor Recipes API which is licensed under the GNU AGPL v3 license by vabene1111.',
                      style: TextStyle(fontSize: 8),
                      textAlign: TextAlign.center)
                ],
              ));
        },
      ),
    );
  }

  void _showError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(error),
      duration: const Duration(seconds: 8),
    ));
  }
}
