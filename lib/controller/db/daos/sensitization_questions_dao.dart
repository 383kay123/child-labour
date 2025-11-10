import 'package:sqflite/sqflite.dart';
import 'package:human_rights_monitor/controller/db/db.dart';
import 'package:human_rights_monitor/controller/models/sensitization_questions_model.dart';

class SensitizationQuestionsDao {
  final LocalDBHelper dbHelper;

  SensitizationQuestionsDao({required this.dbHelper});

  /// Inserts a new sensitization questions record
  Future<int> insert(SensitizationQuestionsData model, int farmIdentificationId) async {
    final db = await dbHelper.database;
    
    final data = {
      'farm_identification_id': farmIdentificationId,
      'has_sensitized_household': model.hasSensitizedHousehold == true ? 1 : 0,
      'has_sensitized_on_protection': model.hasSensitizedOnProtection == true ? 1 : 0,
      'has_sensitized_on_safe_labour': model.hasSensitizedOnSafeLabour == true ? 1 : 0,
      'female_adults_count': model.femaleAdultsCount,
      'male_adults_count': model.maleAdultsCount,
      'consent_for_picture': model.consentForPicture == true ? 1 : 0,
      'consent_reason': model.consentReason,
      'sensitization_image_path': model.sensitizationImagePath,
      'household_with_user_image_path': model.householdWithUserImagePath,
      'parents_reaction': model.parentsReaction,
      'submitted_at': model.submittedAt.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'is_synced': 0,
      'sync_status': 0,
    };

    return await db.insert(
      'sensitization_questions',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Updates an existing sensitization questions record
  Future<int> update(SensitizationQuestionsData model, int id) async {
    final db = await dbHelper.database;
    
    final data = {
      'has_sensitized_household': model.hasSensitizedHousehold == true ? 1 : 0,
      'has_sensitized_on_protection': model.hasSensitizedOnProtection == true ? 1 : 0,
      'has_sensitized_on_safe_labour': model.hasSensitizedOnSafeLabour == true ? 1 : 0,
      'female_adults_count': model.femaleAdultsCount,
      'male_adults_count': model.maleAdultsCount,
      'consent_for_picture': model.consentForPicture == true ? 1 : 0,
      'consent_reason': model.consentReason,
      'sensitization_image_path': model.sensitizationImagePath,
      'household_with_user_image_path': model.householdWithUserImagePath,
      'parents_reaction': model.parentsReaction,
      'updated_at': DateTime.now().toIso8601String(),
      'is_synced': 0,
    };

    return await db.update(
      'sensitization_questions',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Gets a sensitization questions record by ID
  Future<SensitizationQuestionsData?> getById(int id) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sensitization_questions',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return _fromMap(maps.first);
  }

  /// Gets a sensitization questions record by farm identification ID
  Future<SensitizationQuestionsData?> getByFarmIdentificationId(int farmId) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sensitization_questions',
      where: 'farm_identification_id = ?',
      whereArgs: [farmId],
      orderBy: 'submitted_at DESC',
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return _fromMap(maps.first);
  }

  /// Gets all sensitization questions records
  Future<List<SensitizationQuestionsData>> getAll() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('sensitization_questions');
    return List.generate(maps.length, (i) => _fromMap(maps[i]));
  }

  /// Gets all unsynced sensitization questions records
  Future<List<SensitizationQuestionsData>> getUnsynced() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sensitization_questions',
      where: 'is_synced = 0',
    );
    return List.generate(maps.length, (i) => _fromMap(maps[i]));
  }

  /// Deletes a sensitization questions record by ID
  Future<int> delete(int id) async {
    final db = await dbHelper.database;
    return await db.delete(
      'sensitization_questions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Converts a database map to a SensitizationQuestionsData
  SensitizationQuestionsData _fromMap(Map<String, dynamic> map) {
    return SensitizationQuestionsData(
      hasSensitizedHousehold: map['has_sensitized_household'] == 1,
      hasSensitizedOnProtection: map['has_sensitized_on_protection'] == 1,
      hasSensitizedOnSafeLabour: map['has_sensitized_on_safe_labour'] == 1,
      femaleAdultsCount: map['female_adults_count'] ?? '',
      maleAdultsCount: map['male_adults_count'] ?? '',
      consentForPicture: map['consent_for_picture'] == 1,
      consentReason: map['consent_reason'] ?? '',
      sensitizationImagePath: map['sensitization_image_path'],
      householdWithUserImagePath: map['household_with_user_image_path'],
      parentsReaction: map['parents_reaction'] ?? '',
      submittedAt: map['submitted_at'] != null 
          ? DateTime.parse(map['submitted_at']) 
          : DateTime.now(),
    );
  }

  /// Saves a sensitization questions record (inserts or updates)
  Future<int> save(SensitizationQuestionsData model, int farmIdentificationId, {int? id}) async {
    if (id == null) {
      return await insert(model, farmIdentificationId);
    } else {
      return await update(model, id);
    }
  }

  /// Gets the count of unsynced sensitization questions records
  Future<int> getUnsyncedCount() async {
    final db = await dbHelper.database;
    final count = await db.rawQuery(
      'SELECT COUNT(*) as count FROM sensitization_questions WHERE is_synced = 0',
    );
    return count.first['count'] as int;
  }

  /// Marks a record as synced
  Future<int> markAsSynced(int id) async {
    final db = await dbHelper.database;
    return await db.update(
      'sensitization_questions',
      {
        'is_synced': 1,
        'sync_status': 1,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Checks if a farm has any sensitization records
  Future<bool> hasSensitizationRecord(int farmId) async {
    final db = await dbHelper.database;
    final count = await db.rawQuery('''
      SELECT COUNT(*) as count FROM sensitization_questions 
      WHERE farm_identification_id = ?
    ''', [farmId]);
    
    return (count.first['count'] as int) > 0;
  }
}
