import 'package:flutter/material.dart';
import 'package:human_rights_monitor/controller/models/districts/districts_model.dart';

class DistrictDetailsScreen extends StatelessWidget {
  final District district;

  const DistrictDetailsScreen({Key? key, required this.district}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(district.district ?? 'District Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            _buildProfileHeader(context),
            const SizedBox(height: 24),

            // Basic Information
            _buildSection(
              context,
              title: 'Basic Information',
              children: [
                _buildDetailItem(
                  context,
                  label: 'District Name',
                  value: district.district ?? 'N/A',
                  icon: Icons.location_on,
                ),
                _buildDetailItem(
                  context,
                  label: 'District Code',
                  value: district.districtCode ?? 'N/A',
                  icon: Icons.code,
                ),
                _buildDetailItem(
                  context,
                  label: 'Region ID',
                  value: district.regionTblForeignkey?.toString() ?? 'N/A',
                  icon: Icons.map,
                ),
               _buildDetailItem(
  context,
  label: 'Status',
  value: (district.deleteField?.toLowerCase() ?? 'no') == 'no' ? 'Active' : 'Deleted',
  valueColor: (district.deleteField?.toLowerCase() ?? 'no') == 'no' ? Colors.green : Colors.red,
  icon: (district.deleteField?.toLowerCase() ?? 'no') == 'no' 
      ? Icons.check_circle 
      : Icons.cancel,
),
              ],
            ),
            const SizedBox(height: 24),

            // System Information
            _buildSection(
              context,
              title: 'System Information',
              children: [
                _buildDetailItem(
                  context,
                  label: 'District ID',
                  value: district.id?.toString() ?? 'N/A',
                  icon: Icons.fingerprint,
                ),
                _buildDetailItem(
                  context,
                  label: 'Created Date',
                  value: _formatDateTime(district.createdDate),
                  icon: Icons.calendar_today,
                ),
                _buildDetailItem(
                  context,
                  label: 'Delete Field',
                  value: district.deleteField ?? 'N/A',
                  icon: Icons.delete,
                  valueColor: (district.deleteField?.toLowerCase() ?? 'no') == 'no' ? Colors.green : Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // District Avatar
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.location_city,
                size: 40,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    district.district ?? 'N/A',
                    style: Theme.of(context).textTheme.displayLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    district.districtCode ?? 'N/A',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: (district.deleteField?.toLowerCase() ?? 'no') == 'no'
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      (district.deleteField?.toLowerCase() ?? 'no') == 'no' ? 'Active' : 'Deleted',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: (district.deleteField?.toLowerCase() ?? 'no') == 'no'
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required List<Widget> children}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: valueColor ?? Theme.of(context).colorScheme.onBackground,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}