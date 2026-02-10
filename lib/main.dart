import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() => runApp(const MyApp());

// แอปหลัก
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: TravelList()); // กำหนดหน้าแรกเป็น TravelList
  }
}

// สร้าง Widget สำหรับรายการสินค้า
class TravelList extends StatefulWidget {
  const TravelList({super.key});

  @override
  _TravelListState createState() => _TravelListState();
}

class _TravelListState extends State<TravelList> {
  List Travels = []; // เก็บข้อมูลสินค้าทั้งหมด
  List filteredTravels = []; // เก็บข้อมูลสินค้าที่ค้นหา
  TextEditingController searchController = TextEditingController(); // ตัวควบคุมช่องค้นหา

  @override
  void initState() {
    super.initState();
    fetchTravels(); // เรียก API เมื่อโหลดหน้าครั้งแรก
  }

  // ฟังก์ชันดึงข้อมูลสินค้าจาก API
  Future<void> fetchTravels() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost/flutter_travel_image/show_travel/php.api/show_travel.php'),
      );
      if (response.statusCode == 200) {
        setState(() {
          Travels = json.decode(response.body); // แปลง JSON เป็น List
          filteredTravels = Travels; // เริ่มต้นให้แสดงสินค้าทั้งหมด
        });
      } else {
        print('Failed to load Travels: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching Travels: $e');
    }
  }

  // ฟังก์ชันกรองสินค้าจากการค้นหา
  void filterTravels(String query) {
    setState(() {
      filteredTravels = Travels.where((Travel) {
        final name = Travel['name']?.toLowerCase() ?? '';
        return name.contains(query.toLowerCase()); // ค้นหาจากชื่อสินค้า
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Travel List')), // แถบหัวข้อ
      body: Column(
        children: [
          // ช่องค้นหาสินค้า
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: 'Search by Travel name',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: filterTravels, // เรียก filterTravels เมื่อพิมพ์
            ),
          ),
          // แสดงรายการสินค้า
          Expanded(
            child: filteredTravels.isEmpty
                ? const Center(child: CircularProgressIndicator()) // โหลดข้อมูล
                : ListView.builder(
                    itemCount: filteredTravels.length,
                    itemBuilder: (context, index) {
                      final Travel = filteredTravels[index];
                      String imageAsset =
                          'images/${Travel['image'] ?? 'default.png'}';
                      return Card(
                        child: ListTile(
                          leading: SizedBox(
                            width: 80,
                            height: 80,
                            child: Image.asset(
                              imageAsset,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.error); // กรณีโหลดภาพไม่ได้
                              },
                            ),
                          ),
                          title: Text(Travel['name'] ?? 'No Name'), // ชื่อสินค้า
                          subtitle: Text(
                            Travel['description'] ?? 'No Description', // รายละเอียดสินค้า
                          ),
                          trailing: Text('฿${Travel['price'] ?? '0.00'}'), // ราคา
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TravelDetail(Travel: Travel),
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
    );
  }
}

// หน้ารายละเอียดสินค้า
class TravelDetail extends StatelessWidget {
  final dynamic Travel;
  const TravelDetail({super.key, required this.Travel});

  @override
  Widget build(BuildContext context) {
    String imageAsset = 'images/${Travel['image'] ?? 'default.png'}';

    return Scaffold(
      appBar: AppBar(title: Text(Travel['name'] ?? 'Travel Detail')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // แสดงภาพสินค้า
            Center(
              child: Image.asset(
                imageAsset,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.error, size: 100);
                },
              ),
            ),
            const SizedBox(height: 20),
            // ชื่อสินค้า
            Text('Name: ${Travel['name'] ?? 'No Name'}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            // รายละเอียดสินค้า
            Text('Description: ${Travel['description'] ?? 'No Description'}'),
            const SizedBox(height: 10),
            // ราคา
            Text('Price: ฿${Travel['price'] ?? '0.00'}'),
          ],
        ),
      ),
    );
  }
}


