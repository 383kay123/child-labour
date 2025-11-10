// import 'package:flutter/material.dart';
// import 'package:human_rights_monitor/controller/db/db.dart';
// import 'package:human_rights_monitor/controller/db/table_names.dart';
// import 'package:human_rights_monitor/controller/models/cover_model.dart';

// class DBTestPage extends StatefulWidget {
//   const DBTestPage({Key? key}) : super(key: key);

//   @override
//   State<DBTestPage> createState() => _DBTestPageState();
// }

// class _DBTestPageState extends State<DBTestPage> {
//   final dbHelper = LocalDBHelper.instance;
//   String _status = 'Ready to test';
//   bool _isLoading = false;

//   Future<void> _testSave(String tableName, Map<String, dynamic> data) async {
//     setState(() {
//       _isLoading = true;
//       _status = 'Saving to $tableName...';
//     });

//     try {
//       final db = await dbHelper.database;
//       final id = await db.insert(tableName, data);
      
//       setState(() {
//         _status = '✅ Successfully saved to $tableName\nID: $id';
//       });
//     } catch (e) {
//       setState(() {
//         _status = '❌ Error saving to $tableName\n$e';
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   // Test cover page data with timestamp verification using CoverPageModel
//   Future<void> _testCoverPage() async {
//     setState(() {
//       _isLoading = true;
//       _status = 'Testing Cover Page with Timestamp Verification...';
//     });

//     try {
//       // Clear existing test data first
//       await _clearTestData();
      
//       // Prepare test data using CoverPageModel
//       final testTown = 'TOWN_${DateTime.now().millisecondsSinceEpoch}';
//       final testFarmer = 'FARMER_${DateTime.now().millisecondsSinceEpoch}';
//       final now = DateTime.now().toUtc();
      
//       // Create a test model
//       final testModel = CoverPageModel(
//         selectedTown: testTown,
//         selectedTownName: 'Test Town ${now.second}',
//         selectedFarmer: testFarmer,
//         selectedFarmerName: 'Test Farmer ${now.second}',
//         status: 1,
//         syncStatus: 0,
//         createdAt: now.toIso8601String(),
//         updatedAt: now.toIso8601String(),
//         isSynced: 0,
//       );
      
//       // Insert test data
//       final db = await dbHelper.database;
//       final id = await db.insert(
//         CoverPageModelDB.tableName, 
//         testModel.toMap()..remove('id'), // Remove id for auto-increment
//       );
      
//       // Query the inserted data using CoverPageModel
//       final results = await db.query(
//         CoverPageModelDB.tableName,
//         where: 'id = ?',
//         whereArgs: [id],
//       );

//       if (results.isEmpty) {
//         throw Exception('Failed to retrieve saved data');
//       }
      
//       // Convert result to CoverPageModel
//       final savedModel = CoverPageModel.fromMap(results.first);
      
//       // Verify the data
//       if (savedModel.selectedTown != testTown || 
//           savedModel.selectedFarmer != testFarmer) {
//         throw Exception('Saved data does not match expected values');
//       }
      
//       // Verify the status fields
//       if (savedModel.status != 1) {
//         throw Exception('Expected status to be 1, got ${savedModel.status}');
//       }
      
//       if (savedModel.syncStatus != 0) {
//         throw Exception('Expected syncStatus to be 0, got ${savedModel.syncStatus}');
//       }
      
//       if (savedModel.isSynced != 0) {
//         throw Exception('Expected isSynced to be 0, got ${savedModel.isSynced}');
//       }
      
//       // Verify timestamps
//       final savedCreatedAt = DateTime.parse(savedModel.createdAt!).toUtc();
//       final savedUpdatedAt = DateTime.parse(savedModel.updatedAt!).toUtc();
      
//       if (savedCreatedAt.isAfter(DateTime.now().toUtc())) {
//         throw Exception('created_at is in the future');
//       }
      
//       if (savedUpdatedAt.isAfter(DateTime.now().toUtc())) {
//         throw Exception('updated_at is in the future');
//       }
      
//       setState(() {
//         _status = '✅ Cover Page Test Successful!\n';
//         _status += 'ID: $id\n';
//         _status += 'Town: ${savedModel.selectedTown}\n';
//         _status += 'Farmer: ${savedModel.selectedFarmer}\n';
//         _status += 'Created At: ${savedModel.createdAt}\n';
//         _status += 'Updated At: ${savedModel.updatedAt}\n';
//         _status += 'Status: ${savedModel.status}\n';
//         _status += 'Sync Status: ${savedModel.syncStatus}\n';
//         _status += 'Is Synced: ${savedModel.isSynced == 1 ? 'Yes' : 'No'}';
//       });
//     } catch (e, stackTrace) {
//       setState(() {
//         _status = '❌ Cover Page Test Failed\n$e\n\nStack Trace:\n$stackTrace';
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
  
//   // Clear test data
//   Future<void> _clearTestData() async {
//     try {
//       final db = await dbHelper.database;
//       await db.delete(CoverPageModelDB.tableName);
//       setState(() {
//         _status = '✅ Cleared all test data from ${CoverPageModelDB.tableName} table';
//       });
//     } catch (e) {
//       setState(() {
//         _status = '❌ Error clearing test data: $e';
//       });
//     }
//   }

//   // List all saved cover pages
//   Future<void> _listCoverPages() async {
//     setState(() {
//       _isLoading = true;
//       _status = 'Loading cover pages...';
//     });

//     try {
//       final db = await dbHelper.database;
//       final results = await db.query(
//         TableNames.coverPageTBL,
//         orderBy: 'id DESC',
//       );
      
//       setState(() {
//         if (results.isEmpty) {
//           _status = 'No cover pages found';
//         } else {
//           _status = 'Found ${results.length} cover pages:\n\n';
//           for (var i = 0; i < results.length; i++) {
//             final page = results[i];
//             _status += '${i + 1}. ID: ${page['id']}\n';
//             _status += '   Town: ${page['selected_town_name']}\n';
//             _status += '   Farmer: ${page['selected_farmer_name']}\n\n';
//           }
//         }
//       });
//     } catch (e) {
//       setState(() {
//         _status = 'Error loading cover pages: $e';
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Database Test Page'),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // Status display
//             Card(
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Test Status:',
//                       style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(_status),
//                     if (_isLoading) const LinearProgressIndicator(),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
            
//             // Cover Page Test Section
//             const Text(
//               'Cover Page Tests',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 10),
//             Row(
//               children: [
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: _isLoading ? null : _testCoverPage,
//                     child: const Text('Test Cover Page with Timestamp Verification'),
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 ElevatedButton(
//                   onPressed: _isLoading ? null : _clearTestData,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.red,
//                     foregroundColor: Colors.white,
//                   ),
//                   child: const Text('Clear Test Data'),
//                 ),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: _isLoading ? null : _listCoverPages,
//                     child: const Text('List Cover Pages'),
//                   ),
//                 ),
//               ],
//             ),
//             const Divider(height: 30),
            
//             // Test buttons for each table
//             _buildTestButton(
//               'Test Farmer Identification',
//               TableNames.farmerIdentificationTBL,
//               {
//                 'cover_page_id': 1,
//                 'has_ghana_card': 1,
//                 'ghana_card_number': 'GHA-123456789-0',
//                 'selected_id_type': 'Voter ID',
//                 'id_number': 'VOTER12345',
//                 'id_picture_consent': 1,
//                 'contact_number': '0244123456',
//                 'created_at': DateTime.now().toIso8601String(),
//                 'updated_at': DateTime.now().toIso8601String(),
//                 'is_synced': 0,
//                 'sync_status': 0,
//               },
//             ),
            
//             _buildTestButton(
//               'Test Sensitization',
//               TableNames.sensitizationTBL,
//               {
//                 'cover_page_id': 1,
//                 'has_sensitized_household': 1,
//                 'has_sensitized_on_protection': 1,
//                 'has_sensitized_on_safe_labour': 1,
//                 'female_adults_count': 2,
//                 'male_adults_count': 1,
//                 'consent_for_picture': 1,
//                 'consent_reason': 'Testing',
//                 'parent_reaction': 'Positive',
//                 'status': 0,
//                 'sync_status': 0,
//                 'created_at': DateTime.now().toIso8601String(),
//                 'updated_at': DateTime.now().toIso8601String(),
//               },
//             ),
            
//             _buildTestButton(
//               'Test Children Household',
//               TableNames.childrenHouseholdTBL,
//               {
//                 'cover_page_id': 1,
//                 'total_children': 3,
//                 'children_5_to_17': 2,
//                 'children_in_school': 2,
//                 'children_not_in_school': 1,
//                 'status': 0,
//                 'sync_status': 0,
//                 'created_at': DateTime.now().toIso8601String(),
//                 'updated_at': DateTime.now().toIso8601String(),
//               },
//             ),
            
//             _buildTestButton(
//               'Test End of Collection',
//               TableNames.endOfCollectionTBL,
//               {
//                 'cover_page_id': 1,
//                 'respondent_photo_path': null,
//                 'respondent_signature_path': null,
//                 'interview_end_time': DateTime.now().toIso8601String(),
//                 'status': 0,
//                 'sync_status': 0,
//                 'created_at': DateTime.now().toIso8601String(),
//                 'updated_at': DateTime.now().toIso8601String(),
//               },
//             ),
            
//             _buildTestButton(
//               'Test Remediation',
//               TableNames.remediationTBL,
//               {
//                 'cover_page_id': 1,
//                 'needs_remediation': 1,
//                 'remediation_type': 'School Support',
//                 'remediation_details': 'Needs school fees support',
//                 'follow_up_required': 1,
//                 'follow_up_date': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
//                 'status': 0,
//                 'sync_status': 0,
//                 'created_at': DateTime.now().toIso8601String(),
//                 'updated_at': DateTime.now().toIso8601String(),
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTestButton(String label, String tableName, Map<String, dynamic> testData) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8.0),
//       child: ElevatedButton(
//         onPressed: _isLoading
//             ? null
//             : () => _testSave(tableName, testData),
//         child: Text(label),
//       ),
//     );
//   }
// }
