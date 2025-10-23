import 'package:flutter/material.dart';
import 'package:human_rights_monitor/model/sensitization_model.dart';

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
}

class _SensitizationPageState extends State<SensitizationPage> {
  late bool _isAcknowledged;
  bool _isCheckboxValid = true;

  @override
  void initState() {
    super.initState();
    _isAcknowledged = widget.sensitizationData.isAcknowledged;
  }

  void _onCheckboxChanged(bool value) {
    setState(() {
      _isAcknowledged = value;
      _isCheckboxValid = true; // Clear error when user interacts
      widget.onSensitizationChanged(
        widget.sensitizationData.copyWith(
          isAcknowledged: value,
          acknowledgedAt: value ? DateTime.now() : null,
        ),
      );
    });
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
                    value: widget.sensitizationData.isAcknowledged ?? false,
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
