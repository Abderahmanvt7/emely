import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EditAnnouncementScreen extends StatefulWidget {
  final Map<String, dynamic> announcement;

  const EditAnnouncementScreen({Key? key, required this.announcement})
      : super(key: key);

  @override
  _EditAnnouncementScreenState createState() => _EditAnnouncementScreenState();
}

class _EditAnnouncementScreenState extends State<EditAnnouncementScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController titleController;
  late TextEditingController nameController;
  late TextEditingController ageController;
  late TextEditingController descriptionController;
  late TextEditingController lastLocationController;
  late TextEditingController contactController;
  late DateTime selectedDate;
  File? imageFile;
  String? imageUrl;
  bool isUploading = false;

  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing announcement data
    titleController = TextEditingController(text: widget.announcement['titre']);
    nameController = TextEditingController(text: widget.announcement['nom']);
    ageController =
        TextEditingController(text: widget.announcement['age'].toString());
    descriptionController =
        TextEditingController(text: widget.announcement['description']);
    lastLocationController =
        TextEditingController(text: widget.announcement['dernier_lieu']);
    contactController =
        TextEditingController(text: widget.announcement['contact']);
    selectedDate = widget.announcement['dernier_date'];
    imageUrl = widget.announcement['imageUrl'];
  }

  @override
  void dispose() {
    titleController.dispose();
    nameController.dispose();
    ageController.dispose();
    descriptionController.dispose();
    lastLocationController.dispose();
    contactController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String> uploadImageToImgBB(String imagePath) async {
    String apiKey = dotenv.env['IMGBB_API_KEY'] ?? '';
    var uri = Uri.parse('https://api.imgbb.com/1/upload?key=$apiKey');

    var request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('image', imagePath));

    var response = await request.send();
    if (response.statusCode == 200) {
      final responseString = await response.stream.bytesToString();
      final data = json.decode(responseString);
      return data['data']['url'];
    } else {
      throw Exception('Failed to upload image');
    }
  }

  Future<void> updateAnnouncement() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isUploading = true;
      });

      try {
        // Upload new image if selected
        if (imageFile != null) {
          imageUrl = await uploadImageToImgBB(imageFile!.path);
        }

        // Update the announcement in Firestore
        await FirebaseFirestore.instance
            .collection('announcements')
            .doc(widget.announcement['id'])
            .update({
          'titre': titleController.text,
          'nom': nameController.text,
          'age': int.parse(ageController.text),
          'description': descriptionController.text,
          'dernier_lieu': lastLocationController.text,
          'dernier_date': selectedDate,
          'contact': contactController.text,
          'imageUrl': imageUrl,
          'updatedAt': DateTime.now(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                AppLocalizations.of(context)!.announcementUpdatedSuccessfully ??
                    'Announcement updated successfully'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                AppLocalizations.of(context)!.errorUpdatingAnnouncement ??
                    'Error updating announcement'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          isUploading = false;
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localization!.editAnnouncement ?? 'Edit Announcement'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: titleController,
                decoration:
                    InputDecoration(labelText: localization.title + ' : '),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return localization.titleRequired;
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: nameController,
                decoration:
                    InputDecoration(labelText: localization.name + ' : '),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return localization.nameRequired;
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: ageController,
                decoration:
                    InputDecoration(labelText: localization.age + ' : '),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return localization.ageRequired;
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(
                    labelText: localization.description + ' : '),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return localization.descriptionRequired;
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: lastLocationController,
                decoration: InputDecoration(
                    labelText: localization.lastLocation + ' : '),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return localization.lastLocationRequired;
                  }
                  return null;
                },
              ),
              Row(
                children: [
                  Text(localization.lastDate + ' : '),
                  Text("${selectedDate.toLocal()}".split(' ')[0]),
                  IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ],
              ),
              TextFormField(
                controller: contactController,
                decoration:
                    InputDecoration(labelText: localization.contact + ' : '),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return localization.contactRequired;
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: pickImage,
                child: Text(localization.pickImage),
              ),
              if (imageFile != null)
                Image.file(imageFile!)
              else if (imageUrl != null)
                Image.network(
                  imageUrl!,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      height: 200,
                      child: Icon(Icons.broken_image, size: 50),
                    );
                  },
                ),
              SizedBox(height: 20),
              isUploading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: updateAnnouncement,
                      child: Text(localization.updateAnnouncement ??
                          'Update Announcement'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
