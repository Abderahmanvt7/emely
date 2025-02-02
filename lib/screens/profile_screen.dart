import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:emely/providers/locale_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User user;

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser!;
  }

  void _changePassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChangePasswordScreen()),
    );
  }

  void changeLanguage(String language) {
    final provider = Provider.of<LocaleProvider>(context, listen: false);
    if (language == 'Arabe') {
      provider.setLocale(const Locale('ar'));
    } else {
      provider.setLocale(const Locale('fr'));
    }
  }

  void _logout() async {
    await _auth.signOut();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    String selectedLocale = Localizations.localeOf(context).languageCode;
    String selectedLanguage = selectedLocale == 'ar' ? 'Arabe' : 'Français';
    final localization = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localization!.profile),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 40,
                child: Icon(Icons.person, size: 50),
              ),
            ),
            SizedBox(height: 16),
            Text('${localization!.email}: ${user.email}',
                style: TextStyle(fontSize: 18)),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(localization!.language, style: TextStyle(fontSize: 16)),
                DropdownButton<String>(
                  value: selectedLanguage,
                  items: ['Arabe', 'Français'].map((String language) {
                    return DropdownMenuItem<String>(
                      value: language,
                      child: Text(language),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    if (newValue != null) {
                      changeLanguage(newValue);
                    }
                  },
                ),
              ],
            ),
            Divider(),
            ListTile(
              title: Text(localization!.changePassword,
                  style: TextStyle(fontSize: 18)),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: _changePassword,
            ),
            Divider(),
            ListTile(
              title: Text(localization!.logout,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.red,
                  )),
              trailing: Icon(Icons.logout, color: Colors.red),
              onTap: _logout,
            ),
          ],
        ),
      ),
    );
  }
}

class ChangePasswordScreen extends StatefulWidget {
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();

  Future<void> _changePassword() async {
    if (_formKey.currentState!.validate()) {
      try {
        User? user = FirebaseAuth.instance.currentUser;

        // Reauthenticate user
        AuthCredential credential = EmailAuthProvider.credential(
          email: user!.email!,
          password: currentPasswordController.text,
        );

        await user.reauthenticateWithCredential(credential);

        // Update password
        await user.updatePassword(newPasswordController.text);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  AppLocalizations.of(context)!.passwordChangedSuccessfully)),
          // navigate back to profile screen
        );
        Navigator.pop(context);
      } catch (e) {
        print(e);
        if (e is FirebaseAuthException) {
          if (e.code == 'invalid-credential') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      AppLocalizations.of(context)!.currentPasswordIncorrect)),
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(localization!.changePassword),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: currentPasswordController,
                obscureText: true,
                decoration:
                    InputDecoration(labelText: localization!.currentPassword),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return localization.currentPasswordRequired;
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: newPasswordController,
                obscureText: true,
                decoration:
                    InputDecoration(labelText: localization!.newPassword),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return localization.newPasswordRequired;
                  }
                  if (value.length < 6) {
                    return localization.passwordShouldBeLongerThanSixCharacters;
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _changePassword,
                child: Text(localization.changePassword),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
