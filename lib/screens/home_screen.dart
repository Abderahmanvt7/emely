import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'announcement_details_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  String searchQuery = '';
  List<Map<String, dynamic>> announcements = [];
  List<Map<String, dynamic>> filteredAnnouncements = [];
  bool isLoading = true;
  late RouteObserver<ModalRoute> routeObserver;

  @override
  void initState() {
    super.initState();
    routeObserver = RouteObserver<ModalRoute>();
    fetchAnnouncements();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Refetch when returning to this screen
    fetchAnnouncements();
  }

  Future<void> fetchAnnouncements() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Fetch data from Firestore
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('announcements')
          // filter out canceled and found announcements
          .where('is_canceled', isEqualTo: false)
          .where('is_found', isEqualTo: false)
          .orderBy('createdAt',
              descending: true) // Added ordering by creation date
          .get();

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
            'is_found': doc['is_found'],
            'is_canceled': doc['is_canceled'],
            'userId': doc['userId'],
            'createdAt': doc['createdAt'].toDate(),
            'updatedAt': doc['updatedAt'].toDate(),
          };
        },
      ).toList();

      if (mounted) {
        setState(() {
          announcements = loadedAnnouncements;
          filteredAnnouncements = loadedAnnouncements;
          isLoading = false;
        });
      }
    } catch (error) {
      print('Error fetching announcements: $error');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Échec du chargement des annonces')),
        );
      }
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
            onPressed: () async {
              await Navigator.pushNamed(context, '/profile');
              // Refetch when returning from profile screen
              fetchAnnouncements();
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
              decoration: const InputDecoration(
                hintText: 'Rechercher...',
                border: InputBorder.none,
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: fetchAnnouncements,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : filteredAnnouncements.isEmpty
                ? const Center(child: Text('Aucune annonce trouvée'))
                : ListView.builder(
                    itemCount: filteredAnnouncements.length,
                    itemBuilder: (context, index) {
                      final announcement = filteredAnnouncements[index];
                      return GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AnnouncementDetailsScreen(
                                announcement: announcement,
                                currentUserId:
                                    FirebaseAuth.instance.currentUser!.uid,
                              ),
                            ),
                          );
                          // Refetch when returning from details screen
                          fetchAnnouncements();
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
                                    child: const Icon(Icons.broken_image,
                                        size: 50),
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
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(context, '/createAnnouncement');
          // Refetch when returning from create announcement screen
          fetchAnnouncements();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
