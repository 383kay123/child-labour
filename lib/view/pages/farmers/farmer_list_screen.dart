import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_theme.dart';
import 'farmer_detail_screen.dart';

class FarmerListScreen extends StatefulWidget {
  final String? communityId;
  final String? communityName;

  const FarmerListScreen({
    super.key,
    this.communityId,
    this.communityName,
  });

  @override
  State<FarmerListScreen> createState() => _FarmerListScreenState();
}

class _FarmerListScreenState extends State<FarmerListScreen> {
  String _searchQuery = "";

  List<Map<String, dynamic>> get _allFarmers {
    const allFarmers = [
      {
        'id': '1',
        'name': 'John Doe',
        'location': 'Dadieso',
        'communityId': '1',
        'childrenAtRisk': 2,
        'totalChildren': 4,
        'coordinates': {'lat': -0.3031, 'lng': 36.0800},
      },
      {
        'id': '2',
        'name': 'Jane Smith',
        'location': 'Dunkwa',
        'communityId': '1',
        'childrenAtRisk': 1,
        'totalChildren': 3,
        'coordinates': {'lat': 0.5143, 'lng': 35.2698},
      },
      {
        'id': '3',
        'name': 'Michael Johnson',
        'location': 'Elluokrom',
        'communityId': '2',
        'childrenAtRisk': 1,
        'totalChildren': 2,
        'coordinates': {'lat': -0.1022, 'lng': 34.7617},
      },
    ];

    if (widget.communityId == null) return allFarmers;
    return allFarmers
        .where((farmer) => farmer['communityId'] == widget.communityId)
        .toList();
  }

  List<Map<String, dynamic>> get _filteredFarmers {
    if (_searchQuery.isEmpty) return _allFarmers;
    return _allFarmers.where((farmer) {
      final name = farmer['name'].toString().toLowerCase();
      final location = farmer['location'].toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || location.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Farmers',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        backgroundColor: AppTheme.primaryColor,
      ),
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // 🔍 Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search farmers by name or location...",
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),

          // 📋 Farmers List
          Expanded(
            child: _filteredFarmers.isEmpty
                ? Center(
              child: Text(
                "No farmers found",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
                : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _filteredFarmers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final farmer = _filteredFarmers[index];
                final hasRisk = farmer['childrenAtRisk'] > 0;

                return Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                FarmerDetailScreen(farmerData: farmer),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Farmer Name + Status
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  farmer['name'],
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[900],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: hasRisk
                                        ? Colors.orange[50]
                                        : Colors.green[50],
                                    borderRadius:
                                    BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    hasRisk
                                        ? 'Needs Attention'
                                        : 'All Safe',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: hasRisk
                                          ? Colors.orange[800]
                                          : Colors.green[800],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // Location + Stats
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  farmer['location'],
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const Spacer(),
                                _buildStatChip(
                                  '${farmer['childrenAtRisk']} at risk',
                                  hasRisk ? Colors.orange : Colors.grey,
                                ),
                                const SizedBox(width: 8),
                                _buildStatChip(
                                  '${farmer['totalChildren']} total',
                                  theme.primaryColor,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: color,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
