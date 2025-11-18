import 'package:flutter/material.dart';
import 'package:human_rights_monitor/controller/db/db.dart';
import 'package:human_rights_monitor/controller/db/db_tables/helpers/household_db_helper.dart';
import 'package:human_rights_monitor/controller/db/daos/sensitization_dao.dart';
import 'package:human_rights_monitor/controller/models/household_models.dart';


/// A reusable widget that displays a section title with consistent styling.
class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle(this.title, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).primaryColor,
            ),
      ),
    );
  }
}

/// A reusable widget that displays a bullet point with consistent styling.
class BulletPoint extends StatelessWidget {
  final String text;

  const BulletPoint(this.text, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('•  ', style: Theme.of(context).textTheme.bodyMedium),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A page that displays sensitization information about child labor and safe practices.
class SensitizationPage extends StatefulWidget {
  /// The current sensitization data.
  final SensitizationData sensitizationData;

  /// Callback when the user acknowledges the information.
  final ValueChanged<SensitizationData> onSensitizationChanged;

  const SensitizationPage({
    Key? key,
    required this.sensitizationData,
    required this.onSensitizationChanged,
  }) : super(key: key);

  @override
  _SensitizationPageState createState() => _SensitizationPageState();
  
  // Helper method to get the state from a GlobalKey
  static SensitizationPageState? of(GlobalKey<State<SensitizationPage>> key) {
    final state = key.currentState;
    if (state is _SensitizationPageState) {
      return state;
    }
    return null;
  }

  // Public static method to access the state type
  static Type get stateType => _SensitizationPageState;
}

// Public interface for the SensitizationPage state
abstract class SensitizationPageState extends State<SensitizationPage> {
  bool validate();
  Future<bool> saveData(int farmIdentificationId);
}

class _SensitizationPageState extends SensitizationPageState {
  late bool _isAcknowledged;
  bool _isCheckboxValid = true;
  
  // Expose a method to validate the form
  bool validate() {
    setState(() {
      _isCheckboxValid = _isAcknowledged;
    });
    return _isCheckboxValid;
  }

  /// Saves the sensitization acknowledgment data to the database
  /// [farmIdentificationId] - The ID of the farm identification record to associate with this data
  Future<bool> saveData(int farmIdentificationId) async {
    try {
      debugPrint('💾 Starting to save sensitization data...');
      debugPrint('📝 Acknowledgment status: $_isAcknowledged');
      
      // Always save the current state, even if not acknowledged
      // This ensures we can track the user's response

      // Get the database helper instance
      final db = LocalDBHelper.instance;
      final sensitizationDao = SensitizationDao(dbHelper: db);
      
      // First check if we already have a record for this farm
      final existingData = await sensitizationDao.getByFarmIdentificationId(farmIdentificationId);
      
      // Create or update the SensitizationData
      final now = DateTime.now();
      final sensitizationData = existingData?.copyWith(
        isAcknowledged: _isAcknowledged,
        acknowledgedAt: _isAcknowledged ? now : existingData.acknowledgedAt,
        updatedAt: now,
        isSynced: false,
      ) ?? SensitizationData(
        isAcknowledged: _isAcknowledged,
        acknowledgedAt: _isAcknowledged ? now : null,
        updatedAt: now,
        isSynced: false,
      );
      
      debugPrint('📋 Sensitization data to save: $sensitizationData');
      
      try {
        // Save the data
        if (existingData == null) {
          await sensitizationDao.insert(
            sensitizationData, 
            0, // coverPageId - passing 0 as a placeholder, you may want to pass the actual cover page ID
            farmIdentificationId: farmIdentificationId,
          );
        } else {
          await sensitizationDao.update(sensitizationData, existingData.id!);
        }
        
        debugPrint('✅ Sensitization data saved successfully');
        
        // Update the parent widget's state
        widget.onSensitizationChanged(sensitizationData);
        return true;
      } catch (e, stackTrace) {
        debugPrint('❌ Error saving sensitization data: $e');
        debugPrint('📌 Stack trace: $stackTrace');
        
        // Try to get more information about the database state
        try {
          final dbInstance = await db.database;
          final tables = await dbInstance.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
          debugPrint('Available tables: ${tables.map((t) => t['name']).toList()}');
          
          // Check if sensitization table exists
          final sensitizationTable = tables.firstWhere(
            (t) => t['name'] == 'sensitization',
            orElse: () => {},
          );
          
          if (sensitizationTable.isEmpty) {
            debugPrint('❌ Sensitization table does not exist in the database');
            // Try to create the table directly
            try {
              final householdDbHelper = HouseholdDBHelper.instance;
              await householdDbHelper.diagnoseAndFixSensitizationTable();
              debugPrint('🔄 Created sensitization table, retrying save...');
              
              // Try one more time after fixing the table
              if (existingData == null) {
                await sensitizationDao.insert(
                  sensitizationData, 
                  0, // coverPageId - passing 0 as a placeholder
                  farmIdentificationId: farmIdentificationId,
                );
              } else {
                await sensitizationDao.update(sensitizationData, existingData.id!);
              }
              widget.onSensitizationChanged(sensitizationData);
              debugPrint('✅ Sensitization data saved successfully after table creation');
              return true;
            } catch (e) {
              debugPrint('❌ Failed to save after table creation: $e');
              return false;
            }
          }
        } catch (e) {
          debugPrint('❌ Could not check database tables: $e');
        }
        
        return false;
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error saving sensitization data: $e');
      debugPrint('📌 Stack trace: $stackTrace');
      
      // Try to get more information about the error
      try {
        final db = await LocalDBHelper.instance.database;
        final tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
        debugPrint('Available tables: ${tables.map((t) => t['name']).toList()}');
      } catch (e) {
        debugPrint('Could not list tables: $e');
      }
      
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadSensitizationData();
  }

  /// Loads the sensitization data from the database
  Future<void> _loadSensitizationData() async {
    try {
      final db = LocalDBHelper.instance;
      final sensitizationDao = SensitizationDao(dbHelper: db);
      
      // Get the farm identification ID from the parent widget
      final farmId = widget.sensitizationData.id;
      if (farmId != null) {
        final existingData = await sensitizationDao.getByFarmIdentificationId(farmId);
        if (existingData != null && mounted) {
          setState(() {
            _isAcknowledged = existingData.isAcknowledged;
          });
          // Update the parent widget with the loaded data
          widget.onSensitizationChanged(existingData);
        }
      } else {
        // If no farm ID, use the data passed in
        setState(() {
          _isAcknowledged = widget.sensitizationData.isAcknowledged;
        });
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error loading sensitization data: $e');
      debugPrint('Stack trace: $stackTrace');
      
      // Fall back to the data passed in
      if (mounted) {
        setState(() {
          _isAcknowledged = widget.sensitizationData.isAcknowledged;
        });
      }
    }
  }

  void _onCheckboxChanged(bool value) {
    if (mounted) {
      setState(() {
        _isAcknowledged = value;
        _isCheckboxValid = true; // Clear error when user interacts
        
        // Create updated data with current timestamp
        final updatedData = widget.sensitizationData.copyWith(
          isAcknowledged: value,
          acknowledgedAt: value ? DateTime.now() : null,
          updatedAt: DateTime.now(),
        );
        
        // Update the parent immediately when checkbox state changes
        widget.onSensitizationChanged(updatedData);
        
        debugPrint('🔘 Checkbox changed: $value');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main description
            Text(
              SensitizationContent.description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.5,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
            ),

            const SizedBox(height: 16),

            // GOOD PARENTING Section
            SectionTitle(SensitizationContent.goodParentingTitle),
            ...SensitizationContent.goodParentingBullets
                .map((bullet) => BulletPoint(bullet)),

            // CHILD PROTECTION Section
            SectionTitle(SensitizationContent.childProtectionTitle),
            ...SensitizationContent.childProtectionBullets
                .map((bullet) => BulletPoint(bullet)),

            // SAFE LABOUR PRACTICES Section
            SectionTitle(SensitizationContent.safeLabourPracticesTitle),
            ...SensitizationContent.safeLabourPracticesBullets
                .map((bullet) => BulletPoint(bullet)),

            const SizedBox(height: 24),

            // Checkbox with validation
            Container(
              decoration: BoxDecoration(
                color:
                    _isCheckboxValid ? Colors.transparent : Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: _isCheckboxValid
                    ? null
                    : Border.all(color: Colors.red, width: 1),
              ),
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Checkbox(
                    value: _isAcknowledged,
                    onChanged: (bool? value) {
                      _onCheckboxChanged(value ?? false);
                    },
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'I have read and understood the above information',
                          style: TextStyle(
                            color: _isCheckboxValid ? null : Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (!_isCheckboxValid)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              'This acknowledgement is required to continue',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
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
}
