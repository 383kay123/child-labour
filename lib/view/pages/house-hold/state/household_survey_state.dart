import 'package:flutter/material.dart';
import 'package:human_rights_monitor/controller/models/consent_model.dart';
import 'package:human_rights_monitor/controller/models/household_models.dart';
import 'package:human_rights_monitor/controller/models/farmeridentification_model.dart';

class HouseholdSurveyState extends ChangeNotifier {
  // Form data
  CoverPageData _coverData = CoverPageData.empty();
  ConsentData? _consentData;
  FarmerIdentificationData _farmerData;
  
  // Navigation state
  int _currentPageIndex = 0;
  int _currentChildNumber = 1;
  int _totalChildren5To17 = 0;
  List<dynamic> _childrenDetails = [];
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
  List<dynamic> get childrenDetails => _childrenDetails;
  bool get showChildDetailsPage => _showChildDetailsPage;
  bool get isSubmitted => _isSubmitted;
  bool get isSensitizationChecked => _isSensitizationChecked;

  HouseholdSurveyState() : _farmerData = FarmerIdentificationData(
    ghanaCardNumberController: TextEditingController(),
    idNumberController: TextEditingController(),
    contactNumberController: TextEditingController(),
    childrenCountController: TextEditingController(),
    noConsentReasonController: TextEditingController(),
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
    _childrenDetails = value;
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
      ghanaCardNumberController: TextEditingController(),
      idNumberController: TextEditingController(),
      contactNumberController: TextEditingController(),
      childrenCountController: TextEditingController(),
      noConsentReasonController: TextEditingController(),
    );
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
    // Dispose controllers
    _farmerData.ghanaCardNumberController.dispose();
    _farmerData.idNumberController.dispose();
    _farmerData.contactNumberController.dispose();
    _farmerData.childrenCountController.dispose();
    _farmerData.noConsentReasonController.dispose();
    super.dispose();
  }
}
