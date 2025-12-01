import 'package:flutter/material.dart';
import 'package:human_rights_monitor/controller/db/db.dart';
import 'package:human_rights_monitor/controller/db/daos/sensitization_dao.dart';
import 'package:human_rights_monitor/controller/models/household_models.dart';
import 'package:human_rights_monitor/controller/db/db_tables/helpers/household_db_helper.dart';

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

  /// The ID of the cover page this sensitization is associated with.
  final int coverPageId;

  /// Callback when the user acknowledges the information.
  final ValueChanged<SensitizationData> onSensitizationChanged;

   /// Callback when moving to the next page.
  final VoidCallback? onNext;

  /// Callback when moving to the previous page.
  final VoidCallback? onPrevious;

  const SensitizationPage({
    Key? key,
    required this.sensitizationData,
    required this.coverPageId,
    required this.onSensitizationChanged,
     this.onNext,
    this.onPrevious,
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

  @override
  void initState() {
    super.initState();
    _isAcknowledged = widget.sensitizationData.isAcknowledged;
    _loadSensitizationData();
  }

  @override
  bool validate() {
    final isValid = _isAcknowledged;
    if (mounted) {
      setState(() {
        _isCheckboxValid = isValid;
      });
    }
    
    if (!isValid) {
      _showErrorSnackBar('Please acknowledge that you have read and understood the information');
    }
    
    return isValid;
  }

  /// Shows an error message to the user
  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// Saves the sensitization data to the database
 @override
Future<bool> saveData(int coverPageId) async {
  try {
    debugPrint('💾 Saving sensitization acknowledgment...');
    
    if (!validate()) {
      return false;
    }

    final now = DateTime.now();
    
    // Validate coverPageId
    if (coverPageId == null) {
      throw ArgumentError('coverPageId cannot be null when saving sensitization');
    }
    
    // Create updated sensitization data with the current state
    final sensitizationData = SensitizationData(
      id: widget.sensitizationData.id,
      coverPageId: coverPageId, // Ensure coverPageId is set
      isAcknowledged: _isAcknowledged,
      acknowledgedAt: _isAcknowledged ? now : null,
      createdAt: widget.sensitizationData.createdAt ?? now,
      updatedAt: now,
      isSynced: false,
      syncStatus: 0,
    );

    debugPrint('📋 Sensitization data to save: ${sensitizationData.toMap()}');

    // Save to database using the helper method
    final dbHelper = HouseholdDBHelper.instance;
    final id = await dbHelper.insertSensitization(sensitizationData);
    debugPrint('✅ Saved sensitization record with ID: $id');
    
    // Update parent
    if (mounted) {
      widget.onSensitizationChanged(sensitizationData);
    }
    return true;
    
  } catch (e, stackTrace) {
    debugPrint('❌ Error saving sensitization acknowledgment: $e');
    debugPrint('Stack trace: $stackTrace');
    
    if (mounted) {
      _showErrorSnackBar('Failed to save acknowledgment. Please try again.');
    }
    return false;
  }
}
  /// Loads the sensitization data from the database
  Future<void> _loadSensitizationData() async {
    try {
      final db = LocalDBHelper.instance;
      final sensitizationDao = SensitizationDao(dbHelper: db);
      
      // Use the coverPageId to load the data
      final existingData = await sensitizationDao.getByCoverPageId(widget.coverPageId);
      if (existingData != null && mounted) {
        setState(() {
          _isAcknowledged = existingData.isAcknowledged;
        });
        // Update the parent widget with the loaded data
        widget.onSensitizationChanged(existingData);
        return;
      }
      
      // If no data found by coverPageId, fall back to the data passed in
      if (mounted) {
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

            // Acknowledgment checkbox
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: _isAcknowledged,
                  onChanged: (value) => _onCheckboxChanged(value ?? false),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'I acknowledge that I have read and understood the information above',
                        style: TextStyle(fontSize: 16),
                      ),
                      if (!_isCheckboxValid)
                        const Padding(
                          padding: EdgeInsets.only(top: 4.0),
                          child: Text(
                            'Please acknowledge the information to continue',
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
          ],
        ),
      ),
    );
  }
}
