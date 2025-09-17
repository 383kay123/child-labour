import 'package:flutter/material.dart';
import '../../models/monitoring_model.dart';

class RemediationFormController with ChangeNotifier {
  final MonitoringModel _formData = MonitoringModel();
  // final StorageService _storageService = StorageService();

  // Text editing controllers for all text fields
  final TextEditingController childIdController = TextEditingController();
  final TextEditingController childNameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController sexController = TextEditingController();
  final TextEditingController communityController = TextEditingController();
  final TextEditingController farmerIdController = TextEditingController();
  final TextEditingController firstRemediationDateController = TextEditingController();
  final TextEditingController remediationFormProvidedController = TextEditingController();
  final TextEditingController followUpVisitsCountController = TextEditingController();
  final TextEditingController classAtRemediationController = TextEditingController();
  final TextEditingController promotedGradeController = TextEditingController();
  final TextEditingController recommendationsController = TextEditingController();
  final TextEditingController noBirthCertificateReasonController = TextEditingController();
  final TextEditingController additionalCommentsController = TextEditingController();
  final TextEditingController followUpVisitsCountSinceIdentificationController = TextEditingController();

  RemediationFormController() {
    // Load saved data if available
    // loadFormData();
  }

  // Load form data from storage
  // Future<void> loadFormData() async {
  //   final formData = await _storageService.loadFormData();
  //   if (formData != null) {
  //     _updateFormData(formData);
  //     _updateControllersFromData();
  //     notifyListeners();
  //   }
  // }

  // Update form data from loaded data
  void _updateFormData(MonitoringModel formData) {
    _formData.childId = formData.childId;
    _formData.childName = formData.childName;
    _formData.age = formData.age;
    _formData.sex = formData.sex;
    _formData.community = formData.community;
    _formData.farmerId = formData.farmerId;
    _formData.firstRemediationDate = formData.firstRemediationDate;
    _formData.remediationFormProvided = formData.remediationFormProvided;
    _formData.followUpVisitsCount = formData.followUpVisitsCount;
    _formData.isEnrolledInSchool = formData.isEnrolledInSchool;
    _formData.attendanceImproved = formData.attendanceImproved;
    _formData.receivedSchoolMaterials = formData.receivedSchoolMaterials;
    _formData.canReadWriteBasicText = formData.canReadWriteBasicText;
    _formData.advancedToNextGrade = formData.advancedToNextGrade;
    _formData.classAtRemediation = formData.classAtRemediation;
    _formData.academicYearEnded = formData.academicYearEnded;
    _formData.promoted = formData.promoted;
    _formData.promotedGrade = formData.promotedGrade;
    _formData.improvementInSkills = formData.improvementInSkills;
    _formData.recommendations = formData.recommendations;
    _formData.engagedInHazardousWork = formData.engagedInHazardousWork;
    _formData.reducedWorkHours = formData.reducedWorkHours;
    _formData.involvedInLightWork = formData.involvedInLightWork;
    _formData.outOfHazardousWork = formData.outOfHazardousWork;
    _formData.hasBirthCertificate = formData.hasBirthCertificate;
    _formData.birthCertificateProcess = formData.birthCertificateProcess;
    _formData.noBirthCertificateReason = formData.noBirthCertificateReason;
    _formData.receivedAwarenessSessions = formData.receivedAwarenessSessions;
    _formData.improvedUnderstanding = formData.improvedUnderstanding;
    _formData.caregiversSupportSchool = formData.caregiversSupportSchool;
    _formData.receivedFinancialSupport = formData.receivedFinancialSupport;
    _formData.referralsMade = formData.referralsMade;
    _formData.ongoingFollowUpPlanned = formData.ongoingFollowUpPlanned;
    _formData.consideredRemediated = formData.consideredRemediated;
    _formData.additionalComments = formData.additionalComments;
    _formData.followUpVisitsCountSinceIdentification = formData.followUpVisitsCountSinceIdentification;
    _formData.visitsSpacedCorrectly = formData.visitsSpacedCorrectly;
    _formData.confirmedNotInChildLabour = formData.confirmedNotInChildLabour;
    _formData.followUpCycleComplete = formData.followUpCycleComplete;
  }

  // Update controllers from loaded data
  void _updateControllersFromData() {
    childIdController.text = _formData.childId;
    childNameController.text = _formData.childName;
    ageController.text = _formData.age;
    sexController.text = _formData.sex;
    communityController.text = _formData.community;
    farmerIdController.text = _formData.farmerId;
    firstRemediationDateController.text = _formData.firstRemediationDate;
    remediationFormProvidedController.text = _formData.remediationFormProvided;
    followUpVisitsCountController.text = _formData.followUpVisitsCount;
    classAtRemediationController.text = _formData.classAtRemediation;
    promotedGradeController.text = _formData.promotedGrade ?? '';
    recommendationsController.text = _formData.recommendations ?? '';
    noBirthCertificateReasonController.text = _formData.noBirthCertificateReason ?? '';
    additionalCommentsController.text = _formData.additionalComments;
    followUpVisitsCountSinceIdentificationController.text = _formData.followUpVisitsCountSinceIdentification;
  }

  // Save form data to storage
  Future<void> saveFormData() async {
    // Update form data from controllers before saving
    _updateFormDataFromControllers();
    // await _storageService.saveFormData(_formData);
    notifyListeners();
  }

  // Update form data from controllers
  void _updateFormDataFromControllers() {
    _formData.childId = childIdController.text;
    _formData.childName = childNameController.text;
    _formData.age = ageController.text;
    _formData.sex = sexController.text;
    _formData.community = communityController.text;
    _formData.farmerId = farmerIdController.text;
    _formData.firstRemediationDate = firstRemediationDateController.text;
    _formData.remediationFormProvided = remediationFormProvidedController.text;
    _formData.followUpVisitsCount = followUpVisitsCountController.text;
    _formData.classAtRemediation = classAtRemediationController.text;
    _formData.promotedGrade = promotedGradeController.text;
    _formData.recommendations = recommendationsController.text;
    _formData.noBirthCertificateReason = noBirthCertificateReasonController.text;
    _formData.additionalComments = additionalCommentsController.text;
    _formData.followUpVisitsCountSinceIdentification = followUpVisitsCountSinceIdentificationController.text;
  }

  // Submit form (could be extended to send to server)
  Future<bool> submitForm() async {
    _updateFormDataFromControllers();
    // Here you would typically send data to a server
    // For now, we'll just save locally
    await saveFormData();
    return true;
  }

  // Clear form data
  Future<void> clearForm() async {
    childIdController.clear();
    childNameController.clear();
    ageController.clear();
    sexController.clear();
    communityController.clear();
    farmerIdController.clear();
    firstRemediationDateController.clear();
    remediationFormProvidedController.clear();
    followUpVisitsCountController.clear();
    classAtRemediationController.clear();
    promotedGradeController.clear();
    recommendationsController.clear();
    noBirthCertificateReasonController.clear();
    additionalCommentsController.clear();
    followUpVisitsCountSinceIdentificationController.clear();

    // Reset all boolean values
    _formData.isEnrolledInSchool = false;
    _formData.attendanceImproved = false;
    _formData.receivedSchoolMaterials = false;
    _formData.canReadWriteBasicText = false;
    _formData.advancedToNextGrade = false;
    _formData.academicYearEnded = false;
    _formData.promoted = null;
    _formData.improvementInSkills = null;
    _formData.engagedInHazardousWork = false;
    _formData.reducedWorkHours = false;
    _formData.involvedInLightWork = false;
    _formData.outOfHazardousWork = false;
    _formData.hasBirthCertificate = false;
    _formData.birthCertificateProcess = null;
    _formData.receivedAwarenessSessions = false;
    _formData.improvedUnderstanding = false;
    _formData.caregiversSupportSchool = false;
    _formData.receivedFinancialSupport = false;
    _formData.referralsMade = false;
    _formData.ongoingFollowUpPlanned = false;
    _formData.consideredRemediated = false;
    _formData.visitsSpacedCorrectly = false;
    _formData.confirmedNotInChildLabour = false;
    _formData.followUpCycleComplete = false;

    // await _storageService.clearFormData();
    notifyListeners();
  }

  // Getters for form data
  MonitoringModel get formData => _formData;

  // Dispose all controllers
  @override
  void dispose() {
    childIdController.dispose();
    childNameController.dispose();
    ageController.dispose();
    sexController.dispose();
    communityController.dispose();
    farmerIdController.dispose();
    firstRemediationDateController.dispose();
    remediationFormProvidedController.dispose();
    followUpVisitsCountController.dispose();
    classAtRemediationController.dispose();
    promotedGradeController.dispose();
    recommendationsController.dispose();
    noBirthCertificateReasonController.dispose();
    additionalCommentsController.dispose();
    followUpVisitsCountSinceIdentificationController.dispose();
    super.dispose();
  }
}