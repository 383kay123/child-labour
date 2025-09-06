import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:surveyflow/fields/dropdown.dart';
import 'community-assessment-controller.dart';
import 'package:get/get.dart';

class CommunityAssessmentForm extends StatefulWidget {
  const CommunityAssessmentForm({super.key});

  @override
  State<CommunityAssessmentForm> createState() =>
      _CommunityAssessmentFormState();
}

class _CommunityAssessmentFormState extends State<CommunityAssessmentForm> {
  final Map<String, String> _answers = {};
  final CommunityAssessmentController _controller =
  CommunityAssessmentController();

  final List<String> _communities = [
    "Community A",
    "Community B",
    "Community C",
    "Community D"
  ];

  String? _selectedCommunity;

  @override
  Widget build(BuildContext context) {
    _controller.communityAssessmentContext = context;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title:  Text("Community Assessment", style: theme.textTheme.titleLarge?.copyWith(
          fontFamily: GoogleFonts.poppins().fontFamily,
          color: theme.colorScheme.onPrimary,
          fontSize: 18
        ),),
        backgroundColor: theme.primaryColor,
        actions: [
          // Display current score in the app bar
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 16.0),
            child: Obx(() => Text(
              'Score: ${_controller.communityScore.value}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            )),
          ),
        ],
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// Community Name Dropdown
            DropdownField(question: "Select Community", options: _communities, onChanged: (val){
              setState(() {
                _controller.communityName.value = val ?? "";
                _answers["community"] = val ?? "";
              });
            },),

            /// Questions
            _buildQuestionCard(
                context,
                "Do most households in this community have access to a protected water source?",
                "q1"),
            _buildQuestionCard(
                context,
                "Do some households in this community hire adult labourers to do agricultural work?",
                "q2"),
            _buildQuestionCard(
                context,
                "Has at least one awareness-raising session on child labour taken place in the past year?",
                "q3"),
            _buildQuestionCard(
                context,
                "Are there any women among the leaders of this community?",
                "q4"),
            _buildQuestionCard(context, "Is there at least one pre-school in this community?", "q5"),
            _buildQuestionCard(context, "Is there at least one primary school in this community?", "q6"),
            _buildQuestionCard(context, "Are there separate toilets for boys and girls in the primary school(s)?", "q7"),
            _buildQuestionCard(context, "Do(es) the primary school(s) provide food?", "q8"),
            _buildQuestionCard(context, "Do some children in the community access scholarships to attend high school?", "q9"),
            _buildQuestionCard(context, "Is there an absence of corporal punishment in the primary school(s)?", "q10"),
            const SizedBox(height: 30),

            /// Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.secondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.save),
                    label: const Text("Save"),
                    onPressed: () async {
                      await _controller.saveFormOffline(_answers);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.send),
                    label: const Text("Submit"),
                    onPressed: () async {
                      await _controller.submit(_answers);
                    },
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  /// Builds each question card with Yes/No full-width buttons
  Widget _buildQuestionCard(BuildContext context, String question, String key) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 0,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question,
              style: theme.textTheme.bodyLarge?.copyWith(
               fontFamily: GoogleFonts.poppins().fontFamily,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        final previousAnswer = _answers[key];
                        _answers[key] = "Yes";
                        // Update score only if answer changed
                        if (previousAnswer != "Yes") {
                          _controller.updateScore(key, "Yes");
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: _answers[key] == "Yes"
                            ? theme.primaryColor
                            : theme.cardColor,
                        border: Border.all(color: theme.primaryColor),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "Yes",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: _answers[key] == "Yes"
                              ? Colors.white
                              : theme.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        final previousAnswer = _answers[key];
                        _answers[key] = "No";
                        // Update score only if answer changed from Yes to No
                        if (previousAnswer == "Yes") {
                          _controller.updateScore(key, "No");
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: _answers[key] == "No"
                            ? theme.colorScheme.error
                            : theme.cardColor,
                        border: Border.all(color: theme.colorScheme.error),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "No",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: _answers[key] == "No"
                              ? Colors.white
                              : theme.colorScheme.error,
                        ),
                      ),
                    ),
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
