import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AnnouncementDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> announcement;
  final String currentUserId;

  // bool get isAuthor => announcement['userId'] == currentUserId;
  bool get isAuthor => true;
  bool get isFound => announcement['is_found'];
  bool get isCanceled => announcement['is_canceled'];

  AnnouncementDetailsScreen(
      {required this.announcement, required this.currentUserId});

  void _launchCaller(String number) async {
    final Uri callUri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(callUri)) {
      await launchUrl(callUri);
    } else {
      throw 'Could not launch $number';
    }
  }

  void _updateAnnouncementStatus(String docId, String field, bool value) async {
    await FirebaseFirestore.instance
        .collection('announcements')
        .doc(docId)
        .update({field: value});
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Détail de l\'annonce'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.network(
                  announcement['imageUrl'],
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              announcement['titre'],
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Divider(height: 30, thickness: 2),
            ListTile(
              leading: Icon(Icons.person),
              title: Text(localizations!.name + ':'),
              subtitle: Text(announcement['nom']),
            ),
            ListTile(
              leading: Icon(Icons.cake),
              title: Text(localizations.age + ':'),
              subtitle: Text('${announcement['age']} ans'),
            ),
            ListTile(
              leading: Icon(Icons.location_on),
              title: Text(localizations.lastLocation + ':'),
              subtitle: Text(announcement['dernier_lieu']),
            ),
            ListTile(
              leading: Icon(Icons.calendar_today),
              title: Text(localizations.lastDate + ':'),
              subtitle: Text(announcement['dernier_date'].toString()),
            ),
            ListTile(
              leading: Icon(Icons.description),
              title: Text(localizations.description + ':'),
              subtitle: Text(announcement['description']),
            ),
            SizedBox(height: 20),
            if (!isAuthor && !isFound && !isCanceled)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _launchCaller(announcement['contact']),
                  icon: Icon(Icons.phone),
                  label: Text(localizations.contact,
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            if (isAuthor && !isFound && !isCanceled)
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => {
                        _updateAnnouncementStatus(
                            announcement['id'], 'is_found', true),
                        Navigator.pop(context)
                      },
                      icon: Icon(Icons.check_circle),
                      label: Text(localizations!.iFoundIt,
                          style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => {
                        _updateAnnouncementStatus(
                            announcement['id'], 'is_canceled', true),
                        Navigator.pop(context)
                      },
                      icon: Icon(Icons.cancel),
                      label: Text(localizations.cancelAonnonce,
                          style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
