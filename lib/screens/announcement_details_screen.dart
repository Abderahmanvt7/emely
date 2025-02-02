import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'edit_announcement_screen.dart';

class AnnouncementDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> announcement;
  final String currentUserId;

  bool get isAuthor => announcement['userId'] == currentUserId;
  bool get isFound => announcement['is_found'];
  bool get isCanceled => announcement['is_canceled'];

  AnnouncementDetailsScreen(
      {required this.announcement, required this.currentUserId});

  void _launchCaller(String phoneNumber, BuildContext context) async {
    // Remove any non-digit characters from the phone number
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

    // Ensure the number starts with a plus sign if it doesn't already
    final formattedNumber =
        cleanNumber.startsWith('+') ? cleanNumber : '+$cleanNumber';

    final Uri callUri = Uri.parse('tel:$formattedNumber');

    try {
      if (await canLaunchUrl(callUri)) {
        await launchUrl(callUri);
      } else {
        // Show error message if the URL can't be launched
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.cantLaunchPhone ??
                  'Unable to launch phone call'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Show error message if there's an exception
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.phoneError ??
                'Error launching phone call'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
        actions: [
          if (isAuthor && !isFound && !isCanceled)
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditAnnouncementScreen(
                      announcement: announcement,
                    ),
                  ),
                );
                Navigator.pop(context);
              },
              tooltip: localizations?.editAnnouncement ?? 'Edit Announcement',
            ),
        ],
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
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 200,
                      color: Colors.grey[200],
                      child: Icon(Icons.broken_image, size: 50),
                    );
                  },
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
            ListTile(
              leading: Icon(Icons.phone),
              title: Text(localizations!.phoneNumber + ':'),
              subtitle: Text(announcement['contact']),
            ),
            SizedBox(height: 20),
            if (!isAuthor && !isFound && !isCanceled)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () =>
                      _launchCaller(announcement['contact'], context),
                  icon: Icon(Icons.phone),
                  label: Text(localizations.contact),
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
                      label: Text(localizations.iFoundIt,
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
