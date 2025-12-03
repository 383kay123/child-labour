import 'package:human_rights_monitor/controller/db/db.dart';
import 'package:human_rights_monitor/controller/db/table_names.dart';
import 'package:human_rights_monitor/controller/models/auth/user_model.dart';
import 'package:human_rights_monitor/controller/models/staff/staff_model.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

// Type alias for backward compatibility
typedef Staff = StaffModel;

class StaffRepository {
  final LocalDBHelper databaseHelper = LocalDBHelper.instance;

  // Create - Insert a single staff
  Future<int> insertStaff(Staff staff) async {
    final db = await databaseHelper.database;
    
    return await db.transaction((txn) async {
      try {
        // Convert staff to JSON and remove assigned_districts
        final staffJson = staff.toJson();
        final assignedDistricts = staff.assignedDistricts;
        staffJson.remove('assigned_districts');
        
        final id = await txn.insert(
          TableNames.staffTBL,
          staffJson,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        
        // Insert assigned districts if any
        if (assignedDistricts.isNotEmpty) {
          await _insertStaffDistricts(txn, id, assignedDistricts);
        }
        
        return id;
      } catch (e) {
        debugPrint('Error inserting staff: $e');
        throw Exception('Failed to insert staff: $e');
      }
    });
  }

  // Bulk Insert - Insert multiple staff
  Future<List<int>> insertStaffList(List<Staff> staffList) async {
    final db = await databaseHelper.database;
    
    return await db.transaction((txn) async {
      final List<int> ids = [];
      
      for (final staff in staffList) {
        // Convert staff to JSON and remove assigned_districts
        final staffJson = staff.toJson();
        final assignedDistricts = staff.assignedDistricts;
        staffJson.remove('assigned_districts');
        
        final id = await txn.insert(
          TableNames.staffTBL,
          staffJson,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        ids.add(id);
        
        // Insert assigned districts
        if (assignedDistricts.isNotEmpty) {
          await _insertStaffDistricts(txn, staff.id, assignedDistricts);
        }
      }
      
      return ids;
    });
  }

  // Read - Get all staff
  Future<List<Staff>> getAllStaff() async {
    final db = await databaseHelper.database;
    
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        TableNames.staffTBL,
        orderBy: 'first_name ASC, last_name ASC',
      );
      
      final List<Staff> staffList = [];
      
      for (final map in maps) {
        final staff = Staff.fromJson(map);
        
        // Get assigned districts for this staff
        final districts = await _getStaffDistricts(db, staff.id);
        staffList.add(staff.copyWith(assignedDistricts: districts));
      }
      
      return staffList;
    } catch (e) {
      debugPrint('Error getting all staff: $e');
      throw Exception('Failed to get all staff: $e');
    }
  }

  // Read - Get first 10 staff, ordered by staff ID
  Future<List<Staff>> getFirst10Staff() async {
    try {
      final db = await databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        TableNames.staffTBL,
        orderBy: 'staffid ASC',
        limit: 10,
      );
      
      debugPrint('Fetched ${maps.length} staff');
      
      final List<Staff> staffList = [];
      
      for (final map in maps) {
        final staff = Staff.fromJson(map);
        final districts = await _getStaffDistricts(db, staff.id);
        staffList.add(staff.copyWith(assignedDistricts: districts));
      }
      
      return staffList;
    } catch (e) {
      debugPrint('Error in getFirst10Staff: $e');
      rethrow;
    }
  }

  // Read - Get staff by ID
  Future<Staff?> getStaffById(int id) async {
    final db = await databaseHelper.database;
    
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        TableNames.staffTBL,
        where: 'id = ?',
        whereArgs: [id],
      );
      
      if (maps.isNotEmpty) {
        final staff = Staff.fromJson(maps.first);
        final districts = await _getStaffDistricts(db, id);
        return staff.copyWith(assignedDistricts: districts);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting staff by ID: $e');
      throw Exception('Failed to get staff by ID: $e');
    }
  }

  // Read - Get staff by staff ID
  Future<Staff?> getStaffByStaffId(String staffId) async {
    final db = await databaseHelper.database;
    
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        TableNames.staffTBL,
        where: 'staffid = ?',
        whereArgs: [staffId],
      );
      
      if (maps.isNotEmpty) {
        final staff = Staff.fromJson(maps.first);
        final districts = await _getStaffDistricts(db, staff.id);
        return staff.copyWith(assignedDistricts: districts);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting staff by staff ID: $e');
      throw Exception('Failed to get staff by staff ID: $e');
    }
  }

  // Update - Update staff by ID
  Future<int> updateStaff(Staff staff) async {
    final db = await databaseHelper.database;
    
    return await db.transaction((txn) async {
      // Update staff record
      final rowsAffected = await txn.update(
        TableNames.staffTBL,
        staff.toJson(),
        where: 'id = ?',
        whereArgs: [staff.id],
      );
      
      // Update assigned districts
      await _updateStaffDistricts(txn, staff.id, staff.assignedDistricts);
      
      return rowsAffected;
    });
  }

  // Update - Update staff by staff ID
  Future<int> updateStaffByStaffId(Staff staff) async {
    final db = await databaseHelper.database;
    
    return await db.transaction((txn) async {
      // Update staff record
      final rowsAffected = await txn.update(
        TableNames.staffTBL,
        staff.toJson(),
        where: 'staffid = ?',
        whereArgs: [staff.staffId],
      );
      
      // Update assigned districts
      await _updateStaffDistricts(txn, staff.id, staff.assignedDistricts);
      
      return rowsAffected;
    });
  }

  // Delete - Delete staff by ID
  Future<int> deleteStaff(int id) async {
    final db = await databaseHelper.database;
    
    try {
      return await db.delete(
        TableNames.staffTBL,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      debugPrint('Error deleting staff: $e');
      throw Exception('Failed to delete staff: $e');
    }
  }

  // Delete - Delete staff by staff ID
  Future<int> deleteStaffByStaffId(String staffId) async {
    final db = await databaseHelper.database;
    
    try {
      return await db.delete(
        TableNames.staffTBL,
        where: 'staffid = ?',
        whereArgs: [staffId],
      );
    } catch (e) {
      debugPrint('Error deleting staff by staff ID: $e');
      throw Exception('Failed to delete staff by staff ID: $e');
    }
  }

  // Delete all staff
  Future<int> deleteAllStaff() async {
    final db = await databaseHelper.database;
    
    try {
      return await db.delete(TableNames.staffTBL);
    } catch (e) {
      debugPrint('Error deleting all staff: $e');
      throw Exception('Failed to delete all staff: $e');
    }
  }

  // Count total staff
  Future<int> getStaffCount() async {
    final db = await databaseHelper.database;
    
    try {
      final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM ${TableNames.staffTBL}'),
      );
      return count ?? 0;
    } catch (e) {
      debugPrint('Error getting staff count: $e');
      throw Exception('Failed to get staff count: $e');
    }
  }

  // Search staff by name or staff ID
  Future<List<Staff>> searchStaff(String query) async {
    final db = await databaseHelper.database;
    
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        TableNames.staffTBL,
        where: 'first_name LIKE ? OR last_name LIKE ? OR staffid LIKE ?',
        whereArgs: ['%$query%', '%$query%', '%$query%'],
        orderBy: 'first_name ASC',
      );
      
      final List<Staff> staffList = [];
      
      for (final map in maps) {
        final staff = Staff.fromJson(map);
        final districts = await _getStaffDistricts(db, staff.id);
        staffList.add(staff.copyWith(assignedDistricts: districts));
      }
      
      return staffList;
    } catch (e) {
      debugPrint('Error searching staff: $e');
      throw Exception('Failed to search staff: $e');
    }
  }

  // Get staff by designation with pagination
  Future<List<Staff>> getStaffByDesignation(
    int designation, {
    int limit = 10,
    int offset = 0,
  }) async {
    final db = await databaseHelper.database;
    
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        TableNames.staffTBL,
        where: 'designation = ?',
        whereArgs: [designation],
        limit: limit,
        offset: offset,
        orderBy: 'first_name ASC, last_name ASC',
      );
      
      final List<Staff> staffList = [];
      
      for (final map in maps) {
        final staff = Staff.fromJson(map);
        final districts = await _getStaffDistricts(db, staff.id);
        staffList.add(staff.copyWith(assignedDistricts: districts));
      }
      
      return staffList;
    } catch (e) {
      debugPrint('Error getting staff by designation: $e');
      rethrow;
    }
  }

  // ========== PRIVATE HELPER METHODS ==========

  // Insert staff districts
  Future<void> _insertStaffDistricts(
    Transaction txn,
    int staffId,
    List<AssignedDistrict> districts,
  ) async {
    if (districts.isEmpty) return;
    
    final batch = txn.batch();
    
    for (final district in districts) {
      batch.insert(
        TableNames.staffDistrictsTBL,
        {
          'staff_id': staffId,
          'district_id': district.id,
          'district_name': district.name,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    
    await batch.commit(noResult: true);
  }

  // Get staff districts
  Future<List<AssignedDistrict>> _getStaffDistricts(Database db, int staffId) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        TableNames.staffDistrictsTBL,
        where: 'staff_id = ?',
        whereArgs: [staffId],
      );
      
      return maps.map((map) => AssignedDistrict(
        id: map['district_id'] as int,
        name: map['district_name'] as String,
      )).toList();
    } catch (e) {
      debugPrint('Error getting staff districts: $e');
      return [];
    }
  }

  // Update staff districts
  Future<void> _updateStaffDistricts(
    Transaction txn,
    int staffId,
    List<AssignedDistrict> districts,
  ) async {
    // Delete existing districts
    await txn.delete(
      TableNames.staffDistrictsTBL,
      where: 'staff_id = ?',
      whereArgs: [staffId],
    );
    
    // Insert new districts
    if (districts.isNotEmpty) {
      for (final district in districts) {
        await txn.insert(
          TableNames.staffDistrictsTBL,
          {
            'staff_id': staffId,
            'district_id': district.id,
            'district_name': district.name,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }
  }
}