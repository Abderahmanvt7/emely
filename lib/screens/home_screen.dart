import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

  String searchQuery = '';
  List<Map<String, String>> filteredAnnouncements = [];

  @override
  void initState() {
    super.initState();
    filteredAnnouncements = announcements; // Initially, show all announcements
  }

  void updateSearchQuery(String query) {
    setState(() {
      searchQuery = query;
      filteredAnnouncements = announcements
          .where((announcement) =>
              announcement['titre']!
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              announcement['nom']!
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              announcement['age']!.contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emely'),
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
              onChanged: updateSearchQuery,
              decoration: InputDecoration(
                hintText: 'Rechercher...',
                border: InputBorder.none,
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: filteredAnnouncements.length,
        itemBuilder: (context, index) {
          final announcement = filteredAnnouncements[index];
          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                '/announcementDetails',
                arguments: announcement,
              );
            },
            child: Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(
                    announcement['photo']!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        height: 200,
                        child: Icon(Icons.broken_image, size: 50),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          announcement['titre']!,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text('Nom: ${announcement['nom']}'),
                        Text('Âge: ${announcement['age']}'),
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
          Navigator.pushNamed(context, '/create-announcement');
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
