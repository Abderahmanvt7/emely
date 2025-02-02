import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/reset_password_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/create_announcement_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/locale_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // Add ChangeNotifierProvider
      create: (_) => LocaleProvider(),
      child: Consumer<LocaleProvider>(
        // Listen for locale changes
        builder: (context, localeProvider, child) {
          return MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('ar', ''), // Arabic
              Locale('fr', ''), // French
            ],
            locale: localeProvider.locale, // Use dynamic locale
            debugShowCheckedModeBanner: false,
            home: const AuthGate(),
            routes: {
              '/home': (context) => HomeScreen(),
              '/login': (context) => LoginScreen(),
              '/signup': (context) => SignupScreen(),
              '/resetPassword': (context) => ResetPasswordScreen(),
              '/profile': (context) => ProfileScreen(),
              '/createAnnouncement': (context) => CreateAnnouncementScreen(),
            },
          );
        },
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Listen to Firebase authentication state
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Check if the user is authenticated
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          // User is logged in, navigate to home screen
          return HomeScreen();
        } else {
          // User is not logged in, navigate to login screen
          return LoginScreen();
        }
      },
    );
  }
}
