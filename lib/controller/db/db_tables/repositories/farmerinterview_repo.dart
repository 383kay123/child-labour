import 'dart:async';
import 'package:human_rights_monitor/controller/db/db.dart';
import 'package:human_rights_monitor/controller/models/household_online/household_online_model.dart';
import 'package:sqflite/sqflite.dart';

class FarmerInterviewRepository {
  final LocalDBHelper _dbHelper = LocalDBHelper.instance;
  
  // Table name constant
  static const String tableName = 'farmer_interviews';
  
  // ========== CREATE OPERATIONS ==========
  
  /// Create a new farmer interview
  Future<int> createInterview(FarmerInterview interview) async {
    try {
      final db = await _dbHelper.database;
      final id = await db.insert(
        tableName,
        interview.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return id;
    } catch (e) {
      print('❌ Error creating farmer interview: $e');
      throw Exception('Failed to create interview: $e');
    }
  }
  
  /// Create multiple farmer interviews
  Future<List<int>> createMultipleInterviews(List<FarmerInterview> interviews) async {
    final List<int> ids = [];
    try {
      final db = await _dbHelper.database;
      
      await db.transaction((txn) async {
        for (final interview in interviews) {
          final id = await txn.insert(
            tableName,
            interview.toJson(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          ids.add(id);
        }
      });
      
      return ids;
    } catch (e) {
      print('❌ Error creating multiple interviews: $e');
      throw Exception('Failed to create multiple interviews: $e');
    }
  }
  
  // ========== READ OPERATIONS ==========
  
  /// Get interview by ID
  Future<FarmerInterview?> getInterviewById(int id) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
      
      if (maps.isNotEmpty) {
        return FarmerInterview.fromJson(maps.first);
      }
      return null;
    } catch (e) {
      print('❌ Error getting interview by ID: $e');
      throw Exception('Failed to get interview: $e');
    }
  }
  
  /// Get all interviews
  Future<List<FarmerInterview>> getAllInterviews({
    int? limit,
    int? offset,
    String? orderBy = 'created_at DESC',
  }) async {
    try {
      final db = await _dbHelper.database;
      
      String query = 'SELECT * FROM $tableName';
      List<String> whereClauses = [];
      List<Object?> whereArgs = [];
      
      if (whereClauses.isNotEmpty) {
        query += ' WHERE ${whereClauses.join(' AND ')}';
      }
      
      if (orderBy != null) {
        query += ' ORDER BY $orderBy';
      }
      
      if (limit != null) {
        query += ' LIMIT $limit';
        if (offset != null) {
          query += ' OFFSET $offset';
        }
      }
      
      final maps = await db.rawQuery(query, whereArgs);
      
      return maps.map((map) => FarmerInterview.fromJson(map)).toList();
    } catch (e) {
      print('❌ Error getting all interviews: $e');
      throw Exception('Failed to get interviews: $e');
    }
  }
  
  /// Get interviews by enumerator ID
  Future<List<FarmerInterview>> getInterviewsByEnumerator(int enumeratorId) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        tableName,
        where: 'enumerator = ?',
        whereArgs: [enumeratorId],
        orderBy: 'created_at DESC',
      );
      
      return maps.map((map) => FarmerInterview.fromJson(map)).toList();
    } catch (e) {
      print('❌ Error getting interviews by enumerator: $e');
      throw Exception('Failed to get enumerator interviews: $e');
    }
  }
  
  /// Get interviews by farmer ID
  Future<List<FarmerInterview>> getInterviewsByFarmer(int farmerId) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        tableName,
        where: 'farmer = ?',
        whereArgs: [farmerId],
        orderBy: 'created_at DESC',
      );
      
      return maps.map((map) => FarmerInterview.fromJson(map)).toList();
    } catch (e) {
      print('❌ Error getting interviews by farmer: $e');
      throw Exception('Failed to get farmer interviews: $e');
    }
  }
  
  /// Get interviews by community type
  Future<List<FarmerInterview>> getInterviewsByCommunityType(String communityType) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        tableName,
        where: 'community_type = ?',
        whereArgs: [communityType],
        orderBy: 'created_at DESC',
      );
      
      return maps.map((map) => FarmerInterview.fromJson(map)).toList();
    } catch (e) {
      print('❌ Error getting interviews by community type: $e');
      throw Exception('Failed to get community type interviews: $e');
    }
  }
  
  /// Get interviews by date range
  Future<List<FarmerInterview>> getInterviewsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        tableName,
        where: 'created_at BETWEEN ? AND ?',
        whereArgs: [
          startDate.toIso8601String(),
          endDate.toIso8601String(),
        ],
        orderBy: 'created_at DESC',
      );
      
      return maps.map((map) => FarmerInterview.fromJson(map)).toList();
    } catch (e) {
      print('❌ Error getting interviews by date range: $e');
      throw Exception('Failed to get date range interviews: $e');
    }
  }
  
  /// Search interviews by owner name
  Future<List<FarmerInterview>> searchInterviewsByName(String query) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        tableName,
        where: 'name_owner LIKE ? OR first_name_owner LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
        orderBy: 'created_at DESC',
      );
      
      return maps.map((map) => FarmerInterview.fromJson(map)).toList();
    } catch (e) {
      print('❌ Error searching interviews by name: $e');
      throw Exception('Failed to search interviews: $e');
    }
  }
  
  /// Advanced search with multiple criteria
  Future<List<FarmerInterview>> searchInterviews({
    String? nameQuery,
    String? communityType,
    int? enumeratorId,
    int? farmerId,
    String? nationality,
    String? childrenPresent,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final db = await _dbHelper.database;
      
      List<String> whereClauses = [];
      List<Object?> whereArgs = [];
      
      if (nameQuery != null && nameQuery.isNotEmpty) {
        whereClauses.add('(name_owner LIKE ? OR first_name_owner LIKE ?)');
        whereArgs.addAll(['%$nameQuery%', '%$nameQuery%']);
      }
      
      if (communityType != null && communityType.isNotEmpty) {
        whereClauses.add('community_type = ?');
        whereArgs.add(communityType);
      }
      
      if (enumeratorId != null) {
        whereClauses.add('enumerator = ?');
        whereArgs.add(enumeratorId);
      }
      
      if (farmerId != null) {
        whereClauses.add('farmer = ?');
        whereArgs.add(farmerId);
      }
      
      if (nationality != null && nationality.isNotEmpty) {
        whereClauses.add('nationality = ?');
        whereArgs.add(nationality);
      }
      
      if (childrenPresent != null && childrenPresent.isNotEmpty) {
        whereClauses.add('children_present = ?');
        whereArgs.add(childrenPresent);
      }
      
      if (startDate != null && endDate != null) {
        whereClauses.add('created_at BETWEEN ? AND ?');
        whereArgs.addAll([
          startDate.toIso8601String(),
          endDate.toIso8601String(),
        ]);
      } else if (startDate != null) {
        whereClauses.add('created_at >= ?');
        whereArgs.add(startDate.toIso8601String());
      } else if (endDate != null) {
        whereClauses.add('created_at <= ?');
        whereArgs.add(endDate.toIso8601String());
      }
      
      String where = '';
      if (whereClauses.isNotEmpty) {
        where = 'WHERE ${whereClauses.join(' AND ')}';
      }
      
      final query = 'SELECT * FROM $tableName $where ORDER BY created_at DESC';
      final maps = await db.rawQuery(query, whereArgs);
      
      return maps.map((map) => FarmerInterview.fromJson(map)).toList();
    } catch (e) {
      print('❌ Error in advanced search: $e');
      throw Exception('Failed to search interviews: $e');
    }
  }
  
  // ========== UPDATE OPERATIONS ==========
  
  /// Update an existing interview
  Future<int> updateInterview(FarmerInterview interview, int id) async {
    try {
      final db = await _dbHelper.database;
      final data = interview.toJson();
      data['updated_at'] = DateTime.now().toIso8601String();
      
      final rowsAffected = await db.update(
        tableName,
        data,
        where: 'id = ?',
        whereArgs: [id],
      );
      
      return rowsAffected;
    } catch (e) {
      print('❌ Error updating interview: $e');
      throw Exception('Failed to update interview: $e');
    }
  }
  
  /// Partial update of specific fields
  Future<int> partialUpdate(int id, Map<String, dynamic> updates) async {
    try {
      final db = await _dbHelper.database;
      updates['updated_at'] = DateTime.now().toIso8601String();
      
      final rowsAffected = await db.update(
        tableName,
        updates,
        where: 'id = ?',
        whereArgs: [id],
      );
      
      return rowsAffected;
    } catch (e) {
      print('❌ Error in partial update: $e');
      throw Exception('Failed to partially update interview: $e');
    }
  }
  
  /// Mark interview as synced
  Future<int> markAsSynced(int id, {bool synced = true}) async {
    try {
      return await partialUpdate(id, {
        'is_synced': synced ? 1 : 0,
        'sync_status': synced ? 1 : 0,
        'synced_at': synced ? DateTime.now().toIso8601String() : null,
      });
    } catch (e) {
      print('❌ Error marking interview as synced: $e');
      throw Exception('Failed to mark interview as synced: $e');
    }
  }
  
  // ========== DELETE OPERATIONS ==========
  
  /// Delete interview by ID
  Future<int> deleteInterview(int id) async {
    try {
      final db = await _dbHelper.database;
      final rowsAffected = await db.delete(
        tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
      
      return rowsAffected;
    } catch (e) {
      print('❌ Error deleting interview: $e');
      throw Exception('Failed to delete interview: $e');
    }
  }
  
  /// Delete multiple interviews
  Future<int> deleteMultipleInterviews(List<int> ids) async {
    try {
      final db = await _dbHelper.database;
      final placeholders = List.filled(ids.length, '?').join(',');
      
      final rowsAffected = await db.delete(
        tableName,
        where: 'id IN ($placeholders)',
        whereArgs: ids,
      );
      
      return rowsAffected;
    } catch (e) {
      print('❌ Error deleting multiple interviews: $e');
      throw Exception('Failed to delete multiple interviews: $e');
    }
  }
  
  /// Delete all interviews
  Future<int> deleteAllInterviews() async {
    try {
      final db = await _dbHelper.database;
      return await db.delete(tableName);
    } catch (e) {
      print('❌ Error deleting all interviews: $e');
      throw Exception('Failed to delete all interviews: $e');
    }
  }
  
  /// Delete unsynced interviews
  Future<int> deleteUnsyncedInterviews() async {
    try {
      final db = await _dbHelper.database;
      return await db.delete(
        tableName,
        where: 'is_synced = ?',
        whereArgs: [0],
      );
    } catch (e) {
      print('❌ Error deleting unsynced interviews: $e');
      throw Exception('Failed to delete unsynced interviews: $e');
    }
  }
  
  // ========== STATISTICS & ANALYTICS ==========
  
  /// Get total number of interviews
  Future<int> getTotalInterviewsCount() async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery('SELECT COUNT(*) FROM $tableName');
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      print('❌ Error getting interviews count: $e');
      throw Exception('Failed to get interviews count: $e');
    }
  }
  
  /// Get unsynced interviews count
  Future<int> getUnsyncedInterviewsCount() async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) FROM $tableName WHERE is_synced = ?',
        [0],
      );
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      print('❌ Error getting unsynced count: $e');
      throw Exception('Failed to get unsynced count: $e');
    }
  }
  
  /// Get interviews count by community type
  Future<Map<String, int>> getInterviewsCountByCommunityType() async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery('''
        SELECT community_type, COUNT(*) as count 
        FROM $tableName 
        GROUP BY community_type
      ''');
      
      final Map<String, int> counts = {};
      for (final row in result) {
        final type = row['community_type'] as String? ?? 'Unknown';
        final count = row['count'] as int? ?? 0;
        counts[type] = count;
      }
      
      return counts;
    } catch (e) {
      print('❌ Error getting community type counts: $e');
      throw Exception('Failed to get community type statistics: $e');
    }
  }
  
  /// Get interviews count by enumerator
  Future<Map<int, int>> getInterviewsCountByEnumerator() async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery('''
        SELECT enumerator, COUNT(*) as count 
        FROM $tableName 
        GROUP BY enumerator
      ''');
      
      final Map<int, int> counts = {};
      for (final row in result) {
        final enumerator = row['enumerator'] as int? ?? 0;
        final count = row['count'] as int? ?? 0;
        counts[enumerator] = count;
      }
      
      return counts;
    } catch (e) {
      print('❌ Error getting enumerator counts: $e');
      throw Exception('Failed to get enumerator statistics: $e');
    }
  }
  
  /// Get daily interview counts
  Future<Map<DateTime, int>> getDailyInterviewCounts(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery('''
        SELECT DATE(created_at) as date, COUNT(*) as count
        FROM $tableName
        WHERE created_at BETWEEN ? AND ?
        GROUP BY DATE(created_at)
        ORDER BY date
      ''', [
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ]);
      
      final Map<DateTime, int> dailyCounts = {};
      for (final row in result) {
        final dateStr = row['date'] as String?;
        if (dateStr != null) {
          final date = DateTime.parse(dateStr);
          final count = row['count'] as int? ?? 0;
          dailyCounts[date] = count;
        }
      }
      
      return dailyCounts;
    } catch (e) {
      print('❌ Error getting daily counts: $e');
      throw Exception('Failed to get daily statistics: $e');
    }
  }
  
  // ========== DATA EXPORT/IMPORT ==========
  
  /// Export all interviews as JSON
  Future<List<Map<String, dynamic>>> exportAllInterviews() async {
    try {
      final interviews = await getAllInterviews();
      return interviews.map((interview) => interview.toJson()).toList();
    } catch (e) {
      print('❌ Error exporting interviews: $e');
      throw Exception('Failed to export interviews: $e');
    }
  }
  
  /// Export unsynced interviews as JSON
  Future<List<Map<String, dynamic>>> exportUnsyncedInterviews() async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        tableName,
        where: 'is_synced = ?',
        whereArgs: [0],
      );
      
      return maps;
    } catch (e) {
      print('❌ Error exporting unsynced interviews: $e');
      throw Exception('Failed to export unsynced interviews: $e');
    }
  }
  
  /// Import interviews from JSON
  Future<int> importInterviews(List<Map<String, dynamic>> jsonData) async {
    int importedCount = 0;
    try {
      final db = await _dbHelper.database;
      
      await db.transaction((txn) async {
        for (final data in jsonData) {
          try {
            final interview = FarmerInterview.fromJson(data);
            await txn.insert(
              tableName,
              interview.toJson(),
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
            importedCount++;
          } catch (e) {
            print('❌ Error importing interview data: $e');
            // Continue with other records
          }
        }
      });
      
      return importedCount;
    } catch (e) {
      print('❌ Error importing interviews: $e');
      throw Exception('Failed to import interviews: $e');
    }
  }
  
  // ========== UTILITY METHODS ==========
  
  /// Check if interview exists
  Future<bool> interviewExists(int id) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery(
        'SELECT 1 FROM $tableName WHERE id = ? LIMIT 1',
        [id],
      );
      return result.isNotEmpty;
    } catch (e) {
      print('❌ Error checking if interview exists: $e');
      return false;
    }
  }
  
  /// Get latest interviews
  Future<List<FarmerInterview>> getLatestInterviews({int count = 10}) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        tableName,
        orderBy: 'created_at DESC',
        limit: count,
      );
      
      return maps.map((map) => FarmerInterview.fromJson(map)).toList();
    } catch (e) {
      print('❌ Error getting latest interviews: $e');
      throw Exception('Failed to get latest interviews: $e');
    }
  }
  
  /// Get interviews with children present
  Future<List<FarmerInterview>> getInterviewsWithChildren() async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        tableName,
        where: 'children_present = ?',
        whereArgs: ['yes'],
      );
      
      return maps.map((map) => FarmerInterview.fromJson(map)).toList();
    } catch (e) {
      print('❌ Error getting interviews with children: $e');
      throw Exception('Failed to get interviews with children: $e');
    }
  }
  
  /// Get interviews by school fees owed status
  Future<List<FarmerInterview>> getInterviewsBySchoolFeesStatus(String status) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        tableName,
        where: 'school_fees_owed = ?',
        whereArgs: [status],
      );
      
      return maps.map((map) => FarmerInterview.fromJson(map)).toList();
    } catch (e) {
      print('❌ Error getting interviews by school fees status: $e');
      throw Exception('Failed to get interviews by school fees status: $e');
    }
  }
  
  /// Get interviews requiring remediation
  Future<List<FarmerInterview>> getInterviewsRequiringRemediation() async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        tableName,
        where: 'school_fees_owed = ? OR parent_remediation != ? OR community_remediation != ?',
        whereArgs: ['yes', '', ''],
      );
      
      return maps.map((map) => FarmerInterview.fromJson(map)).toList();
    } catch (e) {
      print('❌ Error getting interviews requiring remediation: $e');
      throw Exception('Failed to get interviews requiring remediation: $e');
    }
  }
  
  // ========== BATCH OPERATIONS ==========
  
  /// Batch update multiple interviews
  Future<int> batchUpdate(List<Map<String, dynamic>> updates) async {
    int totalUpdated = 0;
    try {
      final db = await _dbHelper.database;
      
      await db.transaction((txn) async {
        for (final update in updates) {
          final id = update['id'];
          final data = Map<String, dynamic>.from(update);
          data.remove('id');
          data['updated_at'] = DateTime.now().toIso8601String();
          
          final rowsAffected = await txn.update(
            tableName,
            data,
            where: 'id = ?',
            whereArgs: [id],
          );
          
          totalUpdated += rowsAffected;
        }
      });
      
      return totalUpdated;
    } catch (e) {
      print('❌ Error in batch update: $e');
      throw Exception('Failed to batch update interviews: $e');
    }
  }
  
  // ========== DATA INTEGRITY ==========
  
  /// Validate interview data
  Future<bool> validateInterview(FarmerInterview interview) async {
    try {
      // Check required fields
      if (interview.enumerator == null) return false;
      if (interview.farmer == null) return false;
      if (interview.interviewStartTime == null) return false;
      if (interview.nameOwner == null || interview.nameOwner!.isEmpty) return false;
      if (interview.firstNameOwner == null || interview.firstNameOwner!.isEmpty) return false;
      
      // Validate data types
      if (interview.numChildren5To17 != null && interview.numChildren5To17! < 0) return false;
      if (interview.totalAdults != null && interview.totalAdults! < 0) return false;
      if (interview.numberOfFemaleAdults != null && interview.numberOfFemaleAdults! < 0) return false;
      if (interview.numberOfMaleAdults != null && interview.numberOfMaleAdults! < 0) return false;
      
      return true;
    } catch (e) {
      print('❌ Error validating interview: $e');
      return false;
    }
  }
  
  /// Clean up orphaned interviews
  Future<int> cleanupOrphanedInterviews() async {
    try {
      // Example: Delete interviews with invalid farmer references
      // You might need to adjust this based on your foreign key relationships
      final db = await _dbHelper.database;
      
      // This is just an example - you'll need to implement based on your actual schema
      return 0;
    } catch (e) {
      print('❌ Error cleaning up orphaned interviews: $e');
      return 0;
    }
  }
  
  /// Get database size
  Future<int> getDatabaseSize() async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery(
        'SELECT page_count * page_size as size FROM pragma_page_count(), pragma_page_size()'
      );
      return result.first['size'] as int? ?? 0;
    } catch (e) {
      print('❌ Error getting database size: $e');
      return 0;
    }
  }
}

extension FarmerInterviewRepositoryExtensions on FarmerInterviewRepository {
  /// Get interviews by status (you might need to add a status field to your model)
  Future<List<FarmerInterview>> getInterviewsByStatus(int status) async {
    try {
      final db = await LocalDBHelper.instance.database;
      final maps = await db.query(
        FarmerInterviewRepository.tableName,  // Add class name qualifier here
        where: 'status = ?',
        whereArgs: [status],
        orderBy: 'created_at DESC',
      );
      // ... rest of the code
      
      return maps.map((map) => FarmerInterview.fromJson(map)).toList();
    } catch (e) {
      print('❌ Error getting interviews by status: $e');
      throw Exception('Failed to get interviews by status: $e');
    }
  }
  
  /// Get today's interviews
  Future<List<FarmerInterview>> getTodayInterviews() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(Duration(days: 1));
    
    return await getInterviewsByDateRange(startOfDay, endOfDay);
  }
  
  /// Get this week's interviews
  Future<List<FarmerInterview>> getThisWeekInterviews() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(Duration(days: 7));
    
    return await getInterviewsByDateRange(
      DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
      DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day),
    );
  }
}

// Helper class for FarmerInterview model extensions
extension FarmerInterviewModelExtensions on FarmerInterview {
  /// Get full name of owner
  String get fullName => '${nameOwner ?? ''} ${firstNameOwner ?? ''}'.trim();
  
  /// Get formatted interview date
  String? get formattedDate {
    if (interviewStartTime == null) return null;
    try {
      final date = DateTime.parse(interviewStartTime!);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
    } catch (e) {
      return interviewStartTime;
    }
  }
  
  /// Check if interview has children
  bool get hasChildren => childrenPresent == 'yes';
  
  /// Check if school fees are owed
  bool get owesSchoolFees => schoolFeesOwed == 'yes';
  
  /// Get total household members
  int get totalHouseholdMembers {
    final adults = (totalAdults ?? 0);
    final children = (numChildren5To17 ?? 0);
    return adults + children;
  }
  
  /// Get gender ratio
  double? get genderRatio {
    if (numberOfMaleAdults == null || numberOfFemaleAdults == null) return null;
    if (numberOfFemaleAdults == 0) return null;
    return numberOfMaleAdults! / numberOfFemaleAdults!;
  }
}