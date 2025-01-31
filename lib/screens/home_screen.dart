import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dummy data for announcements
    final List<Map<String, String>> announcements = [
      {
        'photo': 'https://picsum.photos/300/200',
        'titre': 'Annonce 1',
        'nom': 'John Doe',
        'age': '25'
      },
      {
        'photo': 'https://picsum.photos/300/200',
        'titre': 'Annonce 2',
        'nom': 'Jane Smith',
        'age': '30'
      },
      {
        'photo': 'https://picsum.photos/300/200',
        'titre': 'Annonce 3',
        'nom': 'Ahmed Ali',
        'age': '35'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
            icon: const Icon(Icons.person),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: announcements.length,
        itemBuilder: (context, index) {
          final announcement = announcements[index];

          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/announcementDetails',
                  arguments: announcement);
            },
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: Image.network(
                      announcement['photo']!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Texts
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          announcement['titre']!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Nom: ${announcement['nom']}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        Text(
                          'Âge: ${announcement['age']} ans',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/createAnnouncement');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
