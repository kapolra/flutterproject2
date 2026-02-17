import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'add_travel_page.dart';

void main() => runApp(const MyApp());

//////////////////////////////////////////////////////////////
// ✅ CONFIG (แก้ตรงนี้ถ้าเปลี่ยนเครื่อง)
//////////////////////////////////////////////////////////////

const String baseUrl =
    "http://127.0.0.1/flutterproject2/php.api/";

//////////////////////////////////////////////////////////////
// ✅ APP ROOT
//////////////////////////////////////////////////////////////

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: travelList(),
      debugShowCheckedModeBanner: false,
    );
  }
}

//////////////////////////////////////////////////////////////
// ✅ travel LIST PAGEF
//////////////////////////////////////////////////////////////

class travelList extends StatefulWidget {
  const travelList({super.key});

  @override
  State<travelList> createState() => _travelListState();
}

class _travelListState extends State<travelList> {
  List travels = [];
  List filteredtravels = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchtravels();
  }

  ////////////////////////////////////////////////////////////
  // ✅ FETCH DATA
  ////////////////////////////////////////////////////////////

  Future<void> fetchtravels() async {
    try {
      final response = await http.get(
        Uri.parse("${baseUrl}show_travel.php"),
      );

      if (response.statusCode == 200) {
        setState(() {
          travels = json.decode(response.body);
          filteredtravels = travels;
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  ////////////////////////////////////////////////////////////
  // ✅ SEARCH
  ////////////////////////////////////////////////////////////

  void filtertravels(String query) {
    setState(() {
      filteredtravels = travels.where((travel) {
        final name = travel['name']?.toLowerCase() ?? '';
        return name.contains(query.toLowerCase());
      }).toList();
    });
  }

  ////////////////////////////////////////////////////////////
  // ✅ UI
  ////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('travel List')),

      body: Column(
        children: [

          //////////////////////////////////////////////////////
          // 🔍 SEARCH BOX
          //////////////////////////////////////////////////////

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: 'Search by travel name',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: filtertravels,
            ),
          ),

          //////////////////////////////////////////////////////
          // 📦 travel LIST
          //////////////////////////////////////////////////////

          Expanded(
            child: filteredtravels.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: filteredtravels.length,
                    itemBuilder: (context, index) {
                      final travel = filteredtravels[index];

                      //////////////////////////////////////////////////////
                      // ✅ IMAGE URL (สำคัญมาก)
                      //////////////////////////////////////////////////////

                     String imageUrl =
                         "${baseUrl}images/${travel['image']}";
    
                      return Card(
                        child: ListTile(

                          //////////////////////////////////////////////////
                          // 🖼 IMAGE FROM SERVER
                          //////////////////////////////////////////////////

                          leading: SizedBox(
                            width: 80,
                            height: 80,
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.image_not_supported),
                            ),
                          ),

                          //////////////////////////////////////////////////
                          // 🏷 NAME
                          //////////////////////////////////////////////////

                          title: Text(travel['name'] ?? 'No Name'),

                          //////////////////////////////////////////////////
                          // 📝 DESCRIPTION
                          //////////////////////////////////////////////////

                          subtitle: Text(
                            travel['description'] ?? 'No Description',
                          ),


                          //////////////////////////////////////////////////
                          // 👉 DETAIL PAGE
                          //////////////////////////////////////////////////

                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    travelDetail(travel: travel),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      ////////////////////////////////////////////////////////
      // ✅ ADD BUTTON
      ///////////////////////////////////////////////////////

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),

        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddTravelPage(),
            ),
          ).then((value) {
            fetchtravels(); // ✅ รีโหลดหลังเพิ่มสินค้า
          });
        },
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
// ✅ travel DETAIL PAGE
//////////////////////////////////////////////////////////////

class travelDetail extends StatelessWidget {
  final dynamic travel;

  const travelDetail({super.key, required this.travel});

  @override
  Widget build(BuildContext context) {

    ////////////////////////////////////////////////////////////
    // ✅ IMAGE URL
    ////////////////////////////////////////////////////////////

    String imageUrl =
        "${baseUrl}images/${travel['image']}";

    return Scaffold(
      appBar: AppBar(
        title: Text(travel['name'] ?? 'Detail'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            //////////////////////////////////////////////////////
            // 🖼 IMAGE
            //////////////////////////////////////////////////////

            Center(
              child: Image.network(
                imageUrl,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.image_not_supported, size: 100),
              ),
            ),

            const SizedBox(height: 20),

            //////////////////////////////////////////////////////
            // 🏷 NAME
            //////////////////////////////////////////////////////

            Text(
              travel['name'] ?? '',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            //////////////////////////////////////////////////////
            // 📝 DESCRIPTION
            //////////////////////////////////////////////////////

            Text(travel['description'] ?? ''),

            const SizedBox(height: 10),

           
          ],
        ),
      ),
    );
  }
}
