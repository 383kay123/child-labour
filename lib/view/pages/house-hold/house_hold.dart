import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:human_rights_monitor/controller/db/db_tables/helpers/household_db_helper.dart';
import 'package:human_rights_monitor/controller/db/table_names.dart';
import 'package:human_rights_monitor/controller/models/household_models.dart';
import 'package:human_rights_monitor/data/dummy_data/cover_dummy_data.dart';
import 'package:human_rights_monitor/view/pages/house-hold/child_details_page.dart';
import 'package:human_rights_monitor/view/pages/house-hold/pages/farm%20identification/children_household_page.dart';
import 'package:human_rights_monitor/view/pages/house-hold/pages/farm%20identification/end_of_collection_page.dart';
import 'package:human_rights_monitor/view/pages/house-hold/pages/farm%20identification/farmer_identification.dart';
import 'package:human_rights_monitor/view/pages/house-hold/pages/farm%20identification/remediation_page.dart';
import 'package:human_rights_monitor/view/pages/house-hold/pages/farm%20identification/sensitization_page.dart';
import 'package:human_rights_monitor/view/pages/house-hold/pages/farm%20identification/sensitization_questions_page.dart';
import 'package:human_rights_monitor/view/pages/house-hold/pages/steps/combined_farmer_identification.dart';
import 'package:human_rights_monitor/view/pages/house-hold/pages/steps/consent_page.dart';
import 'package:human_rights_monitor/view/pages/house-hold/pages/steps/cover_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SurveyState {
  bool isInterviewTimeRecorded = false;
  Position? currentPosition;
  String locationStatus = 'Not recorded';
  DateTime? interviewStartTime;
  String timeStatus = 'Not recorded';
  bool isGettingLocation = false;

  String formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
  }

  String formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    if (difference.inSeconds < 60) return 'just now';
    if (difference.inMinutes < 60)
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    if (difference.inHours < 24)
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
  }
}

class HouseHold extends StatefulWidget {
  final int farmIdentificationId;
  final VoidCallback? onComplete;

  const HouseHold({
    Key? key,
    required this.farmIdentificationId,
    this.onComplete,
  }) : super(key: key);

  @override
  State<HouseHold> createState() => _HouseHoldState();

  static Widget withNewId() {
    return HouseHold(
      farmIdentificationId: DateTime.now().millisecondsSinceEpoch,
    );
  }
}

class _HouseHoldState extends State<HouseHold> with WidgetsBindingObserver {
  // Lifecycle
  bool _isMounted = false;
  bool _isDisposed = false;
  bool _isProcessingNavigation = false;

  // Page Controller
  late final PageController _pageController;

  // Global Keys (One per page)
  final GlobalKey<CoverPageState> _coverPageKey = GlobalKey<CoverPageState>();
  final GlobalKey<ConsentPageState> _consentPageKey = GlobalKey<ConsentPageState>();
  final GlobalKey<FarmerIdentification1PageState> _farmerPageKey = GlobalKey<FarmerIdentification1PageState>();
  final GlobalKey<CombinedFarmIdentificationPageState> _combinedPageKey = GlobalKey<CombinedFarmIdentificationPageState>();
  final GlobalKey<ChildrenHouseholdPageState> _childrenHouseholdKey = GlobalKey<ChildrenHouseholdPageState>();
  final GlobalKey<ChildDetailsPageState> _childDetailsPageKey = GlobalKey<ChildDetailsPageState>();
  final GlobalKey<RemediationPageState> _remediationPageKey = GlobalKey<RemediationPageState>();
  final GlobalKey<SensitizationPageState> _sensitizationPageKey = GlobalKey<SensitizationPageState>();
  final GlobalKey<SensitizationQuestionsPageState> _sensitizationQuestionsKey = GlobalKey<SensitizationQuestionsPageState>();
  final GlobalKey<EndOfCollectionPageState> _endOfCollectionKey = GlobalKey<EndOfCollectionPageState>();

  // Form Keys (Only where needed)
  final GlobalKey<FormState> _childrenHouseholdFormKey = GlobalKey<FormState>();

  // Navigation
  int _currentPageIndex = 0;
  int _combinedPageSubIndex = 0;
  final int _totalPages = 10;

  // State
  bool _isSaving = false;
  bool _isSensitizationChecked = false;
  int _farmIdentificationId = 0;
  
  // Tracking variables
  final Map<String, dynamic> _savedData = {};
  bool _isSavingComplete = false;

  // Children
  int _currentChildNumber = 1;
  int _totalChildren5To17 = 0;
  List<dynamic> _childrenDetails = [];

  // Data
  final SurveyState _surveyState = SurveyState();
  CoverPageData _coverData = CoverPageData.empty();
  ConsentData? _consentData;
  late FarmerIdentificationData _farmerData;

  // Getters
  bool get _isOnCombinedPage => _currentPageIndex == 3;
  double get _progress => (_currentPageIndex + 1) / _totalPages;
  bool get _canUseContext => _isMounted && !_isDisposed && (mounted == true);

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    WidgetsBinding.instance.addObserver(this);

    _pageController = PageController();
    _initFarmerData();
    _coverData = _coverData.copyWith(
      id: widget.farmIdentificationId,
      selectedTownCode: CoverDummyData.dummyTowns.isNotEmpty
          ? CoverDummyData.dummyTowns.first.code
          : null,
      towns: CoverDummyData.dummyTowns,
      farmers: CoverDummyData.getDummyFarmers(CoverDummyData.dummyTowns.firstOrNull?.code),
    );

    _loadSavedState();
  }

  void _initFarmerData() {
    _farmerData = FarmerIdentificationData(
      ghanaCardNumberController: TextEditingController(),
      idNumberController: TextEditingController(),
      contactNumberController: TextEditingController(),
      childrenCountController: TextEditingController(),
      noConsentReasonController: TextEditingController(),
    );
  }

  void safeSetState(VoidCallback fn) {
    if (_canUseContext) setState(fn);
  }

  // Location
  Future<void> _getCurrentLocation() async {
    if (!_canUseContext) return;
    safeSetState(() {
      _surveyState.isGettingLocation = true;
      _surveyState.locationStatus = 'Getting location...';
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        safeSetState(() {
          _surveyState.locationStatus = 'Location services disabled';
          _surveyState.isGettingLocation = false;
        });
        _showSnackBar('Enable location services', action: SnackBarAction(
          label: 'SETTINGS',
          onPressed: Geolocator.openLocationSettings,
        ));
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          safeSetState(() {
            _surveyState.locationStatus = 'Permission denied';
            _surveyState.isGettingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        safeSetState(() {
          _surveyState.locationStatus = 'Permission denied forever';
          _surveyState.isGettingLocation = false;
        });
        return;
      }

      Position position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 10),
        );
      } on TimeoutException {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 15),
        );
      }

      safeSetState(() {
        _surveyState.currentPosition = position;
        _surveyState.locationStatus = 'Location captured';
        _surveyState.isGettingLocation = false;
        _consentData = _consentData?.copyWith(
          currentPosition: position,
          locationStatus: 'Captured',
        );
      });
      _onConsentDataChanged(_consentData!);
    } catch (e) {
      safeSetState(() {
        _surveyState.locationStatus = 'Error: $e';
        _surveyState.isGettingLocation = false;
      });
    }
  }

  void _recordInterviewTime() {
    final now = DateTime.now();
    safeSetState(() {
      _surveyState.interviewStartTime = now;
      _surveyState.timeStatus = 'Started at ${_surveyState.formatTime(now)}';
      _consentData = _consentData?.copyWith(
        interviewStartTime: now,
        timeStatus: _surveyState.timeStatus,
      );
    });
  }

  void _onConsentDataChanged(ConsentData newData) {
    safeSetState(() => _consentData = newData);
  }

  void _onFarmerDataChanged(FarmerIdentificationData newData) async {
    safeSetState(() => _farmerData = newData);
    
    try {
      final db = HouseholdDBHelper.instance;
      if (newData.id == null) {
        // Insert new record
        final id = await db.insertFarmerIdentification(newData);
        safeSetState(() {
          _farmerData = newData.copyWith(id: id);
        });
      } else {
        // Update existing record
        await db.updateFarmerIdentification(newData);
      }
      debugPrint('✅ Farmer information saved successfully');
    } catch (e) {
      debugPrint('❌ Error saving farmer information: $e');
    }
  }

  void _onSurveyEnd() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('End Survey'),
        content: const Text('All unsaved data will be lost.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('END SURVEY', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToPage(int index) async {
    if (!_canUseContext || !_pageController.hasClients) return;
    await _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    safeSetState(() => _currentPageIndex = index);
  }

  void _onPrevious() {
    if (_isOnCombinedPage && _combinedPageSubIndex > 0) {
      final state = _combinedPageKey.currentState;
      if (state?.mounted == true && state!.pageController.hasClients) {
        state.pageController.animateToPage(
          --_combinedPageSubIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else if (_currentPageIndex > 0) {
      _navigateToPage(_currentPageIndex - 1);
    }
  }

  Future<int?> _saveCoverPageData() async {
    try {
      final db = HouseholdDBHelper.instance;
      final id = await db.insertCoverPage(_coverData);
      debugPrint('✅ Cover page saved with ID: $id');
      return id;
    } catch (e) {
      debugPrint('❌ Error saving cover page: $e');
      return null;
    }
  }

  // Enhanced save methods for each page
  Future<bool> _saveCoverPage() async {
    try {
      final saved = await _coverPageKey.currentState?.saveData() ?? false;
      if (!saved) {
        _showSnackBar('Please complete the cover page');
        return false;
      }
      
      final coverPageId = await _saveCoverPageData();
      if (coverPageId == null) {
        _showSnackBar('Failed to save cover page data');
        return false;
      }
      
      _savedData['cover_page'] = _coverData.toMap();
      _showSnackBar('Cover page saved successfully', backgroundColor: Colors.green);
      
      // Update cover data with the new ID
      safeSetState(() {
        _coverData = _coverData.copyWith(id: coverPageId);
        // Initialize consent data with cover page ID
        _consentData = (_consentData ?? ConsentData.empty()).copyWith(
          coverPageId: coverPageId,
        );
      });
      
      return true;
    } catch (e) {
      debugPrint('❌ Error saving cover page: $e');
      _showSnackBar('Error saving cover page: $e');
      return false;
    }
  }

  Future<bool> _saveConsent() async {
    try {
      final validationError = _consentPageKey.currentState?.validateForm();
      if (validationError != null) {
        _showSnackBar(validationError);
        return false;
      }
      
      final saved = await _consentPageKey.currentState?.saveData() ?? false;
      if (!saved) {
        _showSnackBar('Failed to save consent');
        return false;
      }
      
      _savedData['consent'] = _consentData?.toMap();
      debugPrint('✅ Consent saved: ${_consentData?.toMap()}');
      return true;
    } catch (e) {
      debugPrint('❌ Error saving consent: $e');
      _showSnackBar('Error saving consent: $e');
      return false;
    }
  }

  Future<bool> _saveFarmerIdentification() async {
    try {
      if (!_farmerPageKey.currentState!.validateForm()) {
        _showSnackBar('Please complete the farmer identification');
        return false;
      }
      
      safeSetState(() => _isSaving = true);
      final data = _farmerPageKey.currentState!.widget.data;
      final db = HouseholdDBHelper.instance;
      final id = data.id ?? await db.insertFarmerIdentification(data);
      
      safeSetState(() {
        _farmerData = data.copyWith(id: id);
        _farmIdentificationId = id;
      });
      
      _savedData['farmer_identification'] = data.toMap();
      debugPrint('✅ Farmer identification saved with ID: $id');
      return true;
    } catch (e) {
      debugPrint('❌ Error saving farmer identification: $e');
      _showSnackBar('Error saving farmer data: $e');
      return false;
    } finally {
      safeSetState(() => _isSaving = false);
    }
  }

  Future<bool> _saveCombinedFarm() async {
    try {
      final saved = await _combinedPageKey.currentState!.saveData(validateAllPages: false);
      if (!saved) {
        _showSnackBar('Please complete the required fields on this page');
        return false;
      }
      
      // Get the data from the combined page
      final combinedData = _combinedPageKey.currentState!.getCombinedData();
      _savedData['combined_farm'] = combinedData;
      debugPrint('✅ Combined farm data saved');
      return true;
    } catch (e) {
      debugPrint('❌ Error saving combined farm: $e');
      _showSnackBar('Error saving farm data: $e');
      return false;
    }
  }

  Future<bool> _saveChildrenHousehold() async {
    try {
      if (_childrenHouseholdFormKey.currentState?.validate() ?? false) {
        final count = int.tryParse(_farmerData.childrenCountController.text) ?? 0;
        safeSetState(() {
          _totalChildren5To17 = count;
          _currentChildNumber = 1;
        });
        
        _savedData['children_household'] = {
          'children_count': count,
          'total_children_5_to_17': _totalChildren5To17
        };
        debugPrint('✅ Children household data saved: $count children');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Error saving children household: $e');
      return false;
    }
  }

  Future<bool> _saveChildDetails() async {
    try {
      await _saveCurrentChildData();
      _savedData['child_$_currentChildNumber'] = 'saved';
      debugPrint('✅ Child $_currentChildNumber details saved');
      return true;
    } catch (e) {
      debugPrint('❌ Error saving child details: $e');
      return false;
    }
  }

  Future<bool> _saveRemediation() async {
    try {
      final state = _remediationPageKey.currentState;
      if (state == null || !state.validateForm()) {
        _showSnackBar('Complete remediation');
        return false;
      }
      final saved = await state.saveData();
      if (!saved) {
        _showSnackBar('Failed to save remediation');
        return false;
      }
      
      _savedData['remediation'] = 'saved';
      debugPrint('✅ Remediation data saved');
      return true;
    } catch (e) {
      debugPrint('❌ Error saving remediation: $e');
      _showSnackBar('Error saving remediation: $e');
      return false;
    }
  }

  Future<bool> _saveSensitization() async {
    try {
      if (!_isSensitizationChecked) {
        _showSnackBar('Acknowledge sensitization');
        return false;
      }
      
      final saved = await _sensitizationPageKey.currentState?.saveData(_farmIdentificationId) ?? false;
      if (!saved) {
        _showSnackBar('Failed to save sensitization');
        return false;
      }
      
      _savedData['sensitization'] = 'saved';
      debugPrint('✅ Sensitization data saved');
      return true;
    } catch (e) {
      debugPrint('❌ Error saving sensitization: $e');
      _showSnackBar('Error saving sensitization: $e');
      return false;
    }
  }

  Future<bool> _saveSensitizationQuestions() async {
    try {
      final saved = await _sensitizationQuestionsKey.currentState?.saveData(_farmIdentificationId) ?? false;
      if (!saved) {
        _showSnackBar('Complete sensitization questions');
        return false;
      }
      
      _savedData['sensitization_questions'] = 'saved';
      debugPrint('✅ Sensitization questions saved');
      return true;
    } catch (e) {
      debugPrint('❌ Error saving sensitization questions: $e');
      _showSnackBar('Error saving questions: $e');
      return false;
    }
  }

  Future<bool> _saveEndOfCollection() async {
    try {
      if (!_endOfCollectionKey.currentState!.isFormComplete) {
        _showSnackBar('Complete end of collection');
        return false;
      }
      
      _savedData['end_of_collection'] = 'saved';
      debugPrint('✅ End of collection data saved');
      return true;
    } catch (e) {
      debugPrint('❌ Error saving end of collection: $e');
      _showSnackBar('Error saving final data: $e');
      return false;
    }
  }

  Future<void> _saveCurrentChildData() async {
    await _childDetailsPageKey.currentState?.saveData();
  }

  void _refreshChildDetailsPage() {
    safeSetState(() {});
  }

  // Enhanced onNext method with proper saving
  Future<void> _onNext() async {
    if (_isProcessingNavigation) return;
    _isProcessingNavigation = true;

    try {
      bool saveSuccess = false;
      
      switch (_currentPageIndex) {
        case 0: // Cover Page
          saveSuccess = await _saveCoverPage();
          break;
        case 1: // Consent
          saveSuccess = await _saveConsent();
          break;
        case 2: // Farmer
          saveSuccess = await _saveFarmerIdentification();
          break;
        case 3: // Combined
          saveSuccess = await _saveCombinedFarm();
          break;
        case 4: // Children Household
          saveSuccess = await _saveChildrenHousehold();
          if (saveSuccess) {
            final count = int.tryParse(_farmerData.childrenCountController.text) ?? 0;
            if (count > 0) {
              await _navigateToPage(5);
            } else {
              await _navigateToPage(6);
            }
            return;
          }
          break;
        case 5: // Child Details
          saveSuccess = await _saveChildDetails();
          if (saveSuccess) {
            if (_currentChildNumber < _totalChildren5To17) {
              safeSetState(() => _currentChildNumber++);
              _refreshChildDetailsPage();
            } else {
              await _navigateToPage(6);
            }
            return;
          }
          break;
        case 6: // Remediation
          saveSuccess = await _saveRemediation();
          break;
        case 7: // Sensitization
          saveSuccess = await _saveSensitization();
          break;
        case 8: // Sensitization Questions
          saveSuccess = await _saveSensitizationQuestions();
          break;
        case 9: // End
          saveSuccess = await _saveEndOfCollection();
          if (saveSuccess) {
            await _completeSurvey();
            return;
          }
          break;
      }

      if (saveSuccess && _currentPageIndex < _totalPages - 1) {
        await _navigateToPage(_currentPageIndex + 1);
      }
      
      // Log current saved data state
      _logSavedData();
      
    } finally {
      _isProcessingNavigation = false;
    }
  }

  // Log current saved data
  void _logSavedData() {
    debugPrint('\n📊 CURRENT SAVED DATA STATUS:');
    _savedData.forEach((key, value) {
      debugPrint('   - $key: ${value != null ? 'SAVED' : 'NOT SAVED'}');
    });
    debugPrint('   - Total pages completed: ${_savedData.length}/$_totalPages\n');
  }

  // Complete survey and save everything
  Future<void> _completeSurvey() async {
    try {
      safeSetState(() => _isSavingComplete = true);
      
      // Get all the data from the form
      final combinedFarmData = _combinedPageKey.currentState is Map<String, dynamic> ? 
    _combinedPageKey.currentState : _combinedPageKey.currentState?.getCombinedData();
          
      final childrenHouseholdData = _childrenHouseholdKey.currentState is Map<String, dynamic> ?
          _childrenHouseholdKey.currentState : _childrenHouseholdKey.currentState?.getHouseholdData();
          
      final remediationData = _remediationPageKey.currentState is Map<String, dynamic> ?
          _remediationPageKey.currentState : await _remediationPageKey.currentState?.getFormData();
          
      // Get the sensitization data from the state
      final sensitizationData = _sensitizationPageKey.currentState is Map<String, dynamic> 
          ? _sensitizationPageKey.currentState 
          : {
              'isAcknowledged': _isSensitizationChecked,
              'acknowledgedAt': DateTime.now().toIso8601String(),
            };
      
      // Save the sensitization data
      if (_sensitizationPageKey.currentState is! Map<String, dynamic>) {
        await SensitizationPage.of(_sensitizationPageKey)?.saveData(widget.farmIdentificationId);
      }
      final sensitizationQuestionsData = _sensitizationQuestionsKey.currentState is Map<String, dynamic> ?
          _sensitizationQuestionsKey.currentState : await _sensitizationQuestionsKey.currentState?.getData();
          
      final endOfCollectionData = _endOfCollectionKey.currentState is Map<String, dynamic> ?
          _endOfCollectionKey.currentState : await _endOfCollectionKey.currentState?.getData();
      
      // Log the data for debugging
      debugPrint('📋 SAVING SURVEY DATA:');
      debugPrint('   • Cover Page: ${_coverData != null ? '✅' : '❌'}');
      debugPrint('   • Consent: ${_consentData != null ? '✅' : '❌'}');
      debugPrint('   • Farmer: ${_farmerData != null ? '✅' : '❌'}');
      debugPrint('   • Combined Farm: ${combinedFarmData != null ? '✅' : '❌'}');
      debugPrint('   • Children Household: ${childrenHouseholdData != null ? '✅' : '❌'}');
      debugPrint('   • Remediation: ${remediationData != null ? '✅' : '❌'}');
      debugPrint('   • Sensitization: ${sensitizationData != null ? '✅' : '❌'}');
      debugPrint('   • Sensitization Questions: ${sensitizationQuestionsData != null ? '✅' : '❌'}');
      debugPrint('   • End of Collection: ${endOfCollectionData != null ? '✅' : '❌'}');
      
      // Save all data in a single transaction
      final success = await HouseholdDBHelper.instance.saveCompleteSurvey(
        coverPage: _coverData,
        consent: _consentData!,
        farmer: _farmerData,
       combinedFarm: combinedFarmData != null 
    ? CombinedFarmerIdentificationModel.fromMap(
        (combinedFarmData is Map<String, dynamic> 
            ? combinedFarmData 
            : (combinedFarmData as dynamic).toMap())
      )
    : null,
                
        childrenHousehold: childrenHouseholdData != null
            ? ChildrenHouseholdModel.fromMap(
                childrenHouseholdData is Map<String, dynamic> 
                    ? childrenHouseholdData 
                    : (childrenHouseholdData as dynamic).toMap()
              ) 
            : null,
                
        remediation: remediationData != null
    ? (remediationData is Map<String, dynamic>
        ? RemediationModel.fromMap(remediationData)
        : (remediationData is RemediationModel 
            ? remediationData 
            : null))
    : null,
                
        // Get the farm ID safely
        sensitization: () {
          // First, safely extract the farm ID
          int? farmId;
          if (combinedFarmData is Map<String, dynamic>) {
            farmId = (combinedFarmData as Map<String, dynamic>)['id'] as int?;
          } else if (combinedFarmData is CombinedFarmerIdentificationModel) {
            farmId = (combinedFarmData as CombinedFarmerIdentificationModel).id;
          }
          
          // Then create the SensitizationData with the farm ID
          if (sensitizationData is bool) {
            return SensitizationData(
              coverPageId: _coverData.id,
              farmIdentificationId: farmId,
              isAcknowledged: sensitizationData as bool,
            );
          } else if (sensitizationData is Map<String, dynamic>) {
            final data = Map<String, dynamic>.from(sensitizationData as Map<String, dynamic>);
            data['farm_identification_id'] = farmId;
            return SensitizationData.fromMap(data);
          }
          return null;
        }(),
            
        sensitizationQuestions: sensitizationQuestionsData != null ?
            (sensitizationQuestionsData is List ?
                sensitizationQuestionsData.map((e) => e is Map<String, dynamic> ?
                    SensitizationQuestionsData.fromMap(e) :
                    e is SensitizationQuestionsData ? e : SensitizationQuestionsData()
                ).toList() :
                [SensitizationQuestionsData.fromMap(sensitizationQuestionsData is Map<String, dynamic> ?
                    sensitizationQuestionsData : {})]
            ) : null,
            
        endOfCollection: endOfCollectionData != null ?
            EndOfCollectionModel.fromMap(endOfCollectionData is Map<String, dynamic> ?
                endOfCollectionData : endOfCollectionData is EndOfCollectionModel ? 
                endOfCollectionData.toMap() : {}) : null,
      );
      
      if (success) {
        _showSnackBar('Survey completed and saved successfully!', backgroundColor: Colors.green);
        
        // Show summary of saved data
        _showSaveSummary();
        
        widget.onComplete?.call();
        if (mounted) {
          Navigator.popUntil(context, (r) => r.isFirst);
        }
      } else {
        _showSnackBar('Failed to save survey data');
      }
    } catch (e) {
      debugPrint('❌ Error completing survey: $e');
      _showSnackBar('Error completing survey: $e');
    } finally {
      safeSetState(() => _isSavingComplete = false);
    }
  }

  // Show save summary dialog
  void _showSaveSummary() {
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Survey Saved Successfully'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('The following data has been saved:'),
              const SizedBox(height: 16),
              ..._savedData.entries.map((entry) => 
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_getPageName(entry.key))),
                    ],
                  ),
                )
              ).toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _getPageName(String key) {
    final names = {
      'cover_page': 'Cover Page',
      'consent': 'Consent Form',
      'farmer_identification': 'Farmer Identification',
      'combined_farm': 'Farm Details',
      'children_household': 'Children in Household',
      'remediation': 'Remediation',
      'sensitization': 'Sensitization',
      'sensitization_questions': 'Sensitization Questions',
      'end_of_collection': 'End of Collection',
    };
    return names[key] ?? key;
  }

  // View saved data
  void _viewSavedData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Saved Data Preview'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Current saved data:'),
              const SizedBox(height: 16),
              Text(
                _savedData.toString(),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 10),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _handleCombinedPageSubmit() {
    _pageController.jumpToPage(4);
  }

  String _getPageTitle(int index) {
    final titles = [
      'Cover Page', 'Consent Form', 'Farmer Identification', 'Farm Details',
      'Children in Household', 'Child $_currentChildNumber of $_totalChildren5To17 Details',
      'Remediation', 'Sensitization', 'Sensitization Questions', 'End of Collection'
    ];
    return titles[index];
  }

  void _showSnackBar(String msg, {Color? backgroundColor, SnackBarAction? action}) {
    if (!_canUseContext) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: backgroundColor ?? Colors.red,
        behavior: SnackBarBehavior.floating,
        action: action,
      ));
    });
  }

  Future<void> _resetFormData() async {
    final db = await HouseholdDBHelper.instance.database;
    final tables = [
      TableNames.coverPageTBL, TableNames.consentTBL, TableNames.farmerIdentificationTBL,
      TableNames.combinedFarmIdentificationTBL, TableNames.childrenHouseholdTBL,
      TableNames.remediationTBL, TableNames.sensitizationTBL,
      TableNames.sensitizationQuestionsTBL, TableNames.endOfCollectionTBL,
    ];
    await db.transaction((txn) => Future.wait(tables.map(txn.delete)));

    _initFarmerData();
    safeSetState(() {
      _currentPageIndex = 0;
      _combinedPageSubIndex = 0;
      _currentChildNumber = 1;
      _totalChildren5To17 = 0;
      _childrenDetails = [];
      _isSensitizationChecked = false;
      _farmIdentificationId = 0;
      _savedData.clear();
    });

    SharedPreferences.getInstance().then((p) {
      p.remove('selected_town');
      p.remove('selected_farmer');
    });
  }

  Future<void> _loadSavedState() async {
    // Load from DB if needed
  }

  @override
  void dispose() {
    _isMounted = false;
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    _farmerData.ghanaCardNumberController.dispose();
    _farmerData.idNumberController.dispose();
    _farmerData.contactNumberController.dispose();
    _farmerData.childrenCountController.dispose();
    _farmerData.noConsentReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Exit Survey?'),
            content: const Text('All unsaved progress will be lost.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false), 
                child: const Text('Cancel')
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Exit', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
        if (shouldPop == true) {
          await _resetFormData();
        }
        return shouldPop ?? false;
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () async {
              await _resetFormData();
              if (mounted) Navigator.pop(context);
            },
          ),
          title: Column(
            children: [
              Text(
                'Household Survey', 
                style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white)
              ),
              Text(
                _getPageTitle(_currentPageIndex), 
                style: GoogleFonts.inter(fontSize: 14, color: Colors.white.withOpacity(0.9))
              ),
            ],
          ),
          centerTitle: true,
          backgroundColor: Colors.green.shade600,
          actions: [
            IconButton(
              icon: const Icon(Icons.bug_report, color: Colors.white),
              onPressed: _viewSavedData,
              tooltip: 'View Saved Data',
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4),
            child: LinearProgressIndicator(
              value: _progress, 
              backgroundColor: Colors.green.shade400, 
              valueColor: const AlwaysStoppedAnimation(Colors.white)
            ),
          ),
        ),
        body: Column(
          children: [
            if (_isSaving || _isSavingComplete)
              LinearProgressIndicator(
                value: _isSavingComplete ? 1.0 : null,
                backgroundColor: Colors.green.shade100,
                valueColor: AlwaysStoppedAnimation(Colors.green.shade600),
              ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => safeSetState(() => _currentPageIndex = i),
                children: [
                  CoverPage(
                    key: _coverPageKey, 
                    data: _coverData, 
                    onDataChanged: (d) => safeSetState(() => _coverData = d), 
                    onNext: _onNext
                  ),
                  _coverData.id != null
                      ? ConsentPage(
                          key: _consentPageKey,
                          data: _consentData ?? ConsentData.empty().copyWith(coverPageId: _coverData.id),
                          coverPageId: _coverData.id,
                          onDataChanged: _onConsentDataChanged,
                          onRecordTime: _recordInterviewTime,
                          onGetLocation: _getCurrentLocation,
                          onNext: _onNext,
                          onPrevious: _onPrevious,
                          onSurveyEnd: _onSurveyEnd,
                        )
                      : const Center(child: CircularProgressIndicator()),
                  FarmerIdentification1Page(
                    key: _farmerPageKey,
                    data: _farmerData,
                    onDataChanged: _onFarmerDataChanged,
                    onNext: _onNext,
                  ),
                  CombinedFarmIdentificationPage(
                    key: _combinedPageKey,
                    initialPageIndex: _combinedPageSubIndex,
                    onPageChanged: (i) => safeSetState(() => _combinedPageSubIndex = i),
                    onPrevious: _onPrevious,
                    onNext: _onNext,
                    onSubmit: _handleCombinedPageSubmit,
                  ),
                  ChildrenHouseholdPage(
                    key: _childrenHouseholdKey,
                    formKey: _childrenHouseholdFormKey,
                    producerDetails: {
                      'ghanaCardNumber': _farmerData.ghanaCardNumberController.text,
                      'contactNumber': _farmerData.contactNumberController.text,
                    },
                    children5To17Controller: _farmerData.childrenCountController,
                    onPrevious: _onPrevious,
                    onNext: () {
                      if (_childrenHouseholdFormKey.currentState?.validate() ?? false) {
                        final count = int.tryParse(_farmerData.childrenCountController.text) ?? 0;
                        safeSetState(() {
                          _totalChildren5To17 = count;
                          _currentChildNumber = 1;
                        });
                        _navigateToPage(count > 0 ? 5 : 6);
                      }
                    },
                  ),
                  ChildDetailsPage(
                    key: _childDetailsPageKey,
                    childNumber: _currentChildNumber,
                    totalChildren: _totalChildren5To17,
                    childrenDetails: _childrenDetails,
                    onComplete: (result) async {
                      await _saveCurrentChildData();
                      if (_currentChildNumber < _totalChildren5To17) {
                        safeSetState(() => _currentChildNumber++);
                        _refreshChildDetailsPage();
                      } else {
                        _navigateToPage(6);
                      }
                    },
                  ),
                  RemediationPage(
                    key: _remediationPageKey,
                    onPrevious: _onPrevious,
                    onNext: _onNext,
                    coverPageId: _farmIdentificationId,
                  ),
                  SensitizationPage(
                    key: _sensitizationPageKey,
                    sensitizationData: SensitizationData(isAcknowledged: _isSensitizationChecked),
                    onSensitizationChanged: (d) => safeSetState(() => _isSensitizationChecked = d.isAcknowledged),
                  ),
                  SensitizationQuestionsPage(
                    key: _sensitizationQuestionsKey,
                    onNext: _onNext,
                    onPrevious: _onPrevious,
                    coverPageId: _farmIdentificationId,
                  ),
                  EndOfCollectionPage(
                    key: _endOfCollectionKey,
                    onPrevious: _onPrevious,
                    onComplete: () async {
                      if (_endOfCollectionKey.currentState!.isFormComplete) {
                        await _completeSurvey();
                      }
                    },
                  ),
                ],
              ),
            ),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentPageIndex > 0 || (_isOnCombinedPage && _combinedPageSubIndex > 0))
            ElevatedButton(
              onPressed: _onPrevious, 
              child: const Text('Previous')
            )
          else
            const SizedBox(width: 100),
          ElevatedButton(
            onPressed: _isSaving || _isSavingComplete ? null : _onNext,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade600),
            child: Text(
              _currentPageIndex == _totalPages - 1 ? 'Submit' : 'Next',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}