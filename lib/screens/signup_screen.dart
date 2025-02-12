import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  String confirmPassword = '';

  bool isLoading = false;

  void signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      try {
        await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(AppLocalizations.of(context)!.accountCreatedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacementNamed(context, '/login');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    localization!.createAnAccount,
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
                      labelText: localization.email,
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) => email = value,
                    validator: (value) =>
                        value!.isEmpty ? localization.enterValidEmail : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: localization.password,
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    onChanged: (value) => password = value,
                    validator: (value) => value!.length < 6
                        ? localization.passwordShouldBeLongerThanSixCharacters
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: localization.confirmPassword,
                      prefixIcon: Icon(Icons.lock_outline),
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    onChanged: (value) => confirmPassword = value,
                    validator: (value) => value != password
                        ? localization.passwordsDoNotMatch
                        : null,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: signUp,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            localization.createAnAccount,
                            style: TextStyle(fontSize: 18),
                          ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () =>
                        Navigator.pushReplacementNamed(context, '/login'),
                    child: Text(
                      localization.alreadyHaveAnAccount,
                      style: TextStyle(
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
      ),
    );
  }
}
