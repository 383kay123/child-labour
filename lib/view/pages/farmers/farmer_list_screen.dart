// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// import '../../theme/app_theme.dart';
// import 'farmer_detail_screen.dart';

// class FarmerListScreen extends StatefulWidget {
//   final String? communityId;
//   final String? communityName;

//   const FarmerListScreen({
//     super.key,
//     this.communityId,
//     this.communityName,
//   });

//   @override
//   State<FarmerListScreen> createState() => _FarmerListScreenState();
// }

// class _FarmerListScreenState extends State<FarmerListScreen> {
//   String _searchQuery = "";

//   List<Map<String, dynamic>> get _allFarmers {
//     const allFarmers = [
//       {
//         'id': '1',
//         'name': 'John Doe',
//         'location': 'Dadieso',
//         'communityId': '1',
//         'childrenAtRisk': 2,
//         'totalChildren': 4,
//         'coordinates': {'lat': -0.3031, 'lng': 36.0800},
//       },
//       {
//         'id': '2',
//         'name': 'Jane Smith',
//         'location': 'Dunkwa',
//         'communityId': '1',
//         'childrenAtRisk': 1,
//         'totalChildren': 3,
//         'coordinates': {'lat': 0.5143, 'lng': 35.2698},
//       },
//       {
//         'id': '3',
//         'name': 'Michael Johnson',
//         'location': 'Elluokrom',
//         'communityId': '2',
//         'childrenAtRisk': 1,
//         'totalChildren': 2,
//         'coordinates': {'lat': -0.1022, 'lng': 34.7617},
//       },
//     ];

//     if (widget.communityId == null) return allFarmers;
//     return allFarmers
//         .where((farmer) => farmer['communityId'] == widget.communityId)
//         .toList();
//   }

//   List<Map<String, dynamic>> get _filteredFarmers {
//     if (_searchQuery.isEmpty) return _allFarmers;
//     return _allFarmers.where((farmer) {
//       final name = farmer['name'].toString().toLowerCase();
//       final location = farmer['location'].toString().toLowerCase();
//       final query = _searchQuery.toLowerCase();
//       return name.contains(query) || location.contains(query);
//     }).toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Farmers',
//           style: GoogleFonts.poppins(color: Colors.white),
//         ),
//         backgroundColor: AppTheme.primaryColor,
//       ),
//       backgroundColor: Colors.grey[50],
//       body: Column(
//         children: [
//           // 🔍 Search Bar
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
//             child: TextField(
//               decoration: InputDecoration(
//                 hintText: "Search farmers by name or location...",
//                 prefixIcon: const Icon(Icons.search, color: Colors.grey),
//                 filled: true,
//                 fillColor: Colors.white,
//                 contentPadding:
//                 const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide.none,
//                 ),
//               ),
//               onChanged: (value) {
//                 setState(() => _searchQuery = value);
//               },
//             ),
//           ),

//           // 📋 Farmers List
//           Expanded(
//             child: _filteredFarmers.isEmpty
//                 ? Center(
//               child: Text(
//                 "No farmers found",
//                 style: GoogleFonts.poppins(
//                   fontSize: 14,
//                   color: Colors.grey[600],
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             )
//                 : ListView.separated(
//               padding: const EdgeInsets.symmetric(vertical: 8),
//               itemCount: _filteredFarmers.length,
//               separatorBuilder: (_, __) => const SizedBox(height: 8),
//               itemBuilder: (context, index) {
//                 final farmer = _filteredFarmers[index];
//                 final hasRisk = farmer['childrenAtRisk'] > 0;

//                 return Container(
//                   margin: const EdgeInsets.symmetric(
//                       horizontal: 12, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(12),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.05),
//                         blurRadius: 6,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: Material(
//                     color: Colors.transparent,
//                     child: InkWell(
//                       borderRadius: BorderRadius.circular(12),
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (_) =>
//                                 FarmerDetailScreen(farmerData: farmer),
//                           ),
//                         );
//                       },
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 20, vertical: 16),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             // Farmer Name + Status
//                             Row(
//                               mainAxisAlignment:
//                               MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text(
//                                   farmer['name'],
//                                   style: GoogleFonts.poppins(
//                                     fontSize: 15,
//                                     fontWeight: FontWeight.w600,
//                                     color: Colors.grey[900],
//                                   ),
//                                 ),
//                                 Container(
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 10, vertical: 4),
//                                   decoration: BoxDecoration(
//                                     color: hasRisk
//                                         ? Colors.orange[50]
//                                         : Colors.green[50],
//                                     borderRadius:
//                                     BorderRadius.circular(12),
//                                   ),
//                                   child: Text(
//                                     hasRisk
//                                         ? 'Needs Attention'
//                                         : 'All Safe',
//                                     style: GoogleFonts.poppins(
//                                       fontSize: 11,
//                                       fontWeight: FontWeight.w500,
//                                       color: hasRisk
//                                           ? Colors.orange[800]
//                                           : Colors.green[800],
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 10),

//                             // Location + Stats
//                             Row(
//                               children: [
//                                 Icon(
//                                   Icons.location_on_outlined,
//                                   size: 16,
//                                   color: Colors.grey[600],
//                                 ),
//                                 const SizedBox(width: 6),
//                                 Text(
//                                   farmer['location'],
//                                   style: GoogleFonts.poppins(
//                                     fontSize: 12,
//                                     color: Colors.grey[700],
//                                   ),
//                                 ),
//                                 const Spacer(),
//                                 _buildStatChip(
//                                   '${farmer['childrenAtRisk']} at risk',
//                                   hasRisk ? Colors.orange : Colors.grey,
//                                 ),
//                                 const SizedBox(width: 8),
//                                 _buildStatChip(
//                                   '${farmer['totalChildren']} total',
//                                   theme.primaryColor,
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatChip(String label, Color color) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: color.withOpacity(0.3), width: 0.5),
//       ),
//       child: Text(
//         label,
//         style: GoogleFonts.poppins(
//           fontSize: 10,
//           fontWeight: FontWeight.w500,
//           color: color,
//           letterSpacing: 0.2,
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:human_rights_monitor/controller/db/db_tables/repositories/farmers_repo.dart';
import 'package:human_rights_monitor/controller/models/farmers/farmers_model.dart';
import 'package:human_rights_monitor/view/pages/farmers/farmer_detail_screen.dart';

class FarmersListScreen extends StatefulWidget {
  const FarmersListScreen({Key? key}) : super(key: key);

  @override
  State<FarmersListScreen> createState() => _FarmersListScreenState();
}

class _FarmersListScreenState extends State<FarmersListScreen> {
  FarmerRepository repo= FarmerRepository();
  late Future<List<Farmer>> _farmersFuture;
  List<Farmer> _allFarmers = [];
  List<Farmer> _filteredFarmers = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _farmersFuture = _fetchFarmers();
    _searchController.addListener(_onSearchChanged);
  }

  Future<List<Farmer>> _fetchFarmers() async {
    try {
      final farmers = await repo.getAllFarmers();
      _allFarmers = farmers;
      _filteredFarmers = farmers;
      return farmers;
    } catch (e) {
      throw Exception('Failed to load farmers: $e');
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();
    
    if (query.isEmpty) {
      setState(() {
        _filteredFarmers = _allFarmers;
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _filteredFarmers = _allFarmers.where((farmer) {
        return _searchInFarmer(farmer, query);
      }).toList();
    });
  }

 bool _searchInFarmer(Farmer farmer, String query) {
  final searchQuery = query.toLowerCase();
  return (farmer.firstName?.toLowerCase() ?? '').contains(searchQuery) ||
      (farmer.lastName?.toLowerCase() ?? '').contains(searchQuery) ||
      (farmer.farmerCode?.toLowerCase() ?? '').contains(searchQuery) ||
      (farmer.nationalIdNo?.toLowerCase() ?? '').contains(searchQuery) ||
      (farmer.contact?.toLowerCase() ?? '').contains(searchQuery) ||
      (farmer.idType?.toLowerCase() ?? '').contains(searchQuery) ||
      (farmer.mappedStatus?.toLowerCase() ?? '').contains(searchQuery) ||
      (farmer.newFarmerCode?.toLowerCase() ?? '').contains(searchQuery) ||
      (farmer.societyName?.toString() ?? '').toLowerCase().contains(searchQuery) ||
      (farmer.noOfCocoaFarms?.toString() ?? '').contains(query) ||
      (farmer.totalCocoaBagsHarvestedPreviousYear?.toString() ?? '').contains(query);
}
  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _filteredFarmers = _allFarmers;
      _isSearching = false;
    });
  }

  void _refreshData() {
    setState(() {
      _farmersFuture = _fetchFarmers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Farmers List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search farmers...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearSearch,
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // Results Count
          if (_isSearching)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Text(
                    '${_filteredFarmers.length} farmers found',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
            ),

          // Farmers List
          Expanded(
            child: FutureBuilder<List<Farmer>>(
              future: _farmersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to load farmers',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          snapshot.error.toString(),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _refreshData,
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  );
                }

                if (_filteredFarmers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _isSearching ? 'No farmers found' : 'No farmers available',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (!_isSearching) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Check your connection and try again',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: _filteredFarmers.length,
                  itemBuilder: (context, index) {
                    final farmer = _filteredFarmers[index];
                    return _FarmerCard(farmer: farmer);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FarmerCard extends StatelessWidget {
  final Farmer farmer;

  const _FarmerCard({required this.farmer});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FarmerDetailsScreen(farmer: farmer),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar/Icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              // Farmer Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${farmer.firstName} ${farmer.lastName}',
                      style: Theme.of(context).textTheme.titleLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Code: ${farmer.farmerCode}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${farmer.nationalIdNo}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.phone,
                          size: 12,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          farmer.contact??'N/A',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Status Indicator
             // Status Indicator
Container(
  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  decoration: BoxDecoration(
    color: (farmer.mappedStatus?.toLowerCase() ?? 'no') == 'yes'
        ? Colors.green.withOpacity(0.1)
        : Colors.orange.withOpacity(0.1),
    borderRadius: BorderRadius.circular(8),
    border: Border.all(
      color: (farmer.mappedStatus?.toLowerCase() ?? 'no') == 'yes'
          ? Colors.green
          : Colors.orange,
      width: 1,
    ),
  ),
  child: Text(
    farmer.mappedStatus ?? 'N/A',
    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: (farmer.mappedStatus?.toLowerCase() ?? 'no') == 'yes'
              ? Colors.green
              : Colors.orange,
          fontWeight: FontWeight.w500,
        ),
  ),
)
            ],
          ),
        ),
      ),
    );
  }
}