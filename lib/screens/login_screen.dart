import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  String? _email;
  String? _password;
  String _errorMessage = '';

  bool _isLoading = false;

  void _loginUser() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      try {
        await _auth.signInWithEmailAndPassword(
          email: _email!,
          password: _password!,
        );

        // Navigate to Écran Accueille upon success
        Navigator.pushReplacementNamed(context, '/home');
      } catch (error) {
        print('Error: $error');
        setState(() {
          _errorMessage = _handleFirebaseError(error);
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _handleFirebaseError(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
          return AppLocalizations.of(context)!.invalidEmail;
        case 'invalid-credential':
          return AppLocalizations.of(context)!.invalidCredential;
        default:
          return AppLocalizations.of(context)!.unknownError;
      }
    }
    return AppLocalizations.of(context)!.unknownError;
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  localization!.login ?? 'Login',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: localization!.email ?? 'E-mail',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return localization!.enterValidEmail ??
                          'Please enter your email.';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _email = value;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: localization!.password ?? 'Mot de passe',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return localization!.enterValidPassword ??
                          'Please enter your password.';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _password = value;
                  },
                ),
                const SizedBox(height: 10),
                if (_errorMessage.isNotEmpty)
                  Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _isLoading ? null : _loginUser,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(localization!.login ?? 'Login'),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(localization!.doNotHaveAnAccount ?? 'Pas de compte ?'),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/signup');
                      },
                      child: Text(
                        " " + localization!.createAnAccount ??
                            'Créer un compte',
                        style: const TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/resetPassword');
                  },
                  child: Text(
                    localization!.forgotPassword ?? 'Mot de passe oublié',
                    style: const TextStyle(
                      color: Colors.blueAccent,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
