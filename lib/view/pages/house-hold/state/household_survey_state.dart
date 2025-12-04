import 'package:flutter/material.dart';

import 'package:human_rights_monitor/controller/models/household_models.dart';


class HouseholdSurveyState extends ChangeNotifier {
  // Form data
  CoverPageData _coverData = CoverPageData.empty();
  ConsentData? _consentData;
  FarmerIdentificationData _farmerData;
  
  // Form controllers
  final TextEditingController ghanaCardNumberController = TextEditingController();
  final TextEditingController idNumberController = TextEditingController();
  final TextEditingController contactNumberController = TextEditingController();
  final TextEditingController childrenCountController = TextEditingController();
  final TextEditingController noConsentReasonController = TextEditingController();
  
  // Navigation state
  int _currentPageIndex = 0;
  int _currentChildNumber = 1;
  int _totalChildren5To17 = 0;
  List<Map<String, dynamic>> _childrenDetails = [];
  bool _showChildDetailsPage = false;
  bool _isSubmitted = false;
  bool _isSensitizationChecked = false;
  
  // Getters
  CoverPageData get coverData => _coverData;
  ConsentData? get consentData => _consentData;
  FarmerIdentificationData get farmerData => _farmerData;
  int get currentPageIndex => _currentPageIndex;
  int get currentChildNumber => _currentChildNumber;
  int get totalChildren5To17 => _totalChildren5To17;
  List<Map<String, dynamic>> get childrenDetails => _childrenDetails;
  bool get showChildDetailsPage => _showChildDetailsPage;
  bool get isSubmitted => _isSubmitted;
  bool get isSensitizationChecked => _isSensitizationChecked;

  HouseholdSurveyState() : _farmerData = FarmerIdentificationData(
    hasGhanaCard: 0,
    childrenCount: 0,
    idPictureConsent: 0,
    isSynced: 0,
    syncStatus: 0,
  );

  // Setters with notifyListeners()
  set coverData(CoverPageData value) {
    _coverData = value;
    notifyListeners();
  }

  set consentData(ConsentData? value) {
    _consentData = value;
    notifyListeners();
  }

  set farmerData(FarmerIdentificationData value) {
    _farmerData = value;
    notifyListeners();
  }

  set currentPageIndex(int value) {
    _currentPageIndex = value;
    notifyListeners();
  }

  set currentChildNumber(int value) {
    _currentChildNumber = value;
    notifyListeners();
  }

  set totalChildren5To17(int value) {
    _totalChildren5To17 = value;
    notifyListeners();
  }

  set childrenDetails(List<dynamic> value) {
    _childrenDetails = value.cast<Map<String, dynamic>>().toList();
    notifyListeners();
  }

  set showChildDetailsPage(bool value) {
    _showChildDetailsPage = value;
    notifyListeners();
  }

  set isSubmitted(bool value) {
    _isSubmitted = value;
    notifyListeners();
  }

  set isSensitizationChecked(bool value) {
    _isSensitizationChecked = value;
    notifyListeners();
  }

  // Helper methods
  void resetCoverData() {
    _coverData = CoverPageData.empty();
    notifyListeners();
  }

  void addChildDetail(dynamic childDetail) {
    _childrenDetails.add(childDetail);
    notifyListeners();
  }

  void updateChildDetail(int index, dynamic childDetail) {
    if (index >= 0 && index < _childrenDetails.length) {
      _childrenDetails[index] = childDetail;
      notifyListeners();
    }
  }

  void removeChildDetail(int index) {
    if (index >= 0 && index < _childrenDetails.length) {
      _childrenDetails.removeAt(index);
      notifyListeners();
    }
  }

  void resetForm() {
    _coverData = CoverPageData.empty();
    _consentData = null;
    _farmerData = FarmerIdentificationData(
      hasGhanaCard: 0,
      childrenCount: 0,
      idPictureConsent: 0,
      isSynced: 0,
      syncStatus: 0,
    );
    
    // Clear all controllers
    ghanaCardNumberController.clear();
    idNumberController.clear();
    contactNumberController.clear();
    childrenCountController.clear();
    noConsentReasonController.clear();
    
    _currentPageIndex = 0;
    _currentChildNumber = 1;
    _totalChildren5To17 = 0;
    _childrenDetails = [];
    _showChildDetailsPage = false;
    _isSubmitted = false;
    _isSensitizationChecked = false;
    notifyListeners();
  }

  @override
  void dispose() {
    // Dispose all controllers
    ghanaCardNumberController.dispose();
    idNumberController.dispose();
    contactNumberController.dispose();
    childrenCountController.dispose();
    noConsentReasonController.dispose();
    super.dispose();
  }
}
