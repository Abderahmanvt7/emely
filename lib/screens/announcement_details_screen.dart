import 'package:flutter/material.dart';

class AnnouncementDetailsScreen extends StatelessWidget {
  const AnnouncementDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    final id = args?['id'] ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de l\'annonce'),
      ),
      body: Center(
        child: Text('Détails de l\'annonce $id'),
      ),
    );
  }
}
