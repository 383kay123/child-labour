import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:human_rights_monitor/controller/db/daos/sensitization_questions_dao.dart';
import 'package:human_rights_monitor/controller/db/daos/remediation_dao.dart';
import 'package:human_rights_monitor/controller/db/db_tables/repositories/districts_repo.dart';
import 'package:human_rights_monitor/controller/db/db_tables/repositories/farmers_repo.dart';
import 'package:human_rights_monitor/controller/db/db.dart';
import 'package:human_rights_monitor/controller/db/db_tables/helpers/household_db_helper.dart';
import 'package:human_rights_monitor/controller/models/survey_summary.dart';
import 'package:sqflite/sqflite.dart';
import 'package:human_rights_monitor/controller/db/db_tables/helpers/household_db_helper.dart';
import 'package:human_rights_monitor/controller/db/table_names.dart';
import 'package:human_rights_monitor/controller/models/household_models.dart';
import 'package:human_rights_monitor/controller/api/get_methods.dart';
import 'package:human_rights_monitor/controller/db/household_tables.dart';
import 'package:human_rights_monitor/view/screen_wrapper/screen_wrapper.dart';
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
  bool _isLoading = false;
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
      selectedTownCode: null,
      towns: const [],
      farmers: const [],
    );

    // Initialize with the provided coverPageId
    if (widget.coverPageId != 0) {
      _coverData = _coverData.copyWith(id: widget.coverPageId);
    }
    
    _initFarmerData();
    _loadDistricts();
    _loadFarmers();
    _loadSavedState();
    
    // Check for duplicates on startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForDuplicateSurveys();
    });
  }

  Future<void> _loadDistricts() async {
    if (!_canUseContext) return;
    
    setState(() {
      _isLoading = true;
      _coverData = _coverData.copyWith(
        isLoadingTowns: true,
        townError: null,
      );
    });
    
    try {
      final districtRepo = DistrictRepository();
      final districts = await districtRepo.getDistrictsOrderByName();
      
      if (_canUseContext) {
        setState(() {
          _coverData = _coverData.copyWith(
            towns: districts.map((district) => DropdownItem(
              code: district.districtCode,
              name: district.district,
            )).toList(),
            isLoadingTowns: false,
          );
        });
      }
    } catch (e) {
      debugPrint('Error loading districts: $e');
      if (_canUseContext) {
        setState(() {
          _coverData = _coverData.copyWith(
            townError: 'Failed to load districts. Please try again.',
            isLoadingTowns: false,
          );
        });
      }
    } finally {
      if (_canUseContext) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  Future<void> _loadFarmers() async {
    if (!_canUseContext) return;
    
    setState(() {
      _isLoading = true;
      _coverData = _coverData.copyWith(
        isLoadingFarmers: true,
        farmerError: null,
      );
    });
    
    try {
      final farmerRepo = FarmerRepository();
      debugPrint('🔄 Loading first 10 farmers...');
      final farmers = await farmerRepo.getFirst10Farmers();
      debugPrint('✅ Loaded ${farmers.length} farmers');
      
      if (_canUseContext) {
        setState(() {
          _coverData = _coverData.copyWith(
            farmers: farmers.map((farmer) => DropdownItem(
              code: farmer.farmerCode,
              name: '${farmer.firstName} ${farmer.lastName}'.trim(),
            )).toList(),
            isLoadingFarmers: false,
          );
        });
        debugPrint('ℹ️ Updated coverData with ${farmers.length} farmers');
      }
    } catch (e) {
      debugPrint('❌ Error loading farmers: $e');
      if (_canUseContext) {
        setState(() {
          _coverData = _coverData.copyWith(
            farmerError: 'Failed to load farmers. Please try again.',
            isLoadingFarmers: false,
          );
        });
      }
    } finally {
      if (_canUseContext) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
      
      // If we already have an ID, UPDATE the record
      if (_coverData.id != null) {
        final db = await HouseholdDBHelper.instance.database;
        final data = _coverData.toMap();
        data['updated_at'] = DateTime.now().toIso8601String(); // Add current timestamp
        final rowsAffected = await db.update(
          TableNames.coverPageTBL,
          data,
          where: 'id = ?',
          whereArgs: [_coverData.id],
        );
        
        if (rowsAffected > 0) {
          debugPrint('✅ Cover page updated with ID: ${_coverData.id}');
          _savedData['cover_page'] = _coverData.toMap();
          _showSnackBar('Cover page updated successfully', backgroundColor: Colors.green);
          return true;
        } else {
          _showSnackBar('Failed to update cover page');
          return false;
        }
      } else {
        // Only create new record if we don't have an ID
        final coverPageId = await _saveCoverPageData();
        if (coverPageId == null) {
          _showSnackBar('Failed to save cover page data');
          return false;
        }
        safeSetState(() {
          _coverData = _coverData.copyWith(id: coverPageId);
        });
        _savedData['cover_page'] = _coverData.toMap();
        _showSnackBar('Cover page saved successfully', backgroundColor: Colors.green);
        return true;
      }
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

      // Get the current consent page state
      final consentState = _consentPageKey.currentState;
      if (consentState == null) {
        _showSnackBar('Error: Could not validate form');
        return false;
      }

      // Run validation
      final validationError = consentState.validateForm();
      if (validationError != null) {
        _showSnackBar(validationError);
        return false;
      }

      // Save the data
      final saved = await consentState.saveData();
      if (!saved) {
        _showSnackBar('Failed to save consent form');
        return false;
      }

      _savedData['consent'] = 'saved';
      _showSnackBar('Consent saved successfully', backgroundColor: Colors.green);
      return true;
    } catch (e) {
      debugPrint('❌ Error saving consent: $e');
      _showSnackBar('Error saving consent: ${e.toString()}');
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
    if (_childrenHouseholdKey.currentState == null) {
      _showSnackBar('Error: Could not save children household data');
      return false;
    }

    // Ensure cover page is saved first
    if (_coverData.id == null) {
      final success = await _saveCoverPage();
      if (!success) return false;
    }

    // Save the form data
    await _childrenHouseholdKey.currentState!.saveFormData();
    
    // Get the current data
    final childrenHousehold = _childrenHouseholdKey.currentState!.getHouseholdData();
    
    // Update with the current cover page ID
    final updatedHousehold = childrenHousehold.copyWith(
      coverPageId: _coverData.id,
    );

    // Save to database
    try {
      debugPrint('💾 Saving children household with coverPageId: ${_coverData.id}');
      debugPrint('📋 Children 5-17 count: ${updatedHousehold.children5To17}');
      
      await HouseholdDBHelper.instance.insertChildrenHousehold(updatedHousehold);
      
      // Get the count directly from the form data
      final count = updatedHousehold.children5To17 ?? 0;
      
      safeSetState(() {
        _totalChildren5To17 = count;
        _currentChildNumber = 1;
      });
      
      _savedData['children_household'] = {
        'children_count': count,
        'total_children_5_to_17': _totalChildren5To17
      };
      
      _showSnackBar('Children household data saved successfully', backgroundColor: Colors.green);
      return true;
    } catch (e) {
      debugPrint('❌ Error saving children household data: $e');
      _showErrorSnackBar('Failed to save children household data');
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
      debugPrint('🔄 [Sensitization Questions] Starting save process...');
      debugPrint('🔍 [Sensitization Questions] Using coverPageId: ${_coverData.id}');
      debugPrint('🔍 [Sensitization Questions] _coverData: ${_coverData.toMap()}');

      final state = _sensitizationQuestionsKey.currentState;
      if (state == null) {
        debugPrint('❌ [Sensitization Questions] State is null');
        _showSnackBar('Sensitization questions page not initialized');
        return false;
      }

      // Save using cover page ID
      debugPrint('💾 [Sensitization Questions] Calling saveData with coverPageId: ${_coverData.id}');
      final saved = await state.saveData(_coverData.id!);
      
      if (!saved) {
        debugPrint('❌ [Sensitization Questions] Save failed - validation error');
        _showSnackBar('Please complete all sensitization questions');
        return false;
      }
      
      _savedData['sensitization_questions'] = {
        'cover_page_id': _coverData.id,
        'saved_at': DateTime.now().toIso8601String(),
      };
      
      debugPrint('✅ [Sensitization Questions] Saved successfully with coverPageId: ${_coverData.id}');
      debugPrint('📋 [Sensitization Questions] Saved data: ${_savedData['sensitization_questions']}');
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

  // Fixed onNext method - NO duplicate complete survey calls
  Future<void> _onNext() async {
    if (_isProcessingNavigation) return;
    _isProcessingNavigation = true;

    try {
      bool shouldNavigate = true;
      
      switch (_currentPageIndex) {
        case 0: // Cover Page
          await _saveCoverPage();
          break;
        case 1: // Consent
          await _saveConsent();
          break;
        case 2: // Farmer
          await _saveFarmerIdentification();
          break;
        case 3: // Combined Farm
          final state = _combinedPageKey.currentState;
          if (state != null) {
            // First, validate and save the current page
            if (!state.validateCurrentPage()) {
              _showSnackBar('Please complete all required fields on this page');
              _isProcessingNavigation = false;
              return;
            }
            
            // Save the current page data
            await state.saveCurrentPageData();
            
            // Define the subpages in order
            final pageController = state.pageController;
            final currentIndex = state.currentPageIndex;
            
            // If not on the last page, go to next subpage
            if (currentIndex < 3) { // 3 is the index of the last subpage (0-3 for 4 pages)
              await pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
              _isProcessingNavigation = false;
              return;
            }
            
            // If we're on the last page, save the combined farm data and proceed
            await _saveCombinedFarm();
          }
          break;
        case 4: // Children Household
          await _saveChildrenHousehold();
          final count = int.tryParse(_farmerData.childrenCountController.text) ?? 0;
          if (count > 0) {
            await _navigateToPage(5); // Go to child details
            shouldNavigate = false;
          } else {
            await _navigateToPage(6); // Skip to remediation
            shouldNavigate = false;
          }
          break;
        case 5: // Child Details
          await _saveChildDetails();
          if (_currentChildNumber < _totalChildren5To17) {
            safeSetState(() => _currentChildNumber++);
            _refreshChildDetailsPage();
            shouldNavigate = false;
          } else {
            await _navigateToPage(6); // Go to remediation
            shouldNavigate = false;
          }
          break;
        case 6: // Remediation
          await _saveRemediation();
          break;
        case 7: // Sensitization
          await _saveSensitization();
          break;
        case 8: // Sensitization Questions
          await _saveSensitizationQuestions();
          break;
        case 9: // End - ONLY save end of collection, NOT complete survey
          await _saveEndOfCollection();
          _showSurveyCompleteDialog();
          shouldNavigate = false;
          break;
      }

      // Only navigate if we're not handling navigation manually
      if (shouldNavigate && _currentPageIndex < _totalPages - 1) {
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

  // Survey completion dialog
  void _showSurveyCompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Survey Complete'),
        content: const Text('Your survey has been successfully saved.'),
        actions: [
          TextButton(
            onPressed: () {
              // Close the dialog
              Navigator.of(context).pop();
              
              // Call the completion callback
              widget.onComplete?.call();
              
              // Navigate to home using ScreenWrapper
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const ScreenWrapper()),
                (route) => false, // This removes all previous routes
              );
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
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

  // Check for duplicate surveys
  void _checkForDuplicateSurveys() async {
    try {
      final db = HouseholdDBHelper.instance;
      final surveys = await db.getAllSurveys();
      
      // Group by farmer/town to find duplicates
      final Map<String, List<SurveySummary>> grouped = {};
      
      for (var survey in surveys) {
        final key = '${survey.farmerName}-${survey.community}';
        if (!grouped.containsKey(key)) {
          grouped[key] = [];
        }
        grouped[key]!.add(survey);
      }
      
      // Log duplicates
      grouped.forEach((key, surveys) {
        if (surveys.length > 1) {
          debugPrint('🚨 DUPLICATE FOUND: $key (${surveys.length} surveys)');
          for (var survey in surveys) {
            debugPrint('   - ID: ${survey.id}, Date: ${survey.submissionDate}');
          }
        }
      });
    } catch (e) {
      debugPrint('Error checking duplicates: $e');
    }
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
      final existingRecords = await questionsDao.getByCoverPageId(effectiveCoverPageId);
      final existingRecord = existingRecords.isNotEmpty ? existingRecords.first : null;
      
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

      debugPrint('💾 Saving sensitization questions: ${model.toMap()}');

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
        
        // Load saved children data
        final db = await HouseholdDBHelper.instance.database;
        final childrenData = await db.query(
          TableNames.childrenHouseholdTBL,
          where: 'cover_page_id = ?',
          whereArgs: [widget.coverPageId],
        );
        
        if (childrenData.isNotEmpty) {
          final savedChildrenCount = childrenData.first['children_count'] as int? ?? 0;
          safeSetState(() {
            _totalChildren5To17 = savedChildrenCount;
            _currentChildNumber = 1;
          });
          _farmerData.childrenCountController.text = savedChildrenCount.toString();
          debugPrint('✅ Loaded saved children data: $savedChildrenCount children');
        }
        
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
      debugPrint('❌ Error in _loadSavedState: $e');
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
                    onDataChanged: (newData) {
                      // Update the cover data
                      safeSetState(() => _coverData = newData);
                    },
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
                    onNext: _onNext,
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
}