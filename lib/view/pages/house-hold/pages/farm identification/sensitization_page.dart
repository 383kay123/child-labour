import 'package:flutter/material.dart';

import '../../../../../../view/theme/app_theme.dart'; // Updated to use relative path
import 'sensitization_questions_page.dart';

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

class SensitizationPage extends StatefulWidget {
  const SensitizationPage({Key? key}) : super(key: key);

  @override
  _SensitizationPageState createState() => _SensitizationPageState();
}

class _SensitizationPageState extends State<SensitizationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensitization'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Please take a moment to understand the dangers and impact of child labour and to promote child protection and education.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.5,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
            ),

            const SizedBox(height: 16),

            // GOOD PARENTING Section
            const SectionTitle('GOOD PARENTING'),
            const BulletPoint(
                'Every parent is responsible for loving, protecting, training and discipling their children.'),
            const BulletPoint(
                'Good parenting begins from inception. It is cheaper to get things right during early childhood than trying to fix it later.'),
            const BulletPoint(
                'Good parenting nurtures innovation and creative thinking in children.'),
            const BulletPoint(
                'Parenting a child is a one-time opportunity; there is no do-over.'),

            // CHILD PROTECTION Section
            const SectionTitle('CHILD PROTECTION'),
            const BulletPoint(
                'Children\'s rights are all about the needs of a child, all the care and the protection a child must enjoy to guarantee his/her development and full growth.'),
            const BulletPoint(
                'Child labour is mentally, physically, socially, morally dangerous and detrimental to children\'s development.'),
            const BulletPoint(
                'Socialization of children must not be an excuse for exploitation or compromise their education.'),
            const BulletPoint(
                'Children are more likely to have occupational accidents because they are less experienced, less aware of the risks and means to prevent them.'),
            const BulletPoint(
                'Child labour can have tragic consequences at individual, family, community and national levels.'),

            // SAFE LABOUR PRACTICES Section
            const SectionTitle('SAFE LABOUR PRACTICES'),
            const BulletPoint(
                'Carefully read the instructions provided for the use of the chemical product before application.'),
            const BulletPoint(
                'Wear the appropriate protective clothing and footwear before setting off to the farm.'),
            const BulletPoint(
                'Wear protective clothing during spraying of agrochemical products, fertilizer application and pruning.'),
            const BulletPoint(
                'Threats, harassment, assault and deprivations of all kinds are all characteristics of forced labour.'),
            const BulletPoint(
                'Forced/compulsory labour is an affront to children\'s rights and development.'),
            const BulletPoint(
                'Promote safe labour practices in cocoa cultivation among adults.'),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SensitizationQuestionsPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'I Understand',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
