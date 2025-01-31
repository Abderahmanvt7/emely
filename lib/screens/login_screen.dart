import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    // Map Firebase exceptions to user-friendly messages
    switch (error.toString()) {
      case '[firebase_auth/invalid-email]':
        return 'L\'adresse e-mail est invalide.';
      case '[firebase_auth/user-not-found]':
        return 'Utilisateur introuvable.';
      case '[firebase_auth/wrong-password]':
        return 'Mot de passe incorrect.';
      default:
        return 'Une erreur est survenue. Veuillez réessayer.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Connexion',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'E-mail',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre e-mail.';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _email = value;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Mot de passe',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre mot de passe.';
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
                      : const Text('Connexion'),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/signup');
                  },
                  child: const Text('Créer un compte'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/reset-password');
                  },
                  child: const Text('Mot de passe oublié ?'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
