import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'add_travel_page.dart';
import 'edit_travel_page.dart';

void main() => runApp(const MyApp());

const String baseUrl = "http://127.0.0.1/flutterproject2/php_api/";

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const TravelList(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, primarySwatch: Colors.blue),
    );
  }
}

class TravelList extends StatefulWidget {
  const TravelList({super.key});
  @override
  State<TravelList> createState() => _TravelListState();
}

class _TravelListState extends State<TravelList> {
  List travels = [];
  List filteredTravels = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTravels();
  }

  Future<void> fetchTravels() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse("${baseUrl}show_travel.php"));
      if (response.statusCode == 200) {
        setState(() {
          travels = json.decode(response.body);
          filteredTravels = travels;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("Fetch Error: $e");
    }
  }

  void filterTravels(String query) {
    setState(() {
      filteredTravels = travels.where((travel) {
        final name = travel['name']?.toLowerCase() ?? '';
        return name.contains(query.toLowerCase());
      }).toList();
    });
  }

  Future<void> deleteTravel(int id) async {
    final response = await http.get(Uri.parse("${baseUrl}delete.php?id=$id"));
    final data = json.decode(response.body);
    if (data["success"] == true) {
      fetchTravels();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("ลบสำเร็จ")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Travel List')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(labelText: 'ค้นหา...', prefixIcon: Icon(Icons.search)),
              onChanged: filterTravels,
            ),
          ),
          Expanded(
            child: isLoading 
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: filteredTravels.length,
                  itemBuilder: (context, index) {
                    final travel = filteredTravels[index];
                    return Card(
                      child: ListTile(
                        leading: Image.network("${baseUrl}images/${travel['image']}", width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (_,__,___)=>const Icon(Icons.image)),
                        title: Text(travel['name'] ?? ''),
                        subtitle: Text(travel['description'] ?? '', maxLines: 1),
                        trailing: PopupMenuButton(
                          onSelected: (val) {
                            if(val == 'edit') {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => EditTravelPage(travel: travel))).then((_) => fetchTravels());
                            } else {
                              deleteTravel(int.parse(travel['id'].toString()));
                            }
                          },
                          itemBuilder: (_) => [
                            const PopupMenuItem(value: 'edit', child: Text('แก้ไข')),
                            const PopupMenuItem(value: 'delete', child: Text('ลบ')),
                          ],
                        ),
                      ),
                    );
                  },
                ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddTravelPage())).then((_) => fetchTravels()),
        child: const Icon(Icons.add),
      ),
    );
  }
}