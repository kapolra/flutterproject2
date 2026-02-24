import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class EditTravelPage extends StatefulWidget {
  final dynamic travel;
  const EditTravelPage({super.key, required this.travel});
  @override
  State<EditTravelPage> createState() => _EditTravelPageState();
}

class _EditTravelPageState extends State<EditTravelPage> {
  late TextEditingController nameController;
  late TextEditingController descController;
  XFile? selectedImage;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.travel['name']);
    descController = TextEditingController(text: widget.travel['description']);
  }

  Future<void> updateTravel() async {
    var request = http.MultipartRequest('POST', Uri.parse("http://127.0.0.1/flutterproject2/php_api/update_travel.php"));
    request.fields['id'] = widget.travel['id'].toString();
    request.fields['name'] = nameController.text;
    request.fields['description'] = descController.text;

    if (selectedImage != null) {
      if (kIsWeb) {
        request.files.add(http.MultipartFile.fromBytes('image', await selectedImage!.readAsBytes(), filename: selectedImage!.name));
      } else {
        request.files.add(await http.MultipartFile.fromPath('image', selectedImage!.path));
      }
    }

    var res = await request.send();
    if (res.statusCode == 200) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("แก้ไข")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: () async {
                final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
                if (picked != null) setState(() => selectedImage = picked);
              },
              child: Container(
                height: 150, width: double.infinity, color: Colors.grey[200],
                child: selectedImage != null 
                  ? Image.network(selectedImage!.path) 
                  : Image.network("http://127.0.0.1/flutterproject2/php_api/images/${widget.travel['image']}"),
              ),
            ),
            TextField(controller: nameController),
            TextField(controller: descController),
            ElevatedButton(onPressed: updateTravel, child: const Text("บันทึกการแก้ไข"))
          ],
        ),
      ),
    );
  }
}