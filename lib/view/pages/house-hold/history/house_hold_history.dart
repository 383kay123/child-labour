import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:human_rights_monitor/controller/db/household_tables.dart';
import 'package:human_rights_monitor/controller/db/table_names.dart';
import 'package:human_rights_monitor/controller/db/db_tables/helpers/household_db_helper.dart';
import 'package:human_rights_monitor/controller/models/fullsurveymodel.dart';
import 'package:human_rights_monitor/controller/models/household_models.dart';
import 'package:human_rights_monitor/controller/models/survey_summary.dart';
import 'package:human_rights_monitor/controller/db/daos/end_of_collection_dao.dart';
import 'package:human_rights_monitor/view/pages/house-hold/components/survey_data_viewer.dart';
import 'package:human_rights_monitor/view/theme/app_theme.dart';
import 'package:intl/intl.dart';

class SurveyListPage extends StatefulWidget {
  const SurveyListPage({Key? key}) : super(key: key);

  @override
  State<SurveyListPage> createState() => _SurveyListPageState();
}

class _SurveyListPageState extends State<SurveyListPage> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final HouseholdDBHelper _dbHelper = HouseholdDBHelper.instance;
  late final EndOfCollectionDao _endOfCollectionDao;
  late TabController _tabController;
  
  List<SurveySummary> _pendingSurveys = [];
  List<SurveySummary> _completedSurveys = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    try {
      _tabController = TabController(length: 2, vsync: this);
      _endOfCollectionDao = EndOfCollectionDao(dbHelper: _dbHelper);
      _loadSurveys();
      
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
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadSurveys();
    }
  }

  Future<void> _loadSurveys() async {
  if (_hasError) {
    setState(() => _hasError = false);
  }
  
  debugPrint('🔄 [SurveyList] Starting to load surveys...');
  if (mounted) {
    setState(() => _isLoading = true);
  }
  
  try {
    debugPrint('🔍 [SurveyList] Calling _dbHelper.getAllSurveys()...');
    final allSurveys = await _dbHelper.getAllSurveys()
        .timeout(const Duration(seconds: 30), onTimeout: () {
          throw TimeoutException('Database query timed out after 30 seconds');
        });
        
    debugPrint('✅ [SurveyList] Successfully loaded ${allSurveys.length} surveys');
    
    // Separate into pending and completed surveys based on isSubmitted flag
    _pendingSurveys = allSurveys.where((survey) => !survey.isSubmitted).toList();
    _completedSurveys = allSurveys.where((survey) => survey.isSubmitted).toList();
    
    debugPrint('📋 [SurveyList] Found ${_pendingSurveys.length} pending and ${_completedSurveys.length} completed surveys');
    
    if (mounted) {
      setState(() {
        _isLoading = false;
        _hasError = false;
      });
    }
  } on TimeoutException catch (e) {
    debugPrint('⏱️ [SurveyList] Timeout while loading surveys: $e');
    if (mounted) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
    _showErrorSnackBar('Request timed out. Please check your connection and try again.');
  } catch (e, stackTrace) {
    debugPrint('❌ [SurveyList] Error loading surveys: $e');
    debugPrint('📜 Stack trace: $stackTrace');
    
    if (mounted) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
    
    _showErrorSnackBar('Failed to load surveys. Please try again.');
  }
}

void _showErrorSnackBar(String message) {
  if (!mounted) return;
  
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
      action: SnackBarAction(
        label: 'Retry',
        textColor: Colors.white,
        onPressed: _loadSurveys,
      ),
    ),
  );
}
  @override
  Widget build(BuildContext context) {
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
                  Text('Completed'),
                  if (_completedSurveys.isNotEmpty) ...[
                    SizedBox(width: 6),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _completedSurveys.length.toString(),
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
              controller: _tabController,
              children: [
                _buildSurveyList(_pendingSurveys, false),
                _buildSurveyList(_completedSurveys, true),
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

  Widget _buildSurveyList(List<SurveySummary> surveys, bool isCompleted) {
    if (surveys.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isCompleted ? Icons.assignment_turned_in : Icons.assignment_outlined,
              size: 64,
              color: Colors.grey[300],
            ),
            SizedBox(height: 16),
            Text(
              isCompleted ? 'No completed surveys' : 'No pending surveys',
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
          return _buildSurveyCard(surveys[index], isCompleted);
        },
      ),
    );
  }

  Widget _buildSurveyCard(SurveySummary survey, bool isCompleted) {
    DateTime createdAt = survey.submissionDate;
    String farmerName = survey.farmerName.isNotEmpty 
        ? survey.farmerName 
        : 'Survey #${survey.id ?? 'N/A'}';
    int score = _calculateSurveyScore(survey);

    return GestureDetector(
      onTap: isCompleted ? () async {
        if (survey.id != null) {
          final fullSurvey = await _dbHelper.getFullSurvey(survey.id!);
          if (fullSurvey != null && mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SurveyDataViewer(surveyData: fullSurvey),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Error loading survey data'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } : null,
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
                color: isCompleted ? Colors.green[50] : Colors.orange[50],
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
                      color: isCompleted ? Colors.green : Colors.orange,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isCompleted ? 'COMPLETED' : 'DRAFT',
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
                        Icons.location_on, 
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
                  if (!isCompleted)
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _continueSurvey(survey),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Submit',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
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
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Delete',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
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
    try {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      final fullSurvey = await _dbHelper.getFullSurvey(survey.id!);
      
      if (mounted) {
        Navigator.of(context).pop();
        
        if (fullSurvey != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SurveyDataViewer(surveyData: fullSurvey),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to load survey data. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteSurvey(SurveySummary survey) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Survey', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text(
          'Are you sure you want to delete this survey? This action cannot be undone.',
          style: GoogleFonts.poppins(),
        ),
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
        final deletedCount = await _dbHelper.deleteSurvey(survey.id!);
        
        if (mounted) {
          if (deletedCount > 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Survey deleted successfully'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
            _loadSurveys();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No survey found to delete'),
                backgroundColor: Colors.orange,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
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
}