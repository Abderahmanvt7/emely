import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'announcement_details_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String searchQuery = '';
  List<Map<String, dynamic>> announcements = [];
  List<Map<String, dynamic>> filteredAnnouncements = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAnnouncements();
  }

  Future<void> fetchAnnouncements() async {
    try {
      // Fetch data from Firestore
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('announcements').get();

      // Map Firestore documents to a list
      final List<Map<String, dynamic>> loadedAnnouncements = snapshot.docs.map(
        (doc) {
          return {
            'id': doc.id,
            'imageUrl': doc['imageUrl'],
            'titre': doc['titre'],
            'nom': doc['nom'],
            'description': doc['description'],
            'age': doc['age'].toString(),
            'contact': doc['contact'],
            'dernier_date': doc['dernier_date'].toDate(),
            'dernier_lieu': doc['dernier_lieu'],
          };
        },
      ).toList();

      print('Announcements loaded');
      print(loadedAnnouncements);
      print('Announcements count: ${loadedAnnouncements.length}');

      setState(() {
        announcements = loadedAnnouncements;
        filteredAnnouncements = loadedAnnouncements;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print('error');
      print(error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load announcements')),
      );
    }
  }

  void updateSearchQuery(String query) {
    setState(() {
      searchQuery = query;
      filteredAnnouncements = announcements
          .where((announcement) =>
              announcement['titre']
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              announcement['nom'].toLowerCase().contains(query.toLowerCase()) ||
              announcement['age'].contains(query))
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
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : filteredAnnouncements.isEmpty
              ? Center(child: Text('No announcements found'))
              : ListView.builder(
                  itemCount: filteredAnnouncements.length,
                  itemBuilder: (context, index) {
                    final announcement = filteredAnnouncements[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AnnouncementDetailsScreen(
                                    announcement: announcement,
                                    currentUserId: FirebaseAuth
                                        .instance.currentUser!.uid)));
                      },
                      child: Card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.network(
                              announcement['imageUrl'],
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
                                    announcement['titre'],
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
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
          Navigator.pushNamed(context, '/createAnnouncement');
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
