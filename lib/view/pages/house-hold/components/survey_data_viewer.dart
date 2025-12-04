import 'dart:io';

import 'package:flutter/material.dart';
import 'package:human_rights_monitor/controller/db/db.dart';
import 'package:human_rights_monitor/controller/db/db_tables/repositories/child_details.dart';
import 'package:human_rights_monitor/controller/models/chilld_details_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:human_rights_monitor/controller/models/dropdown_item_model.dart';
import 'package:human_rights_monitor/controller/models/fullsurveymodel.dart';
import 'package:human_rights_monitor/controller/models/combinefarmer.dart/adult_info_model.dart';
import 'package:human_rights_monitor/controller/models/combinefarmer.dart/identification_of_owner_model.dart';
import 'package:human_rights_monitor/controller/models/combinefarmer.dart/visit_information_model.dart';
import 'package:human_rights_monitor/controller/models/combinefarmer.dart/workers_in_farm_model.dart';
import 'package:human_rights_monitor/controller/models/household_models.dart';
import 'package:human_rights_monitor/view/theme/app_theme.dart';

extension StringCasingExtension on String {
  String toTitleCase() {
    return toLowerCase().split(' ').map((word) {
      if (word.isEmpty) return '';
      return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
    }).join(' ');
  }
}

class SurveyDataViewer extends StatefulWidget {
  final FullSurveyModel surveyData;
  
  const SurveyDataViewer({Key? key, required this.surveyData}) : super(key: key);

  @override
  State<SurveyDataViewer> createState() => _SurveyDataViewerState();
}

class _SurveyDataViewerState extends State<SurveyDataViewer> {
  int _selectedSection = 0;
  final ScrollController _scrollController = ScrollController();
  bool _isRefreshing = false;

  final List<Map<String, dynamic>> _sections = [
  {
    'title': 'Cover Page',
    'icon': Icons.description_outlined,
    'color': AppTheme.primaryColor,
  },
  {
    'title': 'Consent',
    'icon': Icons.assignment_outlined,
    'color': AppTheme.secondaryColor,
  },
  {
    'title': 'Farmer ID',
    'icon': Icons.perm_identity_outlined,
    'color': AppTheme.accentColor,
  },
  {
    'title': 'Farm Information',
    'icon': Icons.agriculture_outlined,
    'color': Colors.teal,
  },
  {
    'title': 'Children',
    'icon': Icons.child_care_outlined,
    'color': Colors.amber,
  },
  {
    'title': 'Remediation',
    'icon': Icons.health_and_safety_outlined,
    'color': Colors.red,
  },
  {
    'title': 'Sensitization',
    'icon': Icons.psychology_outlined,
    'color': Colors.deepPurple,
  },
  {
    'title': 'End of Collection',
    'icon': Icons.assignment_turned_in_outlined,
    'color': Colors.green,
  },
];

  Future<void> _refreshData() async {
    if (_isRefreshing) return;
    
    setState(() {
      _isRefreshing = true;
    });

    try {
      await Future.delayed(const Duration(seconds: 1));
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('Survey data refreshed'),
            ],
          ),
          backgroundColor: AppTheme.primaryColor,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.fixed,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('Failed to refresh data'),
            ],
          ),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.fixed,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isRefreshing) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              ),
              SizedBox(height: 16),
              Text(
                'Refreshing Survey Data',
                style: AppTheme.textTheme.titleMedium,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 768) {
                  return _buildDesktopLayout();
                } else {
                  return _buildMobileLayout();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final currentSection = _sections[_selectedSection];
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.arrow_back, color: AppTheme.textPrimary),
                  iconSize: 24,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Survey Data',
                        style: AppTheme.textTheme.displayMedium,
                      ),
                      SizedBox(height: 2),
                      Text(
                        'View collected survey information',
                        style: AppTheme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.refresh, color: AppTheme.primaryColor),
                  onPressed: _refreshData,
                ),
              ],
            ),
            SizedBox(height: 12),
            _buildProgressIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    final hasData = _getCurrentSectionData() != null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: hasData ? AppTheme.primaryColor.withOpacity(0.1) : Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: hasData ? AppTheme.primaryColor : Colors.amber,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 6),
          Text(
            hasData ? 'Data Available' : 'No Data',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: hasData ? AppTheme.primaryColor : Colors.amber.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final completedSections = _sections.where((section) {
      final index = _sections.indexOf(section);
      return _getSectionData(index) != null;
    }).length;

    final progress = completedSections / _sections.length;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Survey Progress',
              style: AppTheme.textTheme.bodyLarge,
            ),
            Text(
              '${(progress * 100).round()}%',
              style: AppTheme.textTheme.titleMedium,
            ),
          ],
        ),
        SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey.shade300,
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
        SizedBox(height: 4),
        Text(
          '$completedSections of ${_sections.length} sections completed',
          style: AppTheme.textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        Container(
          width: 90,
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            border: Border(
              right: BorderSide(
                color: Colors.grey.shade300,
                width: 1,
              ),
            ),
          ),
          child: ListView(
            children: [
              SizedBox(height: 8),
              ..._sections.asMap().entries.map((entry) {
                final index = entry.key;
                final section = entry.value;
                final isSelected = _selectedSection == index;
                final hasData = _getSectionData(index) != null;
                
                return _buildDesktopNavItem(
                  section: section,
                  index: index,
                  isSelected: isSelected,
                  hasData: hasData,
                );
              }),
            ],
          ),
        ),
        Expanded(
          child: _buildContentArea(),
        ),
      ],
    );
  }

  Widget _buildDesktopNavItem({
    required Map<String, dynamic> section,
    required int index,
    required bool isSelected,
    required bool hasData,
  }) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedSection = index;
            });
            _scrollController.animateTo(
              0,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? section['color'].withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: isSelected 
                  ? Border.all(
                      color: section['color'].withOpacity(0.3),
                      width: 1,
                    )
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    Icon(
                      section['icon'],
                      color: isSelected ? section['color'] : AppTheme.textSecondary,
                      size: 20,
                    ),
                    if (hasData && !isSelected) ...[
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 6),
                Text(
                  section['title'],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? section['color'] : AppTheme.textSecondary,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        Container(
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.shade300,
                width: 1,
              ),
            ),
          ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _sections.length,
            itemBuilder: (context, index) {
              final section = _sections[index];
              final isSelected = _selectedSection == index;
              final hasData = _getSectionData(index) != null;
              
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _buildMobileNavItem(
                  section: section,
                  index: index,
                  isSelected: isSelected,
                  hasData: hasData,
                ),
              );
            },
          ),
        ),
        Expanded(
          child: _buildContentArea(),
        ),
      ],
    );
  }

  Widget _buildMobileNavItem({
    required Map<String, dynamic> section,
    required int index,
    required bool isSelected,
    required bool hasData,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedSection = index;
          });
          _scrollController.animateTo(
            0,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? section['color'].withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? section['color'].withOpacity(0.3) : Colors.grey.shade300,
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  Icon(
                    section['icon'],
                    color: isSelected ? section['color'] : AppTheme.textSecondary,
                    size: 18,
                  ),
                  if (hasData && !isSelected) ...[
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(height: 4),
              Text(
                section['title'],
                style: GoogleFonts.poppins(
                  fontSize: 9,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? section['color'] : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentArea() {
    final currentSection = _sections[_selectedSection];
    final sectionData = _getCurrentSectionData();

    return Container(
      color: AppTheme.backgroundColor,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  currentSection['icon'],
                  color: currentSection['color'],
                  size: 24,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentSection['title'],
                        style: AppTheme.textTheme.titleLarge,
                      ),
                      SizedBox(height: 2),
                      Text(
                        sectionData != null 
                            ? 'Complete data overview'
                            : 'Section not completed',
                        style: AppTheme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                if (sectionData != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, size: 14, color: AppTheme.primaryColor),
                        SizedBox(width: 4),
                        Text(
                          'Complete',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.pending, size: 14, color: Colors.grey.shade600),
                        SizedBox(width: 4),
                        Text(
                          'Pending',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: sectionData != null 
                ? _buildSectionContent()
                : _buildEmptyState(currentSection['color']),
          ),
        ],
      ),
    );
  }

 Widget _buildSectionContent() {
  debugPrint('Building section: ${_sections[_selectedSection]['title']}');
  
  try {
    switch (_selectedSection) {
      case 0:
        if (widget.surveyData.cover == null) {
          return _buildErrorCard('Cover Page', 'No cover page data available');
        }
        return _buildCoverPageContent();
        
      case 1:
        if (widget.surveyData.consent == null) {
          return _buildErrorCard('Consent', 'No consent data available');
        }
        return _buildConsentContent();
        
      case 2:
        if (widget.surveyData.farmer == null) {
          return _buildErrorCard('Farmer Identification', 'No farmer identification data available');
        }
        return _buildFarmerIdentificationContent();
        
      case 3:
        if (widget.surveyData.combinedFarm == null) {
          return _buildErrorCard('Farm Information', 'No farm information available');
        }
        return _buildFarmInformationContent();
        
      case 4:
        if (widget.surveyData.childrenHousehold == null) {
          return _buildErrorCard('Children', 'No children data available');
        }
        return _buildChildrenContent();
        
      case 5:
        if (widget.surveyData.remediation == null) {
          return _buildErrorCard('Remediation', 'No remediation data available');
        }
        return _buildRemediationContent();
        
     case 6: {
  final hasSensitization = widget.surveyData.sensitization != null;
  final hasQuestions = widget.surveyData.sensitizationQuestions?.isNotEmpty == true;
  
  debugPrint('🔍 [SurveyViewer] Sensitization check - hasSensitization: $hasSensitization, hasQuestions: $hasQuestions');
  debugPrint('🔍 [SurveyViewer] Sensitization data: ${widget.surveyData.sensitization?.toMap()}');
  debugPrint('🔍 [SurveyViewer] Questions count: ${widget.surveyData.sensitizationQuestions?.length ?? 0}');
  
  // Always try to show the content if we have either sensitization data or questions
  if (hasSensitization || hasQuestions) {
    return _buildSensitizationContent();
  }
  
  // Only show "not completed" if we have neither
  return _buildInfoCard(
    'Sensitization', 
    'This section was not completed during the survey.\n\nSensitization data is optional and may not be collected for all surveys.',
    icon: Icons.info_outline,
    color: Colors.blue,
  );
}

        
      case 7: // NEW SECTION
        if (widget.surveyData.endOfCollection == null) {
          return _buildErrorCard('End of Collection', 'No end of collection data available');
        }
        return _buildEndOfCollectionContent();
        
      default:
        return _buildEmptyState(_sections[_selectedSection]['color']);
    }
  } catch (e, stackTrace) {
    debugPrint('Error building section ${_sections[_selectedSection]['title']}: $e');
    return _buildErrorCard(
      'Error', 
      'Failed to load ${_sections[_selectedSection]['title']} data.',
    );
  }
}
  
  Widget _buildErrorCard(String title, String message) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.errorColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.errorColor.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.error_outline, color: AppTheme.errorColor, size: 20),
                SizedBox(width: 8),
                Text(
                  title,
                  style: AppTheme.textTheme.titleLarge?.copyWith(color: AppTheme.errorColor),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              message,
              style: AppTheme.textTheme.bodyLarge,
            ),
            SizedBox(height: 8),
            Text(
              'Survey ID: ${widget.surveyData.surveyId}',
              style: AppTheme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(Color color) {
    final currentSection = _sections[_selectedSection];
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              currentSection['icon'],
              size: 48,
              color: color.withOpacity(0.3),
            ),
            SizedBox(height: 16),
            Text(
              'No Data Available',
              style: AppTheme.textTheme.titleLarge,
            ),
            SizedBox(height: 8),
            Text(
              'This section has not been completed or data is not available.',
              textAlign: TextAlign.center,
              style: AppTheme.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverPageContent() {
    final cover = widget.surveyData.cover;
    final townName = _getTownName(cover.selectedTownCode, cover.towns);
    final farmerName = _getFarmerName(cover.selectedFarmerCode, cover.farmers);
    
    return _buildScrollableContent([
      _buildContentCard(
        title: 'Basic Information',
        items: {
          'Database ID': cover.id?.toString() ?? 'Not set',
          'Selected Town': townName,
          'Selected Farmer': farmerName,
        },
      ),
      if (cover.member != null) 
        _buildContentCard(
          title: 'Member Information',
          items: Map<String, String>.from(cover.member!),
        ),
    ]);
  }

  Widget _buildConsentContent() {
    final consent = widget.surveyData.consent;
    
    if (consent == null) {
      return _buildEmptyState(_sections[1]['color']);
    }
    
    return _buildScrollableContent([
      _buildContentCard(
        title: 'Consent Details',
        items: {
          'Database ID': consent.id?.toString() ?? 'Not set',
          'Community Type': consent.communityType ?? 'Not specified',
          'Resides in Community': consent.residesInCommunityConsent ?? 'Not specified',
          'Farmer Available': consent.farmerAvailable ?? 'Not specified',
          'Consent Given': _boolToYesNo(consent.consentGiven),
         'Consent Timestamp': _formatDateTime(consent.consentTimestamp) ?? 'Not specified',
        },
      ),
    ]);
  }

  Widget _buildFarmerIdentificationContent() {
    final farmer = widget.surveyData.farmer;
    
    if (farmer == null) {
      return _buildScrollableContent([
        _buildContentCard(
          title: 'Farmer Identification',
          items: {
            'Status': 'No farmer identification data available',
          },
        ),
      ]);
    }
    
    return _buildScrollableContent([
      _buildContentCard(
        title: 'Identification Details',
        items: {
          'Has Ghana Card': _intToYesNo(farmer.hasGhanaCard),
          'Ghana Card Number': farmer.ghanaCardNumber ?? 'Not provided',
          'Selected ID Type': farmer.selectedIdType ?? 'Not selected',
          'ID Number': farmer.idNumber ?? 'Not provided',
          'Contact Number': farmer.contactNumber ?? 'Not provided',
          'Children Count': farmer.childrenCount.toString(),
        },
      ),
    ]);
  }

Widget _buildFarmInformationContent() {
  final combinedFarm = widget.surveyData.combinedFarm;
  
  debugPrint('🔍 [SurveyViewer] Building Farm Information Content');
  debugPrint('🔍 [SurveyViewer] Combined Farm Data: ${combinedFarm != null ? "Available" : "Null"}');
  
  if (combinedFarm == null) {
    return _buildErrorCard(
      'Farm Information', 
      'No farm information data is available. This section may not have been completed.'
    );
  }
  
  try {
    final visitInfo = combinedFarm.visitInformation;
    final ownerInfo = combinedFarm.ownerInformation;
    final workersInfo = combinedFarm.workersInFarm;
    final adultsInfo = combinedFarm.adultsInformation;
    
    List<Widget> content = [];
    
    // Basic Info Card
    content.add(_buildContentCard(
      title: 'Farm Information Overview',
      items: {
        'Database ID': combinedFarm.id?.toString() ?? 'Not set',
        'Cover Page ID': combinedFarm.coverPageId?.toString() ?? 'Not set',
        'Created': _formatDateTime(combinedFarm.createdAt) ?? 'Not available',
        'Last Updated': _formatDateTime(combinedFarm.updatedAt) ?? 'Not available',
      },
    ));
    
    // Visit Information
    if (visitInfo != null) {
      final visitItems = <String, String>{};
      
      // Name verification
      if (visitInfo.respondentNameCorrect != null) {
        visitItems['Respondent Name Correct'] = visitInfo.respondentNameCorrect! ? 'Yes' : 'No';
        if (!visitInfo.respondentNameCorrect! && visitInfo.correctedRespondentName != null) {
          visitItems['Corrected Name'] = visitInfo.correctedRespondentName!;
          if (visitInfo.respondentOtherNames != null) {
            visitItems['Other Names'] = visitInfo.respondentOtherNames!;
          }
        }
      }
      
      // Nationality
      if (visitInfo.respondentNationality != null) {
        visitItems['Nationality'] = visitInfo.respondentNationality!;
        if (visitInfo.respondentNationality == 'Non-Ghanaian') {
          if (visitInfo.countryOfOrigin != null) {
            visitItems['Country of Origin'] = visitInfo.countryOfOrigin!;
            if (visitInfo.countryOfOrigin == 'Other' && visitInfo.otherCountry != null) {
              visitItems['Other Country'] = visitInfo.otherCountry!;
            }
          }
        }
      }
      
      // Farm ownership
      if (visitInfo.isFarmOwner != null) {
        visitItems['Is Farm Owner'] = visitInfo.isFarmOwner! ? 'Yes' : 'No';
        if (visitInfo.farmOwnershipType != null) {
          visitItems['Ownership Type'] = visitInfo.farmOwnershipType!;
        }
      }
      
      // Location data
      if (visitInfo.location != null) {
        visitItems['Location'] = visitInfo.location!;
      }
      if (visitInfo.gpsCoordinates != null) {
        visitItems['GPS Coordinates'] = visitInfo.gpsCoordinates!;
      }
      
      if (visitItems.isNotEmpty) {
        content.add(_buildContentCard(
          title: 'Visit Information',
          items: visitItems,
        ));
      }
    }
    
    // Owner Information
    if (ownerInfo != null) {
      final ownerItems = <String, String>{};
      
      if (ownerInfo.ownerName.isNotEmpty) {
        ownerItems['Owner Name'] = ownerInfo.ownerName;
      }
      if (ownerInfo.ownerFirstName.isNotEmpty) {
        ownerItems['Owner First Name'] = ownerInfo.ownerFirstName;
      }
      if (ownerInfo.nationality != null) {
        ownerItems['Nationality'] = ownerInfo.nationality == 'Non-Ghanaian' 
            ? 'Non-Ghanaian' 
            : 'Ghanaian';
        
        if (ownerInfo.nationality == 'Non-Ghanaian' && ownerInfo.specificNationality != null) {
          ownerItems['Country'] = ownerInfo.specificNationality!;
          if (ownerInfo.specificNationality == 'other' && ownerInfo.otherNationality.isNotEmpty) {
            ownerItems['Other Country'] = ownerInfo.otherNationality;
          }
        }
      }
      if (ownerInfo.yearsWithOwner.isNotEmpty) {
        ownerItems['Years with Owner'] = '${ownerInfo.yearsWithOwner} years';
      }
      
      if (ownerItems.isNotEmpty) {
        content.add(_buildContentCard(
          title: 'Owner Information',
          items: ownerItems,
        ));
      }
    }
    
    // Workers Information
    if (workersInfo != null) {
      final workersItems = <String, String>{};
      
      if (workersInfo.hasRecruitedWorker != null) {
        workersItems['Recruited Workers (Past Year)'] = workersInfo.hasRecruitedWorker == '1' ? 'Yes' : 'No';
        
        if (workersInfo.hasRecruitedWorker == '1') {
          // Labor types
          final laborTypes = <String>[];
          if (workersInfo.permanentLabor) laborTypes.add('Permanent');
          if (workersInfo.casualLabor) laborTypes.add('Casual');
          if (laborTypes.isNotEmpty) {
            workersItems['Labor Types'] = laborTypes.join(', ');
          }
          
          // Agreement type
          if (workersInfo.workerAgreementType != null) {
            workersItems['Agreement Type'] = workersInfo.workerAgreementType!;
            if (workersInfo.workerAgreementType == 'Other (specify)' && workersInfo.otherAgreement.isNotEmpty) {
              workersItems['Other Agreement'] = workersInfo.otherAgreement;
            }
          }
          
          // Other worker-related fields
          if (workersInfo.tasksClarified != null) {
            workersItems['Tasks Clarified'] = workersInfo.tasksClarified!;
          }
          if (workersInfo.additionalTasks != null) {
            workersItems['Additional Tasks'] = workersInfo.additionalTasks!;
          }
          if (workersInfo.refusalAction != null) {
            workersItems['Refusal Action'] = workersInfo.refusalAction!;
          }
          if (workersInfo.salaryPaymentFrequency != null) {
            workersItems['Salary Payment'] = workersInfo.salaryPaymentFrequency!;
          }
        } else if (workersInfo.everRecruitedWorker != null) {
          workersItems['Ever Recruited Before'] = workersInfo.everRecruitedWorker!;
        }
      }
      
      if (workersItems.isNotEmpty) {
        content.add(_buildContentCard(
          title: 'Workers Information',
          items: workersItems,
        ));
      }
      
      // Agreement responses
      if (workersInfo.agreementResponses.isNotEmpty) {
        final agreementItems = <String, String>{};
        workersInfo.agreementResponses.forEach((key, value) {
          if (value != null) {
            agreementItems[_formatAgreementKey(key)] = value;
          }
        });
        
        if (agreementItems.isNotEmpty) {
          content.add(_buildContentCard(
            title: 'Worker Agreement Responses',
            items: agreementItems,
          ));
        }
      }
    }
    
    // Adults Information
    if (adultsInfo != null) {
      if (adultsInfo.numberOfAdults != null && adultsInfo.numberOfAdults! > 0) {
        content.add(_buildContentCard(
          title: 'Household Adults (${adultsInfo.numberOfAdults})',
          items: {
            'Total Adults': adultsInfo.numberOfAdults.toString(),
          },
        ));
        
        // Display each household member
        if (adultsInfo.members.isNotEmpty) {
          for (int i = 0; i < adultsInfo.members.length; i++) {
            final member = adultsInfo.members[i];
            final details = member.producerDetails;
            
            final memberItems = <String, String>{};
            memberItems['Name'] = member.name.isNotEmpty ? member.name : 'Unnamed Member ${i + 1}';
            
            if (details != null) {
              if (details.gender != null) {
                memberItems['Gender'] = details.gender!;
              }
              if (details.nationality != null) {
                memberItems['Nationality'] = details.nationality == 'non_ghanaian' ? 'Non-Ghanaian' : 'Ghanaian';
                if (details.nationality == 'non_ghanaian' && details.selectedCountry != null) {
                  memberItems['Country'] = details.selectedCountry!;
                  if (details.selectedCountry == 'Other' && details.otherCountry != null) {
                    memberItems['Other Country'] = details.otherCountry!;
                  }
                }
              }
              if (details.yearOfBirth != null) {
                memberItems['Year of Birth'] = details.yearOfBirth.toString();
              }
              if (details.relationshipToRespondent != null) {
                memberItems['Relationship'] = details.relationshipToRespondent!;
                if (details.relationshipToRespondent == 'other' && details.otherRelationship != null) {
                  memberItems['Other Relationship'] = details.otherRelationship!;
                }
              }
              if (details.hasBirthCertificate != null) {
                // Handle different possible string representations of boolean values
                final birthCert = details.hasBirthCertificate!.toLowerCase();
                if (birthCert == 'true' || birthCert == '1' || birthCert == 'yes') {
                  memberItems['Birth Certificate'] = 'Yes';
                } else if (birthCert == 'false' || birthCert == '0' || birthCert == 'no') {
                  memberItems['Birth Certificate'] = 'No';
                } else {
                  // If it's some other string value, use it as is
                  memberItems['Birth Certificate'] = details.hasBirthCertificate!;
                }
              }
              if (details.occupation != null) {
                memberItems['Occupation'] = details.occupation!;
                if (details.occupation == 'other' && details.otherOccupation != null) {
                  memberItems['Other Occupation'] = details.otherOccupation!;
                }
              }
            }
            
            content.add(_buildContentCard(
              title: 'Household Member ${i + 1}',
              items: memberItems,
            ));
          }
        }
      } else {
        content.add(_buildContentCard(
          title: 'Household Adults',
          items: {'Status': 'No adult members recorded'},
        ));
      }
    }
    
    return _buildScrollableContent(content);
    
  } catch (e, stackTrace) {
    debugPrint('❌ [SurveyViewer] Error building farm information: $e');
    debugPrint('📜 Stack trace: $stackTrace');
    
    return _buildErrorCard(
      'Farm Information - Error', 
      'An error occurred while displaying farm information.\n\nError: $e',
    );
  }
}

// Helper method to format agreement keys
String _formatAgreementKey(String key) {
  final keyMap = {
    'salary_workers': 'Withhold Salary',
    'recruit_1': 'Debt Repayment Work',
    'recruit_2': 'Hide Work Nature',
    'recruit_3': 'Always Available',
    'conditions_1': 'Restrict Movement',
    'conditions_2': 'Family Communication',
    'conditions_3': 'Living Conditions',
    'conditions_4': 'Interfere Private Life',
    'conditions_5': 'Restrict Leaving',
    'leaving_1': 'Stay for Unpaid Salary',
    'leaving_2': 'Cannot Leave with Debt',
  };
  
  return keyMap[key] ?? key;
}

 Widget _buildChildrenContent() {
  final children = widget.surveyData.childrenHousehold;
  if (children == null) {
    return _buildEmptyState(_sections[4]['color']);
  }
  
  // Fetch child details from database using the household ID
  return FutureBuilder<List<ChildDetailsModel>>(
    future: _fetchChildDetails(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return _buildLoadingState();
      }
      
      if (snapshot.hasError) {
        return _buildErrorCard('Children Data', 'Error loading child details: ${snapshot.error}');
      }
      
      if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return _buildScrollableContent([
          _buildContentCard(
            title: 'Children Overview',
            items: {
              'Has Children in Household': children.hasChildrenInHousehold ?? 'Not specified',
              'Number of Children': children.numberOfChildren.toString(),
              'Children 5 to 17 Years': children.children5To17.toString(),
            },
          ),
          _buildInfoCard(
            'Child Details',
            'No detailed child information was collected for this survey.',
            icon: Icons.info_outline,
            color: Colors.blue,
          ),
        ]);
      }
      
      final childDetails = snapshot.data!;
      List<Widget> content = [];
      
      // Add overview card
      content.add(_buildContentCard(
        title: 'Children Overview',
        items: {
          'Has Children in Household': children.hasChildrenInHousehold ?? 'Not specified',
          'Number of Children': children.numberOfChildren.toString(),
          'Children 5 to 17 Years': children.children5To17.toString(),
          'Detailed Records Found': childDetails.length.toString(),
        },
      ));
      
      // Add each child's details
      for (int i = 0; i < childDetails.length; i++) {
        final child = childDetails[i];
        content.addAll(_buildChildDetailsCards(child, i + 1));
      }
      
      return _buildScrollableContent(content);
    },
  );
}

Future<List<ChildDetailsModel>> _fetchChildDetails() async {
  try {
    // Get the cover page ID from the survey data
    final coverPageId = widget.surveyData.cover.id;
    
    if (coverPageId == null) {
      debugPrint('Error: coverPageId is null');
      return [];
    }
    
    debugPrint('Using cover page ID: $coverPageId');
    debugPrint('Fetching child details for cover page ID: $coverPageId');
    
    // Initialize the database
    final dbHelper = LocalDBHelper.instance;
    await dbHelper.database; // Ensure database is initialized
    
    // Fetch child details from the database using cover page ID
    final childRepository = ChildRepositoryImpl();
    final childDetails = await childRepository.getChildrenByCoverPageId(coverPageId);
    debugPrint('Child details: ${childDetails.first.toJson()}');
    debugPrint('Found ${childDetails.length} child records for cover page ID: $coverPageId');
    return childDetails;
  } catch (e) {
    debugPrint('Error fetching child details: $e');
    return [];
  }
}

// This method should be in ChildRepositoryImpl class, not here
// The method is already properly implemented in the repository
// Remove this method from here and use the repository's method instead

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
          'Loading Child Details...',
          style: AppTheme.textTheme.bodyLarge,
        ),
      ],
    ),
  );
}

List<Widget> _buildChildDetailsCards(ChildDetailsModel child, int childNumber) {
  List<Widget> cards = [];
  
  // Child Basic Information Card
  cards.add(_buildContentCard(
    title: 'Child $childNumber: Basic Information',
    items: {
      'Database ID': child.id?.toString() ?? 'Not set',
      'Household ID': child.householdId.toString(),
      'Child Number': child.childNumber.toString(),
      'Is Farmer Child': _boolToYesNo(child.isFarmerChild),
      'Name': '${child.childName} ${child.childSurname}',
      'Gender': child.childGender ?? 'Not specified',
      'Age': child.childAge?.toString() ?? 'Not specified',
      'Birth Year': child.birthYear?.toString() ?? 'Not specified',
      'Has Birth Certificate': _boolToYesNo(child.hasBirthCertificate),
      'Born in Community': child.bornInCommunity ?? 'Not specified',
      'Birth Country': child.birthCountry ?? 'Not specified',
    },
  ));
  
  // Family Information Card
  cards.add(_buildContentCard(
    title: 'Child $childNumber: Family Information',
    items: {
      'Relationship to Head': child.relationshipToHead ?? 'Not specified',
      'Other Relationship': child.otherRelationship ?? 'Not specified',
      'Time in Household': child.timeInHousehold ?? 'Not specified',
      'Father Residence': child.fatherResidence ?? 'Not specified',
      'Father Country': child.fatherCountry ?? 'Not specified',
      'Mother Residence': child.motherResidence ?? 'Not specified',
      'Mother Country': child.motherCountry ?? 'Not specified',
      'Has Spoken with Parents': _boolToYesNo(child.hasSpokenWithParents),
      'Child Agreed with Decision': _boolToYesNo(child.childAgreedWithDecision),
    },
  ));
  
  // Education Information Card
  cards.add(_buildContentCard(
    title: 'Child $childNumber: Education Information',
    items: {
      'Currently Enrolled': _boolToYesNo(child.isCurrentlyEnrolled),
      'School Name': child.schoolName ?? 'Not specified',
      'School Type': child.schoolType ?? 'Not specified',
      'Grade Level': child.gradeLevel ?? 'Not specified',
      'Attendance Frequency': child.schoolAttendanceFrequency ?? 'Not specified',
      'Has Ever Been to School': _boolToYesNo(child.hasEverBeenToSchool),
      'Attended School Last 7 Days': _boolToYesNo(child.attendedSchoolLast7Days),
      'Can Write Sentences': child.canWriteSentences ?? 'Not specified',
      'Education Level': child.educationLevel ?? 'Not specified',
    },
  ));
  
  // Work Information Card
  cards.add(_buildContentCard(
    title: 'Child $childNumber: Work Information',
    items: {
      'Worked in House': _boolToYesNo(child.workedInHouse),
      'Worked on Cocoa Farm': _boolToYesNo(child.workedOnCocoaFarm),
      'Work Frequency': child.workFrequency ?? 'Not specified',
      'Observed Working': _boolToYesNo(child.observedWorking),
      'Received Remuneration': _boolToYesNo(child.receivedRemuneration),
      'Work For Whom': child.workForWhom ?? 'Not specified',
      'Other Work For Whom': child.otherWorkForWhom ?? 'Not specified',
    },
  ));
  
  // Cocoa Farm Tasks Card
  if (child.cocoaFarmTasks != null && child.cocoaFarmTasks!.isNotEmpty) {
    cards.add(_buildContentCard(
      title: 'Child $childNumber: Cocoa Farm Tasks (7 Days)',
      items: {
        'Tasks': child.cocoaFarmTasks!.join(', '),
      },
      isList: true,
      listItems: child.cocoaFarmTasks!,
    ));
  }
  
  // Tasks Last 12 Months Card
  if (child.tasksLast12Months != null && child.tasksLast12Months!.isNotEmpty) {
    cards.add(_buildContentCard(
      title: 'Child $childNumber: Farm Tasks (12 Months)',
      items: {
        'Tasks Count': child.tasksLast12Months!.length.toString(),
      },
      isList: true,
      listItems: child.tasksLast12Months!,
    ));
  }
  
  // Light Tasks 7 Days Card
  cards.add(_buildContentCard(
    title: 'Child $childNumber: Light Tasks (7 Days)',
    items: {
      'Received Remuneration': _boolToYesNo(child.receivedRemunerationLighttasks12months),
      'Longest School Day Time': child.longestLightDutyTimeLighttasks7days ?? 'Not specified',
      'Longest Non-School Day Time': child.longestNonSchoolDayTimeLighttasks7days ?? 'Not specified',
      'Task Location': child.taskLocationLighttasks7days ?? 'Not specified',
      'Other Location': child.otherLocationLighttasks7days ?? 'Not specified',
      'School Day Hours': child.schoolDayTaskHoursLighttasks7days ?? 'Not specified',
      'Non-School Day Hours': child.nonSchoolDayTaskHoursLighttasks7days ?? 'Not specified',
      'Was Supervised': _boolToYesNo(child.wasSupervisedByAdultLighttasks7days),
    },
  ));
  
  // Light Tasks 12 Months Card
  cards.add(_buildContentCard(
    title: 'Child $childNumber: Light Tasks (12 Months)',
    items: {
      'Received Remuneration': _boolToYesNo(child.receivedRemunerationLighttasks12months),
      'Longest School Day Time': child.longestSchoolDayTimeLighttasks12months ?? 'Not specified',
      'Longest Non-School Day Time': child.longestNonSchoolDayTimeLighttasks12months ?? 'Not specified',
      'Task Location': child.taskLocationLighttasks12months ?? 'Not specified',
      'Other Task Location': child.otherTaskLocationLighttasks12months ?? 'Not specified',
      'Total School Day Hours': child.totalSchoolDayHoursLighttasks12months ?? 'Not specified',
      'Total Non-School Day Hours': child.totalNonSchoolDayHoursLighttasks12months ?? 'Not specified',
      'Was Supervised': _boolToYesNo(child.wasSupervisedDuringTaskLighttasks12months),
    },
  ));
  
  // Dangerous Tasks 7 Days Card
  cards.add(_buildContentCard(
    title: 'Child $childNumber: Dangerous Tasks (7 Days)',
    items: {
      'Received Salary': _boolToYesNo(child.hasReceivedSalaryDangeroustask7days),
      'Task Location': child.taskLocationDangeroustask7days ?? 'Not specified',
      'Other Location': child.otherLocationDangeroustask7days ?? 'Not specified',
      'Longest School Day Time': child.longestSchoolDayTimeDangeroustask7days ?? 'Not specified',
      'Longest Non-School Day Time': child.longestNonSchoolDayTimeDangeroustask7days ?? 'Not specified',
      'School Day Hours': child.schoolDayHoursDangeroustask7days ?? 'Not specified',
      'Non-School Day Hours': child.nonSchoolDayHoursDangeroustask7days ?? 'Not specified',
      'Was Supervised': _boolToYesNo(child.wasSupervisedByAdultDangeroustask7days),
    },
  ));
  
  // Dangerous Tasks 12 Months Card
  cards.add(_buildContentCard(
    title: 'Child $childNumber: Dangerous Tasks (12 Months)',
    items: {
      'Received Salary': _boolToYesNo(child.hasReceivedSalaryDangeroustask12months),
      'Task Location': child.taskLocationDangeroustask12months ?? 'Not specified',
      'Other Location': child.otherLocationDangeroustask12months ?? 'Not specified',
      'Longest School Day Time': child.longestSchoolDayTimeDangeroustask12months ?? 'Not specified',
      'Longest Non-School Day Time': child.longestNonSchoolDayTimeDangeroustask12months ?? 'Not specified',
      'School Day Hours': child.schoolDayHoursDangeroustask12months ?? 'Not specified',
      'Non-School Day Hours': child.nonSchoolDayHoursDangeroustask12months ?? 'Not specified',
      'Was Supervised': _boolToYesNo(child.wasSupervisedByAdultDangeroustask12months),
    },
  ));
  
  // Dangerous Tasks List Card
  if (child.dangerousTasks12Months != null && child.dangerousTasks12Months!.isNotEmpty) {
    cards.add(_buildContentCard(
      title: 'Child $childNumber: Dangerous Tasks List (12 Months)',
      items: {
        'Tasks Count': child.dangerousTasks12Months!.length.toString(),
      },
      isList: true,
      listItems: child.dangerousTasks12Months!.map((task) {
        return task.replaceAll('_dangeroustask12months', '');
      }).toList(),
    ));
  }
  
  // Health and Safety Card
  cards.add(_buildContentCard(
    title: 'Child $childNumber: Health and Safety',
    items: {
      'Applied Agrochemicals': _boolToYesNo(child.appliedAgrochemicals),
      'On Farm During Application': _boolToYesNo(child.onFarmDuringApplication),
      'Suffered Injury': _boolToYesNo(child.sufferedInjury),
      'How Wounded': child.howWounded ?? 'Not specified',
      'When Wounded': child.whenWounded ?? 'Not specified',
      'Often Feel Pains': _boolToYesNo(child.oftenFeelPains),
    },
  ));
  
  // Help Received Card
  if (child.helpReceived != null && child.helpReceived!.isNotEmpty) {
    cards.add(_buildContentCard(
      title: 'Child $childNumber: Help Received',
      items: {
        'Help Types': child.helpReceived!.join(', '),
      },
      isList: true,
      listItems: child.helpReceived!,
    ));
  }
  
  // Photo Consent Card
  cards.add(_buildContentCard(
    title: 'Child $childNumber: Photo Consent',
    items: {
      'Parent Consent for Photo': _boolToYesNo(child.parentConsentPhoto),
      'No Consent Reason': child.noConsentReason ?? 'Not specified',
      'Child Photo Taken': (child.childPhotoPath?.isNotEmpty == true) ? 'Yes' : 'No',
    },
  ));
  
  // School Supplies Card
  if (child.availableSchoolSupplies != null && child.availableSchoolSupplies!.isNotEmpty) {
    cards.add(_buildContentCard(
      title: 'Child $childNumber: Available School Supplies',
      items: {
        'Supplies Count': child.availableSchoolSupplies!.length.toString(),
      },
      isList: true,
      listItems: child.availableSchoolSupplies!,
    ));
  }
  
  if (child.absenceReasons != null && child.absenceReasons!.isNotEmpty) {
  cards.add(_buildContentCard(
    title: 'Child $childNumber: School Absence Reasons',
    items: {
      'Reasons Count': child.absenceReasons!.length.toString(),
    },
    isList: true,
    listItems: child.absenceReasons!.entries
        .where((entry) => entry.value == true)
        .map((entry) => entry.key)
        .toList(),
  ));
}
  
  // Work Reasons Card
  if (child.whyWorkReasons != null && child.whyWorkReasons!.isNotEmpty) {
    cards.add(_buildContentCard(
      title: 'Child $childNumber: Why Work Reasons',
      items: {
        'Reasons Count': child.whyWorkReasons!.length.toString(),
      },
      isList: true,
      listItems: child.whyWorkReasons!,
    ));
  }
  
  // Not With Family Reasons Card
  if (child.notWithFamilyReasons != null && child.notWithFamilyReasons!.isNotEmpty) {
    cards.add(_buildContentCard(
      title: 'Child $childNumber: Not With Family Reasons',
      items: {
        'Reasons Count': child.notWithFamilyReasons!.length.toString(),
      },
      isList: true,
      listItems: child.notWithFamilyReasons!,
    ));
  }
  
  // Reasons for Various Decisions
  cards.add(_buildContentCard(
    title: 'Child $childNumber: Reasons for Decisions',
    items: {
      'Reason for Leaving School': child.reasonForLeavingSchool ?? 'Not specified',
      'Other Reason for Leaving School': child.otherReasonForLeavingSchool ?? 'Not specified',
      'Reason Never Attended School': child.reasonNeverAttendedSchool ?? 'Not specified',
      'Other Reason Never Attended': child.otherReasonNeverAttended ?? 'Not specified',
      'Reason Not Attended School': child.reasonNotAttendedSchool ?? 'Not specified',
      'Other Reason Not Attended': child.otherReasonNotAttended ?? 'Not specified',
      'Other Absence Reason': child.otherAbsenceReason ?? 'Not specified',
    },
  ));
  
  // Survey Details Card
  cards.add(_buildContentCard(
    title: 'Child $childNumber: Survey Details',
    items: {
      'Can Be Surveyed Now': _boolToYesNo(child.canBeSurveyedNow),
      'Respondent Type': child.respondentType ?? 'Not specified',
      'Other Respondent Type': child.otherRespondentType ?? 'Not specified',
    },
  ));
  
  return cards;
}
  Widget _buildRemediationContent() {
    final remediation = widget.surveyData.remediation;
    print('Remediation data: $remediation'); // Debug print
    print('Cover page ID: ${widget.surveyData.cover?.id}'); // Check cover page ID
    
    if (remediation == null) {
      print('No remediation data found for this survey'); // Debug print
      return _buildEmptyState(_sections[5]['color']);
    }
    
  return _buildScrollableContent([
  _buildContentCard(
    title: 'Support Information',
    items: {
      'Has School Fees': _boolToYesNo(remediation.hasSchoolFees),
      'Child Protection Education': _boolToYesNo(remediation.childProtectionEducation),
      'School Kits Support': _boolToYesNo(remediation.schoolKitsSupport),
      'IGA Support': _boolToYesNo(remediation.igaSupport),
      'Other Support': _boolToYesNo(remediation.otherSupport),
      if (remediation.otherSupport && remediation.otherSupportDetails != null)
        'Other Support Details': remediation.otherSupportDetails!,
      if (remediation.communityAction != null)
        'Community Action': remediation.communityAction!,
      if (remediation.communityAction == 'Other' && remediation.otherCommunityActionDetails != null)
        'Other Community Action Details': remediation.otherCommunityActionDetails!,
    },
  ),
]);
  }

  Widget _buildSensitizationContent() {
    final sensitization = widget.surveyData.sensitization;
    final questions = widget.surveyData.sensitizationQuestions;

    debugPrint('📊 [Viewer] Building sensitization content...');
    debugPrint('📊 [Viewer] Sensitization: ${sensitization?.toMap()}');
    debugPrint('📊 [Viewer] Questions count: ${questions?.length ?? 0}');
    if (questions != null && questions.isNotEmpty) {
      debugPrint('📊 [Viewer] First question: ${questions.first.toMap()}');
    }

    List<Widget> content = [];
    
    // Sensitization acknowledgment data
    if (sensitization != null) {
      content.add(_buildContentCard(
        title: 'Sensitization Acknowledgment',
        items: {
          'Database ID': sensitization.id?.toString() ?? 'Not set',
          'Cover Page ID': sensitization.coverPageId?.toString() ?? 'Not set',
          'Acknowledged': _boolToYesNo(sensitization.isAcknowledged),
          'Acknowledged At': _formatDateTime(sensitization.acknowledgedAt) ?? 'Not recorded',
          'Created At': _formatDateTime(sensitization.createdAt) ?? 'Not available',
          'Updated At': _formatDateTime(sensitization.updatedAt) ?? 'Not available',
          'Synced': _boolToYesNo(sensitization.isSynced),
        },
      ));
    } else {
      debugPrint('⚠️ [Viewer] No sensitization acknowledgment data');
    }

    // Sensitization questions data
    if (questions != null && questions.isNotEmpty) {
      debugPrint('✅ [Viewer] Processing ${questions.length} questions');
      
      for (int i = 0; i < questions.length; i++) {
        final question = questions[i];
        debugPrint('📝 [Viewer] Processing question ${i + 1}: ID=${question.id}');
        
        final questionData = <String, String>{};
        
        // Add database info
        questionData['Database ID'] = question.id?.toString() ?? 'Not set';
        questionData['Cover Page ID'] = question.coverPageId?.toString() ?? 'Not set';
        
        // Basic questions
        questionData['Sensitized Household'] = _boolToYesNo(question.hasSensitizedHousehold);
        questionData['Sensitized on Protection'] = _boolToYesNo(question.hasSensitizedOnProtection);
        questionData['Sensitized on Safe Labour'] = _boolToYesNo(question.hasSensitizedOnSafeLabour);
        
        // Adult counts
        if (question.femaleAdultsCount.isNotEmpty && question.femaleAdultsCount != '0') {
          questionData['Female Adults Present'] = question.femaleAdultsCount;
        } else {
          questionData['Female Adults Present'] = '0 (or not recorded)';
        }
        
        if (question.maleAdultsCount.isNotEmpty && question.maleAdultsCount != '0') {
          questionData['Male Adults Present'] = question.maleAdultsCount;
        } else {
          questionData['Male Adults Present'] = '0 (or not recorded)';
        }
        
        // Picture consent
        questionData['Consent for Picture'] = _boolToYesNo(question.consentForPicture);
        if (question.consentForPicture == false && question.consentReason.isNotEmpty) {
          questionData['Reason for No Consent'] = question.consentReason;
        }
        
        // Parents reaction
        if (question.parentsReaction.isNotEmpty) {
          questionData['Parents Reaction'] = question.parentsReaction;
        } else {
          questionData['Parents Reaction'] = 'Not recorded';
        }
        
        // Submission time
        questionData['Submitted At'] = _formatDateTime(question.submittedAt) ?? 'Not recorded';
        
        // Sync status
        questionData['Synced'] = _boolToYesNo(question.isSynced ?? false);

        content.add(_buildContentCard(
          title: 'Sensitization Session ${i + 1}',
          items: questionData,
        ));

        // Image previews
        if (question.sensitizationImagePath?.isNotEmpty == true) {
          debugPrint('🖼️ [Viewer] Adding sensitization image: ${question.sensitizationImagePath}');
          content.add(_buildImagePreviewCard(
            title: 'Sensitization Session ${i + 1} - Photo',
            imagePath: question.sensitizationImagePath!,
          ));
        } else {
          debugPrint('⚠️ [Viewer] No sensitization image for question ${i + 1}');
        }

        if (question.householdWithUserImagePath?.isNotEmpty == true) {
          debugPrint('🖼️ [Viewer] Adding household image: ${question.householdWithUserImagePath}');
          content.add(_buildImagePreviewCard(
            title: 'Household with User ${i + 1} - Photo',
            imagePath: question.householdWithUserImagePath!,
          ));
        } else {
          debugPrint('⚠️ [Viewer] No household image for question ${i + 1}');
        }
      }
    } else {
      debugPrint('⚠️ [Viewer] No sensitization questions found');
      
      // Show info card if we have sensitization but no questions
      if (sensitization != null) {
        content.add(_buildInfoCard(
          'Sensitization Questions', 
          'The sensitization was acknowledged but no detailed questions were recorded.\n\n'
          'This may happen if the questions section was not completed during data collection.',
          icon: Icons.info_outline,
          color: Colors.amber,
        ));
      }
    }

    // If we have neither sensitization nor questions data
    if (content.isEmpty) {
      debugPrint('ℹ️ [Viewer] No sensitization data at all');
      return _buildInfoCard(
        'Sensitization', 
        'This section was not completed during the survey.\n\n'
        'Sensitization data is optional and may not be collected for all surveys.',
        icon: Icons.info_outline,
        color: Colors.blue,
      );
    }

    return _buildScrollableContent(content);
  }

// Helper method for formatting DateTime with null safety
String? _formatDateTime(DateTime? dateTime) {
  if (dateTime == null) return null;
  try {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
           '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  } catch (e) {
    debugPrint('Error formatting date: $e');
    return 'Invalid date';
  }
}
 Widget _buildEndOfCollectionContent() {
  final endOfCollection = widget.surveyData.endOfCollection;
  
  if (endOfCollection == null) {
    return _buildEmptyState(_sections[7]['color']);
  }

  return _buildScrollableContent([
    _buildContentCard(
      title: 'End of Collection Details',
      items: {
        'Database ID': endOfCollection.id?.toString() ?? 'Not set',
        'Cover Page ID': endOfCollection.coverPageId?.toString() ?? 'Not set',
        'Respondent Image': endOfCollection.respondentImagePath?.isNotEmpty == true 
            ? 'Image captured' 
            : 'No image',
        'Producer Signature': endOfCollection.producerSignaturePath?.isNotEmpty == true 
            ? 'Signature captured' 
            : 'No signature',
        'GPS Coordinates': endOfCollection.gpsCoordinates?.isNotEmpty == true 
            ? endOfCollection.gpsCoordinates! 
            : 'Not captured',
        'Latitude': endOfCollection.latitude?.toString() ?? 'Not available',
        'Longitude': endOfCollection.longitude?.toString() ?? 'Not available',
      'End Time': endOfCollection.endTime != null 
    ? _formatDateTime(endOfCollection.endTime!) ?? 'Invalid date'
    : 'Not recorded',
        'Remarks': endOfCollection.remarks?.isNotEmpty == true 
            ? endOfCollection.remarks! 
            : 'No remarks',
       'Created At': _formatDateTime(endOfCollection.createdAt) ?? 'Not available',
'Updated At': _formatDateTime(endOfCollection.updatedAt) ?? 'Not available',
        'Is Synced': _boolToYesNo(endOfCollection.isSynced),
      },
    ),
    
    // Image previews if available
    if (endOfCollection.respondentImagePath?.isNotEmpty == true)
      _buildImagePreviewCard(
        title: 'Respondent Image',
        imagePath: endOfCollection.respondentImagePath!,
      ),
    
    if (endOfCollection.producerSignaturePath?.isNotEmpty == true)
      _buildImagePreviewCard(
        title: 'Producer Signature',
        imagePath: endOfCollection.producerSignaturePath,
      ),
  ]);
}

Widget _buildImagePreviewCard({
  required String title,
  String? imagePath,
}) {
  if (imagePath == null) {
    return Container(); // or return a placeholder widget
  }
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      color: AppTheme.cardColor,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: Colors.grey.shade300,
        width: 1,
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTheme.textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade50,
            ),
            child: FutureBuilder<File?>(
              future: _getImageFile(imagePath),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                    ),
                  );
                }

                if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                  return _buildErrorState(
                    'Failed to load image',
                    'Path: $imagePath\nError: ${snapshot.error}',
                  );
                }

                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    snapshot.data!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildErrorState(
                        'Failed to display image',
                        'Path: ${snapshot.data?.path}\nError: $error',
                      );
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Path: $imagePath',
            style: AppTheme.textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ),
  );
}

Widget _buildErrorState(String title, String message) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ),
  );
}

Future<File?> _getImageFile(String path) async {
  try {
    debugPrint('🖼️ Attempting to load image from path: $path');
    
    // Handle null or empty path
    if (path.isEmpty) {
      debugPrint('❌ Empty image path provided');
      return null;
    }

    // Try direct path first
    final file = File(path);
    if (await file.exists()) {
      debugPrint('✅ Found image at direct path: ${file.path}');
      return file;
    }
    debugPrint('❌ Image not found at direct path: ${file.path}');

    // Try to handle file:// URI
    if (path.startsWith('file://')) {
      try {
        final filePath = Uri.parse(path).toFilePath(windows: Platform.isWindows);
        final fileFromUri = File(filePath);
        if (await fileFromUri.exists()) {
          debugPrint('✅ Found image at file URI path: $filePath');
          return fileFromUri;
        }
        debugPrint('❌ Image not found at file URI path: $filePath');
      } catch (e) {
        debugPrint('❌ Error parsing file URI: $e');
      }
    }

    // Try to find in app's documents directory
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final fileName = path.split(Platform.pathSeparator).last;
      final localFile = File('${appDocDir.path}${Platform.pathSeparator}$fileName');
      
      if (await localFile.exists()) {
        debugPrint('✅ Found image in app documents directory: ${localFile.path}');
        return localFile;
      }
      debugPrint('❌ Image not found in app documents directory: ${localFile.path}');
    } catch (e) {
      debugPrint('❌ Error checking app documents directory: $e');
    }

    // If we get here, the file wasn't found in any location
    debugPrint('❌ Could not find image at any location');
    return null;
  } catch (e, stackTrace) {
    debugPrint('❌ Error in _getImageFile: $e\n$stackTrace');
    return null;
  }
}  String _getTownName(String? townCode, List<DropdownItem> towns) {
    if (townCode == null || townCode.isEmpty) return 'Not selected';
    try {
      final town = towns.firstWhere(
        (town) => town.code == townCode,
        orElse: () => DropdownItem(code: '', name: 'Unknown Town'),
      );
      return town.name;
    } catch (e) {
      return 'Town ($townCode)';
    }
  }

  String _getFarmerName(String? farmerCode, List<DropdownItem> farmers) {
    if (farmerCode == null || farmerCode.isEmpty) return 'Not selected';
    try {
      final farmer = farmers.firstWhere(
        (farmer) => farmer.code == farmerCode,
        orElse: () => DropdownItem(code: '', name: 'Unknown Farmer'),
      );
      return farmer.name;
    } catch (e) {
      return 'Farmer ($farmerCode)';
    }
  }

  dynamic _getCurrentSectionData() {
    return _getSectionData(_selectedSection);
  }

  dynamic _getSectionData(int index) {
    switch (index) {
      case 0: return widget.surveyData.cover;
      case 1: return widget.surveyData.consent;
      case 2: return widget.surveyData.farmer;
      case 3: return widget.surveyData.combinedFarm;
      case 4: return widget.surveyData.childrenHousehold;
      case 5: return widget.surveyData.remediation;
      case 6: return {
        'sensitization': widget.surveyData.sensitization,
        'questions': widget.surveyData.sensitizationQuestions ?? [],
      };
      case 7: return widget.surveyData.endOfCollection;
      default: return null;
    }
}

  String _boolToYesNo(bool? value) {
    if (value == null) return 'Not answered';
    return value ? 'Yes' : 'No';
  }

  String _intToYesNo(int? value) {
    if (value == null) return 'Not answered';
    return value == 1 ? 'Yes' : 'No';
  }

  Widget _buildScrollableContent(List<Widget> children) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildContentCard({
    required String title,
    Map<String, dynamic>? items,
    bool isList = false,
    List<String>? listItems,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTheme.textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            if (items != null)
              ...items.entries.map((entry) => _buildInfoRow(
                    entry.key, 
                    entry.value?.toString() ?? 'N/A',
                  )),
            if (isList && listItems != null && listItems.isNotEmpty)
              ...listItems.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.circle, size: 6, color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item,
                        style: AppTheme.textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
              )),
          ],
        ),
      ),
    );
  }

Widget _buildInfoCard(String title, String message, {IconData icon = Icons.info_outline, Color color = Colors.blue}) {
  return Padding(
    padding: const EdgeInsets.all(16),
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              SizedBox(width: 8),
              Text(
                title,
                style: AppTheme.textTheme.titleLarge?.copyWith(color: color),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            message,
            style: AppTheme.textTheme.bodyLarge,
          ),
        ],
      ),
    ),
  );
}

  Widget _buildInfoRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: AppTheme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: AppTheme.textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}
