import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FarmerDetailScreen extends StatelessWidget {
  final Map<String, dynamic> farmerData;

  const FarmerDetailScreen({
    Key? key,
    required this.farmerData,
  }) : super(key: key);

  // Mock children data - replace with your actual data source
  List<Map<String, dynamic>> get children => [
        {
          'name': 'Alice',
          'age': 12,
          'isAtRisk': true,
          'riskFactors': ['Working on farm', 'Not attending school'],
        },
        {
          'name': 'Bob',
          'age': 14,
          'isAtRisk': true,
          'riskFactors': ['Working long hours'],
        },
        {
          'name': 'Charlie',
          'age': 16,
          'isAtRisk': false,
          'riskFactors': [],
        },
      ];

  @override
  Widget build(BuildContext context) {
    final coordinates = farmerData['coordinates'];
    final lat = coordinates['lat'];
    final lng = coordinates['lng'];
    final mapUrl = 'https://www.google.com/maps?q=$lat,$lng';

    return Scaffold(
      appBar: AppBar(
        title: Text('${farmerData['name']}\'s Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Farmer Information',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Divider(),
                    _buildInfoRow('Name', farmerData['name']),
                    _buildInfoRow('Location', farmerData['location']),
                    _buildInfoRow(
                      'Coordinates',
                      '${coordinates['lat']}, ${coordinates['lng']}',
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final Uri uri = Uri.parse(mapUrl);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri);
                          }
                        },
                        icon: const Icon(Icons.map),
                        label: const Text('View on Map'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Children (${children.length} total, ${children.where((c) => c['isAtRisk']).length} at risk)',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            ...children.map((child) => _buildChildCard(context, child)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const Text(': '),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildChildCard(BuildContext context, Map<String, dynamic> child) {
    final isAtRisk = child['isAtRisk'] as bool;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isAtRisk ? Colors.red[50] : Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  child['name'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Text('${child['age']} years'),
                const Spacer(),
                Chip(
                  label: Text(
                    isAtRisk ? 'At Risk' : 'Safe',
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: isAtRisk ? Colors.red : Colors.green,
                ),
              ],
            ),
            if (isAtRisk && (child['riskFactors'] as List).isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                'Risk Factors:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...(child['riskFactors'] as List<String>).map((factor) => Padding(
                    padding: const EdgeInsets.only(left: 8.0, top: 4),
                    child: Text('• $factor'),
                  )),
            ],
          ],
        ),
      ),
    );
  }
}
