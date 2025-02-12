import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CreateAnnouncementScreen extends StatefulWidget {
  @override
  _CreateAnnouncementScreenState createState() =>
      _CreateAnnouncementScreenState();
}

class _CreateAnnouncementScreenState extends State<CreateAnnouncementScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController titleController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController lastLocationController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  File? imageFile;
  String? imageUrl;

  final ImagePicker picker = ImagePicker();

  bool isUploading = false;

  // Method to pick image from the gallery
  Future<void> pickImage() async {
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50, // Optional, adjust image quality
    );

    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String> uploadImageToImgBB(String imagePath) async {
    String apiKey = dotenv.env['IMGBB_API_KEY'] ??
        ''; // Retrieve API key from .env// this is only for testing purpose
    var uri = Uri.parse('https://api.imgbb.com/1/upload?key=$apiKey');

    var request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('image', imagePath));

    var response = await request.send();
    if (response.statusCode == 200) {
      final responseString = await response.stream.bytesToString();
      final data = json.decode(responseString);
      return data['data']['url'];
    } else {
      return '';
    }
  }

  // Save the announcement to Firestore
  Future<void> saveAnnouncement() async {
    if (_formKey.currentState!.validate()) {
      // set the isUploading to true
      setState(() {
        isUploading = true;
      });

      // 1. Upload image to Firebase Storage
      if (imageFile != null) {
        // use uploadImageToImgBB(imageFile.path) to upload image to imgBB
        imageUrl = await uploadImageToImgBB(imageFile!.path);
      }

      // 2. Save the announcement data to Firestore
      FirebaseFirestore.instance.collection('announcements').add({
        'titre': titleController.text,
        'nom': nameController.text,
        'age': int.parse(ageController.text),
        'description': descriptionController.text,
        'dernier_lieu': lastLocationController.text,
        'dernier_date': selectedDate,
        'contact': contactController.text,
        'imageUrl': imageUrl,
        'is_found': false,
        'is_canceled': false,
        'createdAt': DateTime.now(),
        'updatedAt': DateTime.now(),
        'userId': FirebaseAuth.instance.currentUser!.uid,
      });

      // set the isUploading to false
      setState(() {
        isUploading = false;
      });
      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              AppLocalizations.of(context)!.announcementCreatedSuccessfully),
          backgroundColor: Colors.green));

      // Clear the fields
      titleController.clear();
      nameController.clear();
      ageController.clear();
      descriptionController.clear();
      lastLocationController.clear();
      setState(() {
        imageFile = null;
      });

      // Navigate to the home screen
      Navigator.of(context).pop();
    }
  }

  // Date picker to pick the last date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(localization!.createAnnouncement)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: titleController,
                decoration:
                    InputDecoration(labelText: localization!.title + ' : '),
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
                    InputDecoration(labelText: localization!.name + ' : '),
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
                    InputDecoration(labelText: localization!.age + ' : '),
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
                    labelText: localization!.description + ' : '),
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
                    labelText: localization!.lastLocation + ' : '),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return localization.lastLocationRequired;
                  }
                  return null;
                },
              ),
              Row(
                children: [
                  Text(localization!.lastDate + ' : '),
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
                    InputDecoration(labelText: localization!.contact + ' : '),
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
                child: Text(localization!.pickImage),
              ),
              imageFile != null
                  ? Image.file(imageFile!)
                  : Text(localization!.noImageSelected),
              SizedBox(height: 20),
              isUploading
                  ? Center(
                      child:
                          CircularProgressIndicator()) // Show loading spinner
                  : ElevatedButton(
                      onPressed: saveAnnouncement,
                      child: Text(localization!.createAnnouncement),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
