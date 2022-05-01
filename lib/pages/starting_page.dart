import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tare/blocs/authentication/authentication_bloc.dart';
import 'package:tare/blocs/authentication/authentication_event.dart';
import 'package:tare/blocs/authentication/authentication_state.dart';
import 'package:tare/blocs/login/login_bloc.dart';
import 'package:tare/blocs/login/login_event.dart';
import 'package:tare/blocs/login/login_state.dart';
import 'package:tare/constants/colors.dart';

class StartingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
            minimum: const EdgeInsets.all(16),
            child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
              builder: (context, state){
                final authBloc = BlocProvider.of<AuthenticationBloc>(context);
                if (state is AuthenticationNotAuthenticated){
                  return StartWidget(); // show authentication form
                }
                if (state is AuthenticationFailure) {
                  // show error message
                  return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(state.message),
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.all(16),
                              shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(8.0)),
                            ),
                            child: Text('Retry'),
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
                    color: primaryColor,
                  ),
                );
              },
            )
        ),
      )
    );
  }
}

class StartWidget extends StatelessWidget {
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
  final _tokenController = TextEditingController();
  final _urlController = TextEditingController();
  AutovalidateMode _autoValidation = AutovalidateMode.disabled;


  @override
  Widget build(BuildContext context) {
    final _loginBloc = BlocProvider.of<LoginBloc>(context);

    _onLoginButtonPressed () {
      if (_key.currentState!.validate()) {
        _loginBloc.add(LoginWithTokenButtonPressed(
            url: _urlController.text,
            token: _tokenController.text
        ));
      } else {
        setState(() {
          _autoValidation = AutovalidateMode.always;
        });
      }
    }

    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state){
        if (state is LoginFailure){
          _showError(state.error);
        }
      },
      child: BlocBuilder<LoginBloc, LoginState>(
        builder: (context, state){
          if (state is LoginLoading){
            return Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: primaryColor,
              ),
            );
          }
          return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Form(
                key: _key,
                autovalidateMode: _autoValidation,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Server Url',
                          isDense: true,
                        ),
                        controller: _urlController,
                        keyboardType: TextInputType.name,
                        autocorrect: false,
                        validator: (value){
                          if (value == null){
                            return 'Server url is required';
                          }
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Api Token',
                          isDense: true,
                        ),
                        obscureText: true,
                        controller: _tokenController,
                        validator: (value) {
                          if (value == null){
                            return 'Api token is required.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 35,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: primaryColor,
                          onPrimary: Colors.black87,
                          padding: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(8.0)),
                        ),
                        child: Text('LOG IN'),
                        onPressed: _onLoginButtonPressed,
                      )
                    ],
                  ),
                ),
              )
          );
        },
      ),
    );
  }

  void _showError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(error),
            duration: Duration(seconds: 8),
        )
    );
  }
}
