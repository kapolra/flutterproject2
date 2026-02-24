import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class AddTravelPage extends StatefulWidget {
  const AddTravelPage({super.key});
  @override
  State<AddTravelPage> createState() => _AddTravelPageState();
}

class _AddTravelPageState extends State<AddTravelPage> {
  final nameController = TextEditingController();
  final descController = TextEditingController();
  XFile? selectedImage;

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => selectedImage = picked);
  }

  Future<void> saveTravel() async {
    if (selectedImage == null) return;
    var request = http.MultipartRequest('POST', Uri.parse("http://127.0.0.1/flutterproject2/php_api/insert_travel.php"));
    request.fields['name'] = nameController.text;
    request.fields['description'] = descController.text;

    if (kIsWeb) {
      request.files.add(http.MultipartFile.fromBytes('image', await selectedImage!.readAsBytes(), filename: selectedImage!.name));
    } else {
      request.files.add(await http.MultipartFile.fromPath('image', selectedImage!.path));
    }

    var res = await request.send();
    if (res.statusCode == 200) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("เพิ่มสถานที่")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: pickImage,
              child: Container(
                height: 150, width: double.infinity, color: Colors.grey[200],
                child: selectedImage == null ? const Icon(Icons.add_a_photo) : Image.network(selectedImage!.path),
              ),
            ),
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "ชื่อ")),
            TextField(controller: descController, decoration: const InputDecoration(labelText: "รายละเอียด")),
            ElevatedButton(onPressed: saveTravel, child: const Text("บันทึก"))
          ],
        ),
      ),
    );
  }
}