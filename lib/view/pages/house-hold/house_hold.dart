import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:human_rights_monitor/controller/db/daos/sensitization_questions_dao.dart';
import 'package:human_rights_monitor/controller/db/daos/remediation_dao.dart';
import 'package:human_rights_monitor/controller/db/daos/sensitization_questions_dao.dart';
import 'package:human_rights_monitor/controller/db/db.dart';
import 'package:human_rights_monitor/controller/db/db_tables/helpers/household_db_helper.dart';
import 'package:sqflite/sqflite.dart';
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
  final VoidCallback? onComplete;
  final int coverPageId;

  const HouseHold({
    Key? key,
    this.onComplete,
    required this.coverPageId,
  }) : super(key: key);

  @override
  State<HouseHold> createState() => _HouseHoldState();

  static Widget withNewId() {
    return HouseHold(
      coverPageId: DateTime.now().millisecondsSinceEpoch,
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
  bool _isSavingComplete = false;
  bool _isSensitizationChecked = false;
  int _farmIdentificationId = 0;
  
  // Tracking variables
  final Map<String, dynamic> _savedData = {};

  // Children
  int _currentChildNumber = 1;
  int _totalChildren5To17 = 0;
  List<dynamic> _childrenDetails = [];

  // Data
  final SurveyState _surveyState = SurveyState();
  CoverPageData _coverData = CoverPageData.empty();
  
  // Validation fields
  bool? hasSensitizedHousehold;
  bool? hasSensitizedOnProtection;
  bool? hasSensitizedOnSafeLabour;
  final TextEditingController _femaleAdultsController = TextEditingController();
  final TextEditingController _maleAdultsController = TextEditingController();
  bool? _consentForPicture;
  final TextEditingController _consentReasonController = TextEditingController();
  final TextEditingController _reactionController = TextEditingController();
  dynamic _sensitizationImage;
  dynamic _householdWithUserImage;
  ConsentData? _consentData;
  FarmerIdentificationData _farmerData = FarmerIdentificationData(
    hasGhanaCard: 0,
    childrenCount: 0,
    children: [],
  );

  // Remediation data
  RemediationModel? remediationData;

  // Getters
  bool get _isOnCombinedPage => _currentPageIndex == 3;
  double get _progress => (_currentPageIndex + 1) / _totalPages;
  bool get _canUseContext => _isMounted && !_isDisposed && mounted;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    WidgetsBinding.instance.addObserver(this);

    _pageController = PageController();
    _coverData = _coverData.copyWith(
      selectedTownCode: CoverDummyData.dummyTowns.isNotEmpty
          ? CoverDummyData.dummyTowns.first.code
          : null,
      towns: CoverDummyData.dummyTowns,
      farmers: CoverDummyData.getDummyFarmers(CoverDummyData.dummyTowns.firstOrNull?.code),
    );

    // Initialize with the provided coverPageId
    if (widget.coverPageId != 0) {
      _coverData = _coverData.copyWith(id: widget.coverPageId);
    }
    
    _initFarmerData();
    _loadSavedState();
  }

  void _initFarmerData() {
    _farmerData = FarmerIdentificationData(
      coverPageId: _coverData.id,
      hasGhanaCard: 0,
      childrenCount: 0,
      idPictureConsent: 0,
      isSynced: 0,
      syncStatus: 0,
    );
    
    // Initialize controllers with existing values if they exist
    if (_farmerData.ghanaCardNumber != null) {
      _farmerData.ghanaCardNumberController.text = _farmerData.ghanaCardNumber!;
    }
    if (_farmerData.idNumber != null) {
      _farmerData.idNumberController.text = _farmerData.idNumber!;
    }
    if (_farmerData.contactNumber != null) {
      _farmerData.contactNumberController.text = _farmerData.contactNumber!;
    }
    if (_farmerData.noConsentReason != null) {
      _farmerData.noConsentReasonController.text = _farmerData.noConsentReason!;
    }
    _farmerData.childrenCountController.text = _farmerData.childrenCount.toString();
    
    debugPrint('ℹ️ Initialized farmer data with coverPageId: ${_coverData.id}');
  }

  void safeSetState(VoidCallback fn) {
    if (_canUseContext) {
      setState(fn);
    }
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
      if (_consentData != null) {
        _onConsentDataChanged(_consentData!);
      }
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

  void _onFarmerDataChanged(FarmerIdentificationData newData) {
    safeSetState(() => _farmerData = newData);
  }
 
  void _onSurveyEnd() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('End Survey'),
        content: const Text('All unsaved data will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text('CANCEL')
          ),
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
      
      // If we don't have an ID yet, create one
      if (_coverData.id == null) {
        final coverPageId = await _saveCoverPageData();
        if (coverPageId == null) {
          _showSnackBar('Failed to save cover page data');
          return false;
        }
        safeSetState(() {
          _coverData = _coverData.copyWith(id: coverPageId);
        });
      }
      
      _savedData['cover_page'] = _coverData.toMap();
      _showSnackBar('Cover page saved successfully', backgroundColor: Colors.green);
      
      return true;
    } catch (e) {
      debugPrint('❌ Error saving cover page: $e');
      _showSnackBar('Error saving cover page: $e');
      return false;
    }
  }

  Future<bool> _saveConsent() async {
    try {
      // Ensure cover page is saved first
      if (_coverData.id == null) {
        final success = await _saveCoverPage();
        if (!success) return false;
      }

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
      
      _savedData['consent'] = 'saved';
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
      
      // Ensure cover page ID is set
      final dataWithCoverPageId = _farmerData.copyWith(
        coverPageId: _coverData.id,
      );
      
      final db = HouseholdDBHelper.instance;
      final id = await db.insertFarmerIdentification(dataWithCoverPageId);
      
      safeSetState(() {
        _farmerData = dataWithCoverPageId.copyWith(id: id);
        _farmIdentificationId = id;
      });
      
      _savedData['farmer_identification'] = dataWithCoverPageId.toMap();
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
      debugPrint('🔄 [Combined Farm] Starting save process...');
      
      final state = _combinedPageKey.currentState;
      if (state == null) {
        debugPrint('❌ [Combined Farm] State is null');
        _showSnackBar('Combined farm page not initialized');
        return false;
      }

      // Save current page data
      final saved = await state.saveData(validateAllPages: false);
      if (!saved) {
        _showSnackBar('Please complete the required fields on this page');
        return false;
      }

      // Get combined data
      final combinedData = state.getCombinedData();
      if (combinedData == null) {
        debugPrint('❌ [Combined Farm] Failed to get combined data');
        _showSnackBar('Failed to retrieve farm data');
        return false;
      }

      // Ensure cover page ID is set
      final dataWithCoverId = combinedData.copyWith(
        coverPageId: _coverData.id,
        createdAt: combinedData.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to database
      final db = HouseholdDBHelper.instance;
      final farmId = await db.insertCombinedFarmerIdentification(dataWithCoverId);
      
      debugPrint('✅ [Combined Farm] Saved with ID: $farmId');
      
      _savedData['combined_farm'] = {
        'id': farmId,
        'cover_page_id': _coverData.id,
        'saved_at': DateTime.now().toIso8601String(),
      };
      
      _showSnackBar('Farm information saved successfully', backgroundColor: Colors.green);
      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ [Combined Farm] Error: $e');
      debugPrint('📜 Stack trace: $stackTrace');
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
      debugPrint('🔄 [Remediation] Starting save process...');
      
      final state = _remediationPageKey.currentState;
      if (state == null) {
        debugPrint('❌ [Remediation] State is null');
        _showSnackBar('Remediation page not initialized');
        return false;
      }

      if (!state.validateForm()) {
        _showSnackBar('Please complete all required remediation fields');
        return false;
      }

      // Get the remediation data from the state
      final remediationFormData = state.getFormData();
      
      final saved = await state.saveData(_coverData.id!);
      if (!saved) {
        _showSnackBar('Failed to save remediation data');
        return false;
      }
      
      // Store the remediation data
      remediationData = await _getRemediationByCoverPageId(_coverData.id!);
      
      _savedData['remediation'] = {
        'saved': true,
        'cover_page_id': _coverData.id,
        'data': remediationFormData,
        'timestamp': DateTime.now().toIso8601String()
      };
      
      debugPrint('✅ [Remediation] Saved successfully');
      _showSnackBar('Remediation data saved successfully', backgroundColor: Colors.green);
      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ [Remediation] Error: $e');
      debugPrint('📜 Stack trace: $stackTrace');
      _showSnackBar('Error saving remediation: $e');
      return false;
    }
  }

  Future<bool> _saveSensitization() async {
    try {
      debugPrint('🔄 [Sensitization] Starting save process...');
      
      if (!_isSensitizationChecked) {
        _showSnackBar('Please acknowledge the sensitization information');
        return false;
      }
      
      final state = _sensitizationPageKey.currentState;
      if (state == null) {
        // Create sensitization data directly
        final sensitizationData = SensitizationData(
          coverPageId: _coverData.id!,
          isAcknowledged: _isSensitizationChecked,
          acknowledgedAt: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isSynced: false,
          syncStatus: 0,
        );
        
        final db = HouseholdDBHelper.instance;
        final id = await db.insertSensitization(sensitizationData);
        
        debugPrint('✅ [Sensitization] Direct save successful with ID: $id');
        
        _savedData['sensitization'] = {
          'id': id,
          'cover_page_id': _coverData.id,
          'is_acknowledged': true,
        };
      } else {
        // Use state to save
        final saved = await state.saveData(_coverData.id!);
        if (!saved) {
          debugPrint('❌ [Sensitization] State save failed');
          _showSnackBar('Failed to save sensitization');
          return false;
        }
        
        _savedData['sensitization'] = {
          'cover_page_id': _coverData.id,
          'is_acknowledged': true,
        };
      }
      
      _showSnackBar('Sensitization saved successfully', backgroundColor: Colors.green);
      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ [Sensitization] Error: $e');
      debugPrint('📜 Stack trace: $stackTrace');
      _showSnackBar('Error saving sensitization: $e');
      return false;
    }
  }

  Future<bool> _saveSensitizationQuestions() async {
    try {
      debugPrint('🔄 [Sensitization Questions] Saving with coverPageId: ${_coverData.id}');

      final state = _sensitizationQuestionsKey.currentState;
      if (state == null) {
        debugPrint('❌ [Sensitization Questions] State is null');
        _showSnackBar('Sensitization questions page not initialized');
        return false;
      }

      // Save using cover page ID instead of farm identification ID
      final saved = await state.saveData(_coverData.id!);
      if (!saved) {
        _showSnackBar('Please complete all sensitization questions');
        return false;
      }
      
      _savedData['sensitization_questions'] = {
        'cover_page_id': _coverData.id,
        'saved_at': DateTime.now().toIso8601String(),
      };
      
      debugPrint('✅ [Sensitization Questions] Saved successfully');
      _showSnackBar('Sensitization questions saved successfully', backgroundColor: Colors.green);
      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ [Sensitization Questions] Error: $e');
      debugPrint('📜 Stack trace: $stackTrace');
      _showSnackBar('Error saving questions: $e');
      return false;
    }
  }

  Future<bool> _saveEndOfCollection() async {
  try {
    debugPrint('🔄 [EndOfCollection] Starting save process...');
    
    final state = _endOfCollectionKey.currentState;
    if (state == null) {
      debugPrint('❌ [EndOfCollection] State is null');
      _showSnackBar('End of collection page not initialized');
      return false;
    }

    // Check if form is complete
    if (!state.isFormComplete) {
      _showSnackBar('Please complete all required fields in End of Collection');
      return false;
    }

    // Get the form data
    final formData = state.getData();
    if (formData == null) {
      debugPrint('❌ [EndOfCollection] No data returned from form');
      _showSnackBar('Failed to retrieve end of collection data');
      return false;
    }

    debugPrint('📝 [EndOfCollection] Form data: $formData');

    // Create EndOfCollectionModel
    final endOfCollectionData = EndOfCollectionModel(
      coverPageId: _coverData.id,
      respondentImagePath: formData['respondentImagePath'],
      producerSignaturePath: formData['producerSignaturePath'],
      gpsCoordinates: formData['gpsCoordinates'],
      latitude: formData['latitude'],
      longitude: formData['longitude'],
      endTime: formData['endTime'] != null 
          ? DateTime.parse(formData['endTime'])
          : null,
      remarks: formData['remarks'],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isSynced: false,
      syncStatus: 0,
    );

    debugPrint('💾 [EndOfCollection] Saving to database...');
    
    // Save to database
    final db = HouseholdDBHelper.instance;
    final id = await db.saveEndOfCollection(endOfCollectionData);
    
    if (id > 0) {
      _savedData['end_of_collection'] = {
        'id': id,
        'cover_page_id': _coverData.id,
        'saved_at': DateTime.now().toIso8601String(),
        'has_respondent_image': endOfCollectionData.respondentImagePath != null,
        'has_signature': endOfCollectionData.producerSignaturePath != null,
        'has_gps': endOfCollectionData.gpsCoordinates != null,
      };
      
      debugPrint('✅ [EndOfCollection] Saved successfully with ID: $id');
      _showSnackBar('End of collection data saved successfully', backgroundColor: Colors.green);
      return true;
    } else {
      debugPrint('❌ [EndOfCollection] Failed to save - returned ID: $id');
      _showSnackBar('Failed to save end of collection data');
      return false;
    }
  } catch (e, stackTrace) {
    debugPrint('❌ [EndOfCollection] Error: $e');
    debugPrint('📜 Stack trace: $stackTrace');
    _showSnackBar('Error saving end of collection: $e');
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
      bool shouldNavigate = true;
      
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
              await _navigateToPage(5); // Go to child details
              shouldNavigate = false; // Don't do default navigation
            } else {
              await _navigateToPage(6); // Skip to remediation
              shouldNavigate = false; // Don't do default navigation
            }
          }
          break;
        case 5: // Child Details
          saveSuccess = await _saveChildDetails();
          if (saveSuccess) {
            if (_currentChildNumber < _totalChildren5To17) {
              safeSetState(() => _currentChildNumber++);
              _refreshChildDetailsPage();
              shouldNavigate = false; // Stay on same page, just update child number
            } else {
              await _navigateToPage(6); // Go to remediation after all children
              shouldNavigate = false; // Don't do default navigation
            }
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
            shouldNavigate = false; // Don't navigate after completion
          }
          break;
      }

      // Only navigate if save was successful and we're not handling navigation manually
      if (saveSuccess && shouldNavigate && _currentPageIndex < _totalPages - 1) {
        await _navigateToPage(_currentPageIndex + 1);
      }
      
      // Log current saved data state
      _logSavedData();
      
    } catch (e, stackTrace) {
      debugPrint('❌ Error in _onNext: $e');
      debugPrint('📜 Stack trace: $stackTrace');
      _showSnackBar('Navigation error: $e');
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

  Future<RemediationModel?> _getRemediationByCoverPageId(int coverPageId) async {
    try {
      final dao = RemediationDao(dbHelper: HouseholdDBHelper.instance);
      return await dao.getByCoverPageId(coverPageId);
    } catch (e) {
      debugPrint('❌ Error getting remediation by cover page ID: $e');
      return null;
    }
  }

  // Complete survey and save everything
  Future<void> _completeSurvey() async {
    try {
      safeSetState(() => _isSavingComplete = true);
      
      debugPrint('🔄 Starting complete survey save...');
      debugPrint('📋 Cover Page ID: ${_coverData.id}');
      
      // 1. Get Combined Farm Data
      if (_coverData.id == null) {
        debugPrint('❌ Error: Cover page ID is null');
        _showSnackBar('Error: Missing cover page ID. Please save the cover page first.');
        safeSetState(() => _isSavingComplete = false);
        return;
      }
      
      CombinedFarmerIdentificationModel? combinedFarmData;
      try {
        final householdDB = HouseholdDBHelper.instance;
        combinedFarmData = await householdDB.getCombinedFarmByCoverPageId(_coverData.id!);
  
  // If no data exists, try to get from current state
  if (combinedFarmData == null) {
    final combinedState = _combinedPageKey.currentState;
    if (combinedState != null) {
      final rawData = combinedState.getCombinedData();
      if (rawData != null) {
        combinedFarmData = rawData.copyWith(
          coverPageId: _coverData.id,
          createdAt: rawData.createdAt ?? DateTime.now(),
          updatedAt: DateTime.now(),
        );
        debugPrint('✅ Combined farm data retrieved from form state');
      }
    }
  } else {
    debugPrint('✅ Combined farm data loaded from database: ${combinedFarmData.id}');
  }
  
  // Debug what we have
  if (combinedFarmData != null) {
    debugPrint('📊 Combined Farm Data:');
    debugPrint('   - Visit Info: ${combinedFarmData.visitInformation != null}');
    debugPrint('   - Owner Info: ${combinedFarmData.ownerInformation != null}');
    debugPrint('   - Workers Info: ${combinedFarmData.workersInFarm != null}');
    debugPrint('   - Adults Info: ${combinedFarmData.adultsInformation != null}');
  } else {
    debugPrint('⚠️ No combined farm data available');
  }
} catch (e) {
  debugPrint('❌ Error getting combined farm data: $e');
}
      // 2. Get Children Household Data
      ChildrenHouseholdModel? childrenHouseholdData;
      try {
        final childrenState = _childrenHouseholdKey.currentState;
        if (childrenState != null) {
          final rawData = childrenState.getHouseholdData();
          if (rawData != null) {
            childrenHouseholdData = ChildrenHouseholdModel.fromMap(
              rawData is Map<String, dynamic> ? rawData : (rawData as dynamic).toMap()
            ).copyWith(
              coverPageId: _coverData.id,
              timestamp: DateTime.now(),
            );
            debugPrint('✅ Children household data retrieved');
          }
        }
      } catch (e) {
        debugPrint('❌ Error getting children household data: $e');
      }
      
      // 3. Get Remediation Data
      if (remediationData == null && _coverData.id != null) {
        try {
          final savedRemediation = await _getRemediationByCoverPageId(_coverData.id!);
          if (savedRemediation != null) {
            remediationData = savedRemediation;
            debugPrint('✅ Loaded saved remediation data: ${remediationData!.id}');
          } else {
            debugPrint('⚠️ No remediation data found for cover page ID: ${_coverData.id}');
          }
        } catch (e) {
          debugPrint('❌ Error getting remediation data: $e');
        }
      }

      // 4. Get Sensitization Data
      SensitizationData? sensitizationData;
      try {
        sensitizationData = SensitizationData(
          coverPageId: _coverData.id,
          isAcknowledged: _isSensitizationChecked,
          acknowledgedAt: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isSynced: false,
          syncStatus: 0,
        );
        debugPrint('✅ Sensitization data created');
      } catch (e) {
        debugPrint('❌ Error creating sensitization data: $e');
      }
      
      // 5. Get Sensitization Questions Data
    // 5. Get Sensitization Questions Data - FIXED VERSION
List<SensitizationQuestionsData>? sensitizationQuestionsData;
try {
  // Try to load existing data first
  final db = HouseholdDBHelper.instance;
  final questionsDao = SensitizationQuestionsDao(dbHelper: LocalDBHelper.instance);
  final existingQuestions = await questionsDao.getByCoverPageId(_coverData.id!);
  
  if (existingQuestions != null) {
    sensitizationQuestionsData = [existingQuestions];
    debugPrint('✅ Loaded saved sensitization questions: ${existingQuestions.id}');
  } else {
    // If no existing data, try to get from current state
    final questionsState = _sensitizationQuestionsKey.currentState;
    if (questionsState != null) {
      final saved = await questionsState.saveData(_coverData.id!);
      if (saved) {
        // Reload the data after saving
        final reloadedQuestions = await questionsDao.getByCoverPageId(_coverData.id!);
        if (reloadedQuestions != null) {
          sensitizationQuestionsData = [reloadedQuestions];
          debugPrint('✅ Saved and loaded sensitization questions');
        }
      }
    }
  }
} catch (e) {
  debugPrint('❌ Error getting sensitization questions: $e');
}  
       // 6. Get End of Collection Data - ENHANCED VERSION
    EndOfCollectionModel? endOfCollectionData;
    try {
      final db = HouseholdDBHelper.instance;
      // Try to load existing end of collection data first
      if (_coverData.id != null) {
        endOfCollectionData = await db.getEndOfCollection(_coverData.id!);
      }
      
      // If no data exists or we need to update, get from current state
      if (endOfCollectionData == null) {
        final endState = _endOfCollectionKey.currentState;
        if (endState != null) {
          final rawData = endState.getData();
          if (rawData != null && rawData is Map<String, dynamic>) {
            endOfCollectionData = EndOfCollectionModel.fromMap(rawData).copyWith(
              coverPageId: _coverData.id,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );
            debugPrint('✅ End of collection data retrieved from form state');
          }
        }
      } else {
        debugPrint('✅ End of collection data loaded from database: ${endOfCollectionData.id}');
      }
      
      // Debug log what we have
      if (endOfCollectionData != null) {
        debugPrint('📊 End of Collection Data:');
        debugPrint('   - Respondent Image: ${endOfCollectionData.respondentImagePath}');
        debugPrint('   - Signature: ${endOfCollectionData.producerSignaturePath}');
        debugPrint('   - GPS: ${endOfCollectionData.gpsCoordinates}');
        debugPrint('   - End Time: ${endOfCollectionData.endTime}');
      } else {
        debugPrint('⚠️ No end of collection data available');
      }
    } catch (e) {
      debugPrint('❌ Error getting end of collection data: $e');
    }
  
      
      // 7. Log what we have
      debugPrint('\n📊 FINAL DATA SUMMARY:');
      debugPrint('   • Cover Page: ${_coverData.id != null ? '✅' : '❌'}');
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
        combinedFarm: combinedFarmData,
        childrenHousehold: childrenHouseholdData,
        remediation: remediationData,
        sensitization: sensitizationData,
        sensitizationQuestions: sensitizationQuestionsData,
        endOfCollection: endOfCollectionData,
      );
      
      if (success) {
        _showSnackBar('Survey completed and saved successfully!', backgroundColor: Colors.green);
        _showSaveSummary();
        
        widget.onComplete?.call();
        if (mounted) {
          Navigator.popUntil(context, (r) => r.isFirst);
        }
      } else {
        _showSnackBar('Failed to save survey data');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error completing survey: $e');
      debugPrint('📜 Stack trace: $stackTrace');
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
      'Cover Page', 
      'Consent Form', 
      'Farmer Identification', 
      'Farm Details',
      'Children in Household', 
      'Child $_currentChildNumber of $_totalChildren5To17 Details',
      'Remediation', 
      'Sensitization', 
      'Sensitization Questions', 
      'End of Collection'
    ];
    return titles[index];
  }

  void _showSnackBar(String msg, {Color? backgroundColor, SnackBarAction? action}) {
    if (_isDisposed) return;
    
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: backgroundColor,
        action: action,
      ),
    );
  }
  
  void _showErrorSnackBar(String message) {
    _showSnackBar(
      message,
      backgroundColor: Colors.red[700],
    );
  }
  
  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// Debug method to check the current state of form data
  void _debugCheckData() {
    debugPrint('\n🔍 DEBUG DATA CHECK:');
    debugPrint('Cover Page ID: ${_coverData.id}');
    
    // Check combined farm
    final combinedState = _combinedPageKey.currentState;
    if (combinedState != null) {
      final combinedData = combinedState.getCombinedData();
      debugPrint('Combined Farm State: ${combinedData != null}');
      if (combinedData != null) {
        debugPrint('  - Visit Info: ${combinedData.visitInformation != null}');
        debugPrint('  - Owner Info: ${combinedData.ownerInformation != null}');
        debugPrint('  - Workers Info: ${combinedData.workersInFarm != null}');
        debugPrint('  - Adults Info: ${combinedData.adultsInformation != null}');
      }
    }
    
    // Check sensitization questions
    final questionsState = _sensitizationQuestionsKey.currentState;
    if (questionsState != null) {
      debugPrint('Sensitization Questions State: ${questionsState.validateForm(silent: true)}');
    }
  }
  
  /// Validates the form with comprehensive error tracking
  bool validateForm({bool silent = false}) {
    final errors = getValidationErrors();
    
    // Show first error if not in silent mode
    if (!silent && errors.isNotEmpty) {
      _showErrorSnackBar(errors.first);
      // Also log all errors for debugging
      debugPrint('🔍 Validation errors: $errors');
    }
    
    return errors.isEmpty;
  }

  /// Helper method to get validation errors without showing snackbar
  List<String> getValidationErrors() {
    final errors = <String>[];
    
    // Track exactly which fields are missing
    if (hasSensitizedHousehold == null) {
      errors.add('Please indicate if you have sensitized the household members');
    }
    
    if (hasSensitizedOnProtection == null) {
      errors.add('Please indicate if you have sensitized on protection');
    }
    
    if (hasSensitizedOnSafeLabour == null) {
      errors.add('Please indicate if you have sensitized on safe labor');
    }
    
    // Make adult counts optional or provide default values
    final femaleCount = _femaleAdultsController.text.trim().isEmpty 
        ? 0 
        : int.tryParse(_femaleAdultsController.text.trim()) ?? 0;
    final maleCount = _maleAdultsController.text.trim().isEmpty 
        ? 0 
        : int.tryParse(_maleAdultsController.text.trim()) ?? 0;
    
    if (femaleCount < 0) {
      errors.add('Please enter a valid number for female adults');
    }
    
    if (maleCount < 0) {
      errors.add('Please enter a valid number for male adults');
    }
    
    if (_consentForPicture == null) {
      errors.add('Please indicate if consent for picture was given');
    } else if (_consentForPicture == false && _consentReasonController.text.trim().isEmpty) {
      errors.add('Please provide a reason for not giving consent');
    }
    
    // Image validation only if consent was given AND sensitization was done
    if (_consentForPicture == true && hasSensitizedHousehold == true) {
      if (_sensitizationImage == null) {
        errors.add('Please take a sensitization session picture');
      }
      
      if (_householdWithUserImage == null) {
        errors.add('Please take a picture with the household');
      }
    }
    
    if (_reactionController.text.trim().isEmpty) {
      errors.add('Please provide your observations about parents\' reactions');
    }
    
    return errors;
  }

  /// Enhanced save method with better error handling
  Future<bool> saveData([int? coverPageId]) async {
    if (_isDisposed || _isSaving) {
      debugPrint('⚠️ Save operation prevented - already saving or disposed');
      return false;
    }
    
    _isSaving = true;
    
    try {
      final effectiveCoverPageId = coverPageId ?? _coverData.id;
      
      if (effectiveCoverPageId == null) {
        _showErrorSnackBar('Error: Missing cover page ID');
        return false;
      }

      // Validate form before saving - use silent mode to avoid duplicate messages
      if (!validateForm(silent: true)) {
        final errors = getValidationErrors();
        if (errors.isNotEmpty) {
          _showErrorSnackBar(errors.first);
        }
        return false;
      }

     final questionsDao = SensitizationQuestionsDao(dbHelper: LocalDBHelper.instance);
      final now = DateTime.now();
      
      // Check if record exists
      final existingRecord = await questionsDao.getByCoverPageId(effectiveCoverPageId);
      
      // Use default values for empty fields
      final femaleCount = _femaleAdultsController.text.trim().isEmpty 
          ? "0" 
          : _femaleAdultsController.text.trim();
      final maleCount = _maleAdultsController.text.trim().isEmpty 
          ? "0" 
          : _maleAdultsController.text.trim();
      
      // Create the model with ALL required fields
      final model = SensitizationQuestionsData(
        id: existingRecord?.id,
        coverPageId: effectiveCoverPageId,
        hasSensitizedHousehold: hasSensitizedHousehold ?? false,
        hasSensitizedOnProtection: hasSensitizedOnProtection ?? false,
        hasSensitizedOnSafeLabour: hasSensitizedOnSafeLabour ?? false,
        femaleAdultsCount: femaleCount,
        maleAdultsCount: maleCount,
        consentForPicture: _consentForPicture ?? false,
        consentReason: _consentForPicture == true ? 'Consent given' : _consentReasonController.text.trim(),
        sensitizationImagePath: _sensitizationImage?.path,
        householdWithUserImagePath: _householdWithUserImage?.path,
        parentsReaction: _reactionController.text.trim(),
        submittedAt: existingRecord?.submittedAt ?? now,
        createdAt: existingRecord?.createdAt ?? now,
        updatedAt: now,
        isSynced: false,
        syncStatus: 0,
      );

      debugPrint('� Saving sensitization questions: ${model.toMap()}');

      // Save to database
      int result;
      if (existingRecord == null) {
        result = await questionsDao.insert(model, effectiveCoverPageId);
        debugPrint('✅ Inserted new sensitization questions with ID: $result');
      } else {
        result = await questionsDao.update(model, effectiveCoverPageId);
        debugPrint('✅ Updated sensitization questions, rows affected: $result');
      }
      
      _showSuccessSnackBar('Sensitization questions saved successfully!');
      return result > 0;
      
    } catch (e, stackTrace) {
      debugPrint('❌ Error saving sensitization questions: $e');
      debugPrint('Stack trace: $stackTrace');
      
      _showErrorSnackBar('Failed to save sensitization questions. Please try again.');
      return false;
    } finally {
      _isSaving = false;
    }
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
      remediationData = null;
    });

    SharedPreferences.getInstance().then((p) {
      p.remove('selected_town');
      p.remove('selected_farmer');
    });
  }

  // Helper method to update both cover data and farmer data
  void _updateCoverData(CoverPageData newCoverData) {
    safeSetState(() {
      _coverData = newCoverData;
      if (newCoverData.id != null) {
        _farmerData = _farmerData.copyWith(coverPageId: newCoverData.id);
      }
    });
  }

  Future<void> _loadSavedState() async {
    try {
      if (widget.coverPageId != 0) {
        // If we have a coverPageId from the widget, use it
        debugPrint('Using coverPageId from widget: ${widget.coverPageId}');
        _updateCoverData(_coverData.copyWith(id: widget.coverPageId));
        _initFarmerData(); // Initialize farmer data after setting cover page ID
        return;
      }

      // If no coverPageId is provided, create a new one
      final db = await HouseholdDBHelper.instance.database;
      
      // Create a new cover page entry with default values
      final coverPage = CoverPageData(
        id: null, // Let the database auto-generate the ID
        selectedTownCode: _coverData.selectedTownCode,
        towns: _coverData.towns,
        farmers: _coverData.farmers,
        hasUnsavedChanges: true, // Mark as having unsaved changes
      );
      
      // Save the cover page to get an ID
      final coverPageId = await db.insert(
        TableNames.coverPageTBL,
        coverPage.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      if (mounted) {
        _updateCoverData(_coverData.copyWith(id: coverPageId));
        _initFarmerData(); // Initialize farmer data after setting cover page ID
      }
      
      debugPrint('Created new cover page with ID: $coverPageId');
    } catch (e) {
      debugPrint('Error in _loadSavedState: $e');
    }
  }

  Widget _buildLoadingPage(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(message),
        ],
      ),
    );
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
                  // Only show consent if cover page has been saved
                  _coverData.id != null
                      ? ConsentPage(
                          key: _consentPageKey,
                          data: _consentData ?? ConsentData.empty().copyWith(coverPageId: _coverData.id),
                          onDataChanged: _onConsentDataChanged,
                          onRecordTime: _recordInterviewTime,
                          onGetLocation: _getCurrentLocation,
                          onNext: _onNext,
                          onPrevious: _onPrevious,
                          onSurveyEnd: _onSurveyEnd,
                        )
                      : _buildLoadingPage('Preparing Consent Form...'),
                  FarmerIdentification1Page(
                    key: _farmerPageKey,
                    data: _farmerData,
                    onDataChanged: _onFarmerDataChanged,
                    onNext: _onNext,
                  ),
                  // Combined farm page requires cover page ID
                  _coverData.id != null
                      ? CombinedFarmIdentificationPage(
                          key: _combinedPageKey,
                          coverPageId: _coverData.id!,
                          initialPageIndex: _combinedPageSubIndex,
                          onPageChanged: (i) => safeSetState(() => _combinedPageSubIndex = i),
                          onPrevious: _onPrevious,
                          onNext: _onNext,
                          onSubmit: _handleCombinedPageSubmit,
                        )
                      : _buildLoadingPage('Loading Farm Details...'),
                  ChildrenHouseholdPage(
                    key: _childrenHouseholdKey,
                    formKey: _childrenHouseholdFormKey,
                    producerDetails: {
                      'ghanaCardNumber': _farmerData.ghanaCardNumberController.text,
                      'contactNumber': _farmerData.contactNumberController.text,
                    },
                    children5To17Controller: _farmerData.childrenCountController,
                    onPrevious: _onPrevious,
                    onNext: _onNext,
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
                    coverPageId: _coverData.id ?? 0,
                  ),
                // Replace the SensitizationPage in your PageView children:
SensitizationPage(
  key: _sensitizationPageKey,
  coverPageId: _coverData.id ?? 0,
  sensitizationData: SensitizationData(
    coverPageId: _coverData.id,
    isAcknowledged: _isSensitizationChecked,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
  onSensitizationChanged: (SensitizationData newData) {
    safeSetState(() {
      _isSensitizationChecked = newData.isAcknowledged;
    });
  },
  onNext: _onNext, // Add navigation callbacks
  onPrevious: _onPrevious,
),
                  SensitizationQuestionsPage(
                    key: _sensitizationQuestionsKey,
                    onNext: _onNext,
                    onPrevious: _onPrevious,
                    coverPageId: _coverData.id ?? 0,
                  ),
                  EndOfCollectionPage(
                    key: _endOfCollectionKey,
                    householdDBHelper: HouseholdDBHelper.instance,
                    onPrevious: _onPrevious,
                    onComplete: _onNext,
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