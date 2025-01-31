import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'screens/signup_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/announcement_details_screen.dart';
import 'screens/create_announcement_screen.dart';

void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // Show a loading screen while checking authentication
      home: const AuthGate(),
      routes: {
        '/profile': (context) => const ProfileScreen(),
        '/announcementDetails': (context) => const AnnouncementDetailsScreen(),
        '/createAnnouncement': (context) => const CreateAnnouncementScreen(),
      },
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
          return const HomeScreen();
        } else {
          // User is not logged in, navigate to login screen
          return LoginScreen();
        }
      },
    );
  }
}
