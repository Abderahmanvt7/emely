import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _auth = FirebaseAuth.instance; // Instance de Firebase Auth
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  String confirmPassword = '';

  void signUp() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Compte créé avec succès !")),
        );
        Navigator.pop(context); // Retour à l'écran précédent
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Créer un compte")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) => email = value,
                validator: (value) =>
                    value!.isEmpty ? "Veuillez entrer un email valide" : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Mot de passe'),
                obscureText: true,
                onChanged: (value) => password = value,
                validator: (value) =>
                    value!.length < 6 ? "6 caractères minimum" : null,
              ),
              TextFormField(
                decoration:
                    InputDecoration(labelText: 'Confirmer le mot de passe'),
                obscureText: true,
                onChanged: (value) => confirmPassword = value,
                validator: (value) => value != password
                    ? "Les mots de passe ne correspondent pas"
                    : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: signUp,
                child: Text("Créer un compte"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
