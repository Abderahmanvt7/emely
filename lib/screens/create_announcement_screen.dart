import 'package:flutter/material.dart';

class CreateAnnouncementScreen extends StatelessWidget {
  const CreateAnnouncementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer une annonce'),
      ),
      body: const Center(
        child: Text('Formulaire pour créer une annonce'),
      ),
    );
  }
}
