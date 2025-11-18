import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:human_rights_monitor/controller/db/table_names.dart';
import 'package:human_rights_monitor/controller/db/db_tables/helpers/household_db_helper.dart';
import 'package:human_rights_monitor/controller/models/fullsurveymodel.dart';
import 'package:human_rights_monitor/controller/models/survey_summary.dart';
import 'package:human_rights_monitor/controller/db/daos/end_of_collection_dao.dart';
import 'package:human_rights_monitor/view/theme/app_theme.dart';
import 'package:intl/intl.dart';

// Import the survey data viewer if it exists, otherwise we'll create a placeholder
// import 'package:human_rights_monitor/view/pages/house-hold/history/survey_data_viewer.dart';

// Placeholder for SurveyDataViewer if it doesn't exist
class SurveyDataViewer extends StatelessWidget {
  final dynamic surveyData;
  
  const SurveyDataViewer({Key? key, required this.surveyData}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Survey Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Survey Details: ${surveyData.toString()}',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}

class SurveyListPage extends StatefulWidget {
  const SurveyListPage({Key? key}) : super(key: key);

  @override
  State<SurveyListPage> createState() => _SurveyListPageState();
}

class _SurveyListPageState extends State<SurveyListPage> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final HouseholdDBHelper _dbHelper = HouseholdDBHelper.instance;
  late final EndOfCollectionDao _endOfCollectionDao;
  TabController? _tabController; // Make nullable to handle initialization errors
  
  List<SurveySummary> _allSurveys = [];
  List<SurveySummary> _pendingSurveys = [];
  List<SurveySummary> _submittedSurveys = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    try {
      _tabController = TabController(length: 2, vsync: this);
      _endOfCollectionDao = EndOfCollectionDao(dbHelper: _dbHelper);
      _loadSurveys();
      
      // Add observer to detect when the page becomes visible again
      WidgetsBinding.instance.addObserver(this);
    } catch (e) {
      debugPrint('❌ Error initializing SurveyListPage: $e');
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Page became visible again, refresh the list
      _loadSurveys();
    }
  }

  Future<void> _loadSurveys() async {
    if (_hasError) return;
    
    print('🔄 [SurveyList] Starting to load surveys...');
    setState(() => _isLoading = true);
    try {
      print('🔍 [SurveyList] Calling _dbHelper.getAllSurveys()...');
      final allSurveys = await _dbHelper.getAllSurveys();
      print('✅ [SurveyList] Successfully loaded ${allSurveys.length} surveys');
      
      if (allSurveys.isEmpty) {
        print('ℹ️ [SurveyList] No surveys found in the database');
      } else {
        print('📋 [SurveyList] First survey details:');
        print('   - ID: ${allSurveys.first.id}');
        print('   - Name: ${allSurveys.first.farmerName}');
        print('   - Date: ${allSurveys.first.submissionDate}');
        print('   - Has cover data: ${allSurveys.first.hasCoverData}');
      }
      
      // Categorize surveys based on completion status
      final pending = allSurveys.where((survey) => !_isSurveyComplete(survey)).toList();
      final submitted = allSurveys.where((survey) => _isSurveyComplete(survey)).toList();
      
      setState(() {
        _allSurveys = allSurveys;
        _pendingSurveys = pending;
        _submittedSurveys = submitted;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      print('❌ [SurveyList] Error loading surveys: $e');
      print('📜 Stack trace: $stackTrace');
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  bool _isSurveyComplete(SurveySummary survey) {
    // A survey is considered complete if it has data in critical tables
    return survey.hasFarmerData && 
           survey.hasConsentData && 
           survey.hasCoverData &&
           survey.hasEndOfCollectionData;
  }

  @override
  Widget build(BuildContext context) {
    // If there was an error during initialization, show error UI
    if (_hasError) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Survey History',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          backgroundColor: AppTheme.primaryColor,
          elevation: 0,
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.shade400,
              ),
              SizedBox(height: 16),
              Text(
                'Error Loading Surveys',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'There was a problem initializing the survey list.',
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _hasError = false;
                    _isLoading = true;
                  });
                  _loadSurveys();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                ),
                child: Text(
                  'Try Again',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // If tab controller is null, show loading state
    if (_tabController == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Survey History',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          backgroundColor: AppTheme.primaryColor,
          elevation: 0,
          centerTitle: true,
        ),
        body: _buildLoadingState(),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Survey History',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Pending'),
                  if (_pendingSurveys.isNotEmpty) ...[
                    SizedBox(width: 6),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _pendingSurveys.length.toString(),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Submitted'),
                  if (_submittedSurveys.isNotEmpty) ...[
                    SizedBox(width: 6),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _submittedSurveys.length.toString(),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? _buildLoadingState()
          : TabBarView(
              controller: _tabController!,
              children: [
                _buildSurveyList(_pendingSurveys, false),
                _buildSurveyList(_submittedSurveys, true),
              ],
            ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          ),
          SizedBox(height: 16),
          Text(
            'Loading surveys...',
            style: GoogleFonts.poppins(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSurveyList(List<SurveySummary> surveys, bool isSubmitted) {
    if (surveys.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSubmitted ? Icons.assignment_turned_in : Icons.assignment_outlined,
              size: 64,
              color: Colors.grey[300],
            ),
            SizedBox(height: 16),
            Text(
              isSubmitted ? 'No submitted surveys' : 'No pending surveys',
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSurveys,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: surveys.length,
        itemBuilder: (context, index) {
          return _buildSurveyCard(surveys[index], isSubmitted);
        },
      ),
    );
  }

  Widget _buildSurveyCard(SurveySummary survey, bool isSubmitted) {
    DateTime createdAt = survey.submissionDate;
    String farmerName = survey.farmerName.isNotEmpty 
        ? survey.farmerName 
        : 'Survey #${survey.id ?? 'N/A'}';
    int score = _calculateSurveyScore(survey);

    return GestureDetector(
      onTap: () async {
        if (survey.id != null) {
          final fullSurvey = await _loadCompleteSurveyData(survey.id!);
          if (fullSurvey != null && mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SurveyDataViewer(surveyData: fullSurvey),
              ),
            );
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header with status and date
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSubmitted ? Colors.green[50] : Colors.orange[50],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSubmitted ? Colors.green : Colors.orange,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isSubmitted ? 'SUBMITTED' : 'DRAFT',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Spacer(),
                  Text(
                    DateFormat('MMM d, y').format(createdAt),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            
            // Main content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and basic info
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              farmerName,
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'ID: ${survey.id ?? 'N/A'}',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Progress circle
                      Container(
                        width: 40,
                        height: 40,
                        child: Stack(
                          children: [
                            CircularProgressIndicator(
                              value: score / 100,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(_getScoreColor(score)),
                              strokeWidth: 4,
                            ),
                            Center(
                              child: Text(
                                '$score%',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: _getScoreColor(score),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 12),
                  
                  // Additional details
                  Row(
                    children: [
                      _buildDetailChip(
                        Icons.person, 
                        survey.community.isNotEmpty ? survey.community : 'No community'
                      ),
                      SizedBox(width: 8),
                      _buildDetailChip(
                        Icons.credit_card,
                        survey.ghanaCardNumber.isNotEmpty && survey.ghanaCardNumber != 'N/A' 
                            ? 'Ghana Card' 
                            : 'No Ghana Card'
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 12),
                  
                  // Sync status and contact info
                  Row(
                    children: [
                      Icon(
                        survey.isSynced ? Icons.cloud_done : Icons.cloud_upload,
                        size: 16,
                        color: survey.isSynced ? Colors.green : Colors.orange,
                      ),
                      SizedBox(width: 4),
                      Text(
                        survey.isSynced ? 'Synced' : 'Pending Sync',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: survey.isSynced ? Colors.green.shade700 : Colors.orange.shade700,
                        ),
                      ),
                      Spacer(),
                      if (survey.contactNumber.isNotEmpty)
                        _buildDetailChip(
                          Icons.phone,
                          survey.contactNumber
                        ),
                    ],
                  ),
                  
                  SizedBox(height: 12),
                  
                  // Action buttons for pending surveys
                  if (!isSubmitted)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _continueSurvey(survey),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.primaryColor,
                              side: BorderSide(color: AppTheme.primaryColor),
                              padding: EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Continue',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _deleteSurvey(survey),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: BorderSide(color: Colors.red),
                              padding: EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Delete',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey[600]),
          SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  int _calculateSurveyScore(SurveySummary survey) {
    int score = 0;
    
    // Calculate score based on available data
    if (survey.hasCoverData) score += 15;
    if (survey.hasConsentData) score += 15;
    if (survey.hasFarmerData) score += 20;
    if (survey.hasCombinedData) score += 10;
    // if (survey.hasChildrenData) score += 10;
    if (survey.hasRemediationData) score += 10;
    if (survey.hasSensitizationData) score += 10;
    if (survey.hasSensitizationQuestionsData) score += 5;
    if (survey.hasEndOfCollectionData) score += 5;
    
    return score.clamp(0, 100);
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  Future<void> _continueSurvey(SurveySummary survey) async {
    // TODO: Implement navigation to continue the survey
    // This would navigate back to the survey form with the existing data
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Continue survey: ${survey.farmerName}'),
          backgroundColor: AppTheme.primaryColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _deleteSurvey(SurveySummary survey) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Survey', style: GoogleFonts.poppins()),
        content: Text('Are you sure you want to delete this survey? This action cannot be undone.', 
          style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Delete', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // TODO: Implement delete functionality
        // await _dbHelper.deleteSurvey(survey.id!);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Survey deleted successfully'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          _loadSurveys();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting survey: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  Future<FullSurveyModel?> _loadCompleteSurveyData(int coverPageId) async {
    final db = await _dbHelper.database;
    final Map<String, dynamic> rawData = {};

    try {
      // 1. Cover Page
      final cover = await db.query(TableNames.coverPageTBL, where: 'id = ?', whereArgs: [coverPageId]);
      if (cover.isEmpty) return null;
      rawData['cover_page'] = cover.first;

      // 2. Consent
      final consent = await db.query(TableNames.consentTBL, where: 'coverPageId = ?', whereArgs: [coverPageId]);
      if (consent.isNotEmpty) rawData['consent'] = consent.first;

      // 3. Farmer Identification
      final farmer = await db.query(TableNames.farmerIdentificationTBL, where: 'coverPageId = ?', whereArgs: [coverPageId]);
      final farmerId = farmer.isNotEmpty ? farmer.first['id'] as int : null;
      if (farmer.isNotEmpty) rawData['farmer_identification'] = farmer.first;

      // 4. Combined Farm
      final combined = await db.query(TableNames.combinedFarmIdentificationTBL, where: 'coverPageId = ?', whereArgs: [coverPageId]);
      if (combined.isNotEmpty) rawData['combined_farm'] = combined.first;

      // 5. Children Household
      final children = await db.query(TableNames.childrenHouseholdTBL, where: 'farmerId = ?', whereArgs: [farmerId]);
      if (children.isNotEmpty) rawData['children_household'] = children.first;

      // 6. Remediation
      final remediation = await db.query(TableNames.remediationTBL, where: 'farm_identification_id = ?', whereArgs: [farmerId]);
      if (remediation.isNotEmpty) rawData['remediation'] = remediation.first;

      // 7. Sensitization
      final sensitization = await db.query(TableNames.sensitizationTBL, where: 'farm_identification_id = ?', whereArgs: [farmerId]);
      if (sensitization.isNotEmpty) rawData['sensitization'] = sensitization.first;

      // 8. Sensitization Questions
      final questions = await db.query(TableNames.sensitizationQuestionsTBL, where: 'farm_identification_id = ?', whereArgs: [farmerId]);
      rawData['sensitization_questions'] = questions;

      // 9. End of Collection
      if (farmerId != null) {
        final end = await _endOfCollectionDao.getByFarmIdentificationId(farmerId);
        if (end != null) rawData['end_of_collection'] = end;
      }

      rawData['created_at'] = rawData['cover_page']?['createdAt'] ?? rawData['farmer_identification']?['createdAt'];
      rawData['id'] = coverPageId;

      return FullSurveyModel.fromMap(rawData);
    } catch (e) {
      debugPrint('Error loading full survey: $e');
      return null;
    }
  }
}