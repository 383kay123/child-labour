import 'package:flutter/material.dart';
import 'package:human_rights_monitor/controller/db/db_tables/repositories/districts_repo.dart';
import 'package:human_rights_monitor/controller/models/districts/districts_model.dart';
import 'package:human_rights_monitor/view/pages/communities/comuunity_details.dart';


class DistrictsListScreen extends StatefulWidget {
  const DistrictsListScreen({Key? key}) : super(key: key);

  @override
  State<DistrictsListScreen> createState() => _DistrictsListScreenState();
}

class _DistrictsListScreenState extends State<DistrictsListScreen> {
  DistrictRepository repo = DistrictRepository();
  late Future<List<District>> _districtsFuture;
  List<District> _allDistricts = [];
  List<District> _filteredDistricts = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _districtsFuture = _fetchDistricts();
    _searchController.addListener(_onSearchChanged);
  }

  Future<List<District>> _fetchDistricts() async {
    try {
      final districts = await repo.getAllDistricts();
      _allDistricts = districts;
      _filteredDistricts = districts;
      return districts;
    } catch (e) {
      throw Exception('Failed to load districts: $e');
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();
    
    if (query.isEmpty) {
      setState(() {
        _filteredDistricts = _allDistricts;
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _filteredDistricts = _allDistricts.where((district) {
        return _searchInDistrict(district, query);
      }).toList();
    });
  }

  bool _searchInDistrict(District district, String query) {
    final searchQuery = query.toLowerCase();
    return (district.district?.toLowerCase() ?? '').contains(searchQuery) ||
        (district.districtCode?.toLowerCase() ?? '').contains(searchQuery) ||
        (district.deleteField?.toLowerCase() ?? '').contains(searchQuery) ||
        (district.regionTblForeignkey?.toString() ?? '').contains(query) ||
        (district.id?.toString() ?? '').contains(query);
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _filteredDistricts = _allDistricts;
      _isSearching = false;
    });
  }

  void _refreshData() {
    setState(() {
      _districtsFuture = _fetchDistricts();
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
        title: const Text('Districts Directory'),
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
                hintText: 'Search districts by name, code, or region...',
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
                    '${_filteredDistricts.length} districts found',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
            ),

          // Districts List
          Expanded(
            child: FutureBuilder<List<District>>(
              future: _districtsFuture,
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
                          'Failed to load districts',
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

                if (_filteredDistricts.isEmpty) {
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
                          _isSearching ? 'No districts found' : 'No districts available',
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
                  itemCount: _filteredDistricts.length,
                  itemBuilder: (context, index) {
                    final district = _filteredDistricts[index];
                    return _DistrictCard(district: district);
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

class _DistrictCard extends StatelessWidget {
  final District district;

  const _DistrictCard({required this.district});

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
              builder: (context) => DistrictDetailsScreen(district: district),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Location Icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.location_on,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              // District Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      district.district ?? 'N/A',
                      style: Theme.of(context).textTheme.titleLarge,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Code: ${district.districtCode}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Region ID: ${district.regionTblForeignkey}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 12,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Created: ${_formatDate(district.createdDate)}',
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (district.deleteField?.toLowerCase() ?? 'no') == 'no'
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: (district.deleteField?.toLowerCase() ?? 'no') == 'no'
                        ? Colors.green
                        : Colors.red,
                    width: 1,
                  ),
                ),
                child: Text(
                  (district.deleteField?.toLowerCase() ?? 'no') == 'no' ? 'Active' : 'Deleted',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: (district.deleteField?.toLowerCase() ?? 'no') == 'no'
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }
}