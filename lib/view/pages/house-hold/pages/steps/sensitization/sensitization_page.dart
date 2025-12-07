import 'package:flutter/material.dart';
import 'package:human_rights_monitor/controller/db/db.dart';
import 'package:human_rights_monitor/controller/db/daos/sensitization_dao.dart';
import 'package:human_rights_monitor/controller/models/household_models.dart';
import 'package:human_rights_monitor/controller/db/db_tables/helpers/household_db_helper.dart';
import 'package:human_rights_monitor/view/pages/house-hold/pages/steps/sensitization/sensitization_questions_page.dart';

/// A page that displays sensitization information about child labor and safe practices.
class SensitizationPage extends StatefulWidget {
  final int coverPageId;

  const SensitizationPage({
    Key? key,
    required this.coverPageId,
  }) : super(key: key);

  @override
  SensitizationPageState createState() => SensitizationPageState();
}

class SensitizationPageState extends State<SensitizationPage> {
  // ==================== FORM STATE ====================
  bool _isAcknowledged = false;
  bool _isSaving = false;
  bool _showValidationError = false;

  // ==================== CONTENT CONSTANTS ====================
  static const String description = '''
Child labor, particularly in cocoa farming, is a serious issue that affects children's health, education, and future opportunities. This sensitization aims to educate parents, guardians, and community members about child labor, its harmful effects, and alternative safe practices. By understanding these principles, we can work together to create safer environments for children and ensure their rights to education, health, and proper development are protected.
''';

  static const String goodParentingTitle = 'GOOD PARENTING';
  static const List<String> goodParentingBullets = [
    'Children have rights to education, health, and a safe environment.',
    'Children should be protected from all forms of abuse, including child labor.',
    'Parents should ensure their children attend school regularly and complete their education.',
    'Children\'s opinions should be respected and considered in decisions affecting them.',
    'Parents should provide emotional support and guidance to their children.',
  ];

  static const String childProtectionTitle = 'CHILD PROTECTION';
  static const List<String> childProtectionBullets = [
    'Child labor is illegal and harmful to children\'s development.',
    'Children should not be exposed to dangerous tasks or hazardous environments.',
    'Children have the right to be protected from economic exploitation.',
    'Any form of child abuse, neglect, or exploitation should be reported to authorities.',
    'Communities should work together to protect children from harmful practices.',
  ];

  static const String safeLabourPracticesTitle = 'SAFE LABOUR PRACTICES';
  static const List<String> safeLabourPracticesBullets = [
    'Light household chores appropriate to the child\'s age are acceptable under supervision.',
    'Children should never be involved in tasks involving chemicals, heavy machinery, or dangerous tools.',
    'Work should not interfere with school attendance or homework.',
    'Children should have adequate rest, food, and water during any permissible activities.',
    'Adults should always supervise children during any work activities.',
  ];

  // ==================== INITIALIZATION ====================
  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  // ==================== DATA LOADING ====================
  Future<void> _loadSavedData() async {
    try {
      final db = LocalDBHelper.instance;
      final sensitizationDao = SensitizationDao(dbHelper: db);

      final existingData = await sensitizationDao.getByCoverPageId(widget.coverPageId);
      if (existingData != null && mounted) {
        setState(() {
          _isAcknowledged = existingData.isAcknowledged;
        });
        debugPrint('✅ Loaded existing sensitization data');
      }
    } catch (e) {
      debugPrint('❌ Error loading sensitization data: $e');
    }
  }

  // ==================== FORM VALIDATION ====================
  bool _validateForm() {
    if (!_isAcknowledged) {
      setState(() => _showValidationError = true);
      _showSnackBar('Please acknowledge that you have read and understood the information');
      return false;
    }

    setState(() => _showValidationError = false);
    return true;
  }

  // ==================== DATA SAVING ====================
  Future<void> _saveData() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      // Validate form
      if (!_validateForm()) {
        return;
      }

      final now = DateTime.now();

      // Create sensitization data
      final sensitizationData = SensitizationData(
        coverPageId: widget.coverPageId,
        isAcknowledged: _isAcknowledged,
        acknowledgedAt: _isAcknowledged ? now : null,
        createdAt: now,
        updatedAt: now,
        isSynced: false,
        syncStatus: 0,
      );

      debugPrint('💾 Saving sensitization data: ${sensitizationData.toMap()}');

      // Save to database
      final dbHelper = HouseholdDBHelper.instance;
      final id = await dbHelper.insertSensitization(sensitizationData);

      debugPrint('✅ Saved sensitization record with ID: $id');

      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return SensitizationQuestionsPage(
          coverPageId: widget.coverPageId,
        );
      }));

      _showSnackBar(
        'Acknowledgement saved successfully',
        backgroundColor: Colors.green,
      );

    } catch (e) {
      debugPrint('❌ Error saving sensitization acknowledgment: $e');
      _showSnackBar('Failed to save acknowledgment. Please try again.');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  // ==================== UI COMPONENTS ====================
  void _showSnackBar(String message, {Color backgroundColor = Colors.red}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
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

  Widget _buildBulletPoint(String text) {
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

  Widget _buildAcknowledgmentCheckbox() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: _isAcknowledged,
              onChanged: (value) {
                setState(() {
                  _isAcknowledged = value ?? false;
                  _showValidationError = false;
                });
              },
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
                  if (_showValidationError)
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
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isSaving ? null : _saveData,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _isSaving
              ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(Colors.white),
            ),
          )
              : const Text(
            'Continue',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // ==================== MAIN BUILD ====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensitization'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main description
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.5,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // GOOD PARENTING Section
                  _buildSectionTitle(goodParentingTitle),
                  ...goodParentingBullets.map(_buildBulletPoint),

                  const SizedBox(height: 16),

                  // CHILD PROTECTION Section
                  _buildSectionTitle(childProtectionTitle),
                  ...childProtectionBullets.map(_buildBulletPoint),

                  const SizedBox(height: 16),

                  // SAFE LABOUR PRACTICES Section
                  _buildSectionTitle(safeLabourPracticesTitle),
                  ...safeLabourPracticesBullets.map(_buildBulletPoint),

                  const SizedBox(height: 24),

                  // Acknowledgment checkbox
                  _buildAcknowledgmentCheckbox(),
                ],
              ),
            ),
          ),
          _buildActionButtons(),
        ],
      ),
    );
  }
}