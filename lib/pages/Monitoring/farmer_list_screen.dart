import 'package:flutter/material.dart';
import 'farmer_detail_screen.dart';

class FarmerListScreen extends StatelessWidget {
  const FarmerListScreen({Key? key}) : super(key: key);

  // Mock data - replace with your actual data source
  final List<Map<String, dynamic>> farmers = const [
    {
      'id': '1',
      'name': 'John Doe',
      'location': 'Nakuru',
      'childrenAtRisk': 2,
      'totalChildren': 4,
      'coordinates': {'lat': -0.3031, 'lng': 36.0800},
    },
    {
      'id': '2',
      'name': 'Jane Smith',
      'location': 'Eldoret',
      'childrenAtRisk': 1,
      'totalChildren': 3,
      'coordinates': {'lat': 0.5143, 'lng': 35.2698},
    },
    // Add more farmers as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farmers List'),
      ),
      body: ListView.builder(
        itemCount: farmers.length,
        itemBuilder: (context, index) {
          final farmer = farmers[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(
                farmer['name'],
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text('Location: ${farmer['location']}'),
                  const SizedBox(height: 4),
                  Text(
                    'Children: ${farmer['childrenAtRisk']} at risk • ${farmer['totalChildren']} total',
                    style: TextStyle(
                      color: farmer['childrenAtRisk'] > 0
                          ? Colors.orange
                          : Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        FarmerDetailScreen(farmerData: farmer),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
