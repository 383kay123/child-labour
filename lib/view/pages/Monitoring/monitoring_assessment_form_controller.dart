import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:human_rights_monitor/controller/db/db_tables/helpers/monitoring_db_helper.dart';
import 'package:intl/intl.dart';
import '../../../controller/models/monitoring_model.dart';


class MonitoringAssessmentFormController extends GetxController {
  // Form state using MonitoringModel
  final Rx<MonitoringModel> formData = MonitoringModel(visitDate: DateTime.now()).obs;
  final RxInt monitoringScore = 0.obs;
  
  // Text Editing Controllers
  final TextEditingController childIdController = TextEditingController();
  final TextEditingController childNameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController communityController = TextEditingController();
  final TextEditingController farmerIdController = TextEditingController();
  final TextEditingController interventionDateController = TextEditingController();
  final TextEditingController remediationTypeController = TextEditingController();
  final TextEditingController followUpVisitsController = TextEditingController();
  final TextEditingController recommendationsController = TextEditingController();
  final TextEditingController noBirthCertReasonController = TextEditingController();
  final TextEditingController additionalCommentsController = TextEditingController();
  final TextEditingController followUpVisitsCountController = TextEditingController();
  
  // Selection Fields
  final RxString selectedGender = ''.obs;
  final RxString selectedCommunity = ''.obs;
  final RxString selectedFarmerId = ''.obs;
  final RxString selectedRemediationClass = ''.obs;
  final RxString selectedCurrentGrade = ''.obs;
  final RxString selectedChildCode = ''.obs;

  // Available options
  final List<String> classLevels = [
    'Nursery', 'PP1', 'PP2', 'Grade 1', 'Grade 2', 'Grade 3', 'Grade 4', 
    'Grade 5', 'Grade 6', 'Grade 7', 'Grade 8', 'Form 1', 'Form 2', 
    'Form 3', 'Form 4', 'College/University'
  ];
  
  final List<String> genderOptions = ['Male', 'Female', 'Other'];
  
  // Child options
  final List<Map<String, String>> childOptions = [
    {'code': 'CHILD-1001', 'name': 'John Doe'},
    {'code': 'CHILD-1002', 'name': 'Mary Johnson'},
    {'code': 'CHILD-1003', 'name': 'David Smith'},
    {'code': 'CHILD-1004', 'name': 'Sarah Williams'},
    {'code': 'CHILD-1005', 'name': 'Michael Brown'},
  ];
  
  final Rx<DateTime?> interventionDate = Rx<DateTime?>(null);

  @override
  void onInit() {
    super.onInit();
    _initializeForm();
  }

  @override
  void onClose() {
    childIdController.dispose();
    childNameController.dispose();
    ageController.dispose();
    communityController.dispose();
    farmerIdController.dispose();
    interventionDateController.dispose();
    remediationTypeController.dispose();
    followUpVisitsController.dispose();
    recommendationsController.dispose();
    noBirthCertReasonController.dispose();
    additionalCommentsController.dispose();
    followUpVisitsCountController.dispose();
    super.onClose();
  }

  void _initializeForm() {
    interventionDateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    interventionDate.value = DateTime.now();
  }

  // Child Selection
  void setSelectedChild(String? code) {
    selectedChildCode.value = code ?? '';
    if (code == null) {
      childNameController.clear();
      childIdController.clear();
      ageController.clear();
    } else {
      final child = childOptions.firstWhere(
        (child) => child['code'] == code,
        orElse: () => {'code': code, 'name': 'Unknown'},
      );
      childIdController.text = code;
      childNameController.text = child['name']!;
      ageController.text = '12';
    }
  }

  // Date Picker
  Future<void> selectInterventionDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: interventionDate.value ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != interventionDate.value) {
      interventionDate.value = picked;
      interventionDateController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  // Update score based on all answers
  void updateScore() {
    int score = 0;
    
    // Education Progress
    if (formData.value.isEnrolledInSchool) score += 10;
    if (formData.value.attendanceImproved) score += 10;
    if (formData.value.receivedSchoolMaterials) score += 10;
    if (formData.value.canReadBasicText) score += 10;
    if (formData.value.canWriteBasicText) score += 10;
    if (formData.value.canDoCalculations) score += 10;
    if (formData.value.advancedToNextGrade) score += 10;
    
    // Child Labour Risk
    if (!formData.value.engagedInHazardousWork) score += 10;
    if (formData.value.reducedWorkHours) score += 10;
    if (formData.value.involvedInLightWork) score += 5;
    if (formData.value.outOfHazardousWork) score += 10;
    
    // Legal Documentation
    if (formData.value.hasBirthCertificate) score += 10;
    if (formData.value.ongoingBirthCertProcess == true) score += 5;
    
    monitoringScore.value = score;
  }

  // Form Validation
  bool validateForm() {
    if (selectedChildCode.value.isEmpty) {
      Get.snackbar('Error', 'Please select a child', 
        backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }
    
    if (selectedGender.value.isEmpty) {
      Get.snackbar('Error', 'Please select gender', 
        backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }
    
    if (selectedCommunity.value.isEmpty) {
      Get.snackbar('Error', 'Please select community', 
        backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }
    
    if (selectedFarmerId.value.isEmpty) {
      Get.snackbar('Error', 'Please select farmer ID', 
        backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }
    
    if (interventionDateController.text.isEmpty) {
      Get.snackbar('Error', 'Please select intervention date', 
        backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }
    
    return true;
  }

  // Prepare MonitoringModel with ALL questions and answers
  MonitoringModel prepareMonitoringModel({int status = 0}) {
    final now = DateTime.now();
    
    return MonitoringModel(
      // Metadata
      dateCreated: formData.value.dateCreated ?? now,
      dateModified: now,
      status: status,
      visitDate: formData.value.visitDate,
      notes: formData.value.notes,
      
      // Section 1: Child Identification
      childId: childIdController.text,
      childName: childNameController.text,
      age: ageController.text,
      sex: selectedGender.value,
      community: selectedCommunity.value,
      farmerId: selectedFarmerId.value,
      firstRemediationDate: interventionDateController.text,
      remediationFormProvided: remediationTypeController.text,
      followUpVisitsCount: followUpVisitsController.text,
      
      // Section 2: Education Progress
      classAtRemediation: selectedRemediationClass.value,
      isEnrolledInSchool: formData.value.isEnrolledInSchool,
      attendanceImproved: formData.value.attendanceImproved,
      receivedSchoolMaterials: formData.value.receivedSchoolMaterials,
      canReadBasicText: formData.value.canReadBasicText,
      canWriteBasicText: formData.value.canWriteBasicText,
      canDoCalculations: formData.value.canDoCalculations,
      advancedToNextGrade: formData.value.advancedToNextGrade,
      academicYearEnded: formData.value.academicYearEnded,
      promoted: formData.value.promoted,
      academicImprovement: formData.value.academicImprovement,
      promotedGrade: selectedCurrentGrade.value,
      recommendations: recommendationsController.text,
      
      // Section 3: Child Labour Risk
      engagedInHazardousWork: formData.value.engagedInHazardousWork,
      reducedWorkHours: formData.value.reducedWorkHours,
      involvedInLightWork: formData.value.involvedInLightWork,
      outOfHazardousWork: formData.value.outOfHazardousWork,
      hazardousWorkDetails: formData.value.hazardousWorkDetails,
      reducedWorkHoursDetails: formData.value.reducedWorkHoursDetails,
      lightWorkDetails: formData.value.lightWorkDetails,
      hazardousWorkFreePeriodDetails: formData.value.hazardousWorkFreePeriodDetails,
      
      // Section 4: Legal Documentation
      hasBirthCertificate: formData.value.hasBirthCertificate,
      ongoingBirthCertProcess: formData.value.ongoingBirthCertProcess,
      noBirthCertificateReason: noBirthCertReasonController.text,
      birthCertificateStatus: formData.value.birthCertificateStatus,
      ongoingBirthCertProcessDetails: formData.value.ongoingBirthCertProcessDetails,
      
      // Section 5: Family & Caregiver Engagement
      receivedAwarenessSessions: formData.value.receivedAwarenessSessions,
      improvedUnderstanding: formData.value.improvedUnderstanding,
      caregiversSupportSchool: formData.value.caregiversSupportSchool,
      awarenessSessionsDetails: formData.value.awarenessSessionsDetails,
      understandingImprovementDetails: formData.value.understandingImprovementDetails,
      caregiverSupportDetails: formData.value.caregiverSupportDetails,
      
      // Section 6: Additional Support Provided
      receivedFinancialSupport: formData.value.receivedFinancialSupport,
      referralsMade: formData.value.referralsMade,
      ongoingFollowUpPlanned: formData.value.ongoingFollowUpPlanned,
      financialSupportDetails: formData.value.financialSupportDetails,
      referralsDetails: formData.value.referralsDetails,
      followUpPlanDetails: formData.value.followUpPlanDetails,
      
      // Section 7: Overall Assessment
      consideredRemediated: formData.value.consideredRemediated,
      additionalComments: additionalCommentsController.text,
      
      // Section 8: Follow-up Cycle Completion
      followUpVisitsCountSinceIdentification: followUpVisitsCountController.text,
      visitsSpacedCorrectly: formData.value.visitsSpacedCorrectly,
      confirmedNotInChildLabour: formData.value.confirmedNotInChildLabour,
      followUpCycleComplete: formData.value.followUpCycleComplete,
    );
  }

  // Update form data from UI
  void updateFormData({
    // Education Progress
    bool? isEnrolledInSchool,
    bool? attendanceImproved,
    bool? receivedSchoolMaterials,
    bool? canReadBasicText,
    bool? canWriteBasicText,
    bool? canDoCalculations,
    bool? advancedToNextGrade,
    bool? academicYearEnded,
    bool? promoted,
    bool? academicImprovement,
    
    // Child Labour Risk
    bool? engagedInHazardousWork,
    bool? reducedWorkHours,
    bool? involvedInLightWork,
    bool? outOfHazardousWork,
    String? hazardousWorkDetails,
    String? reducedWorkHoursDetails,
    String? lightWorkDetails,
    String? hazardousWorkFreePeriodDetails,
    
    // Legal Documentation
    bool? hasBirthCertificate,
    bool? ongoingBirthCertProcess,
    String? birthCertificateStatus,
    String? ongoingBirthCertProcessDetails,
    
    // Family & Caregiver Engagement
    bool? receivedAwarenessSessions,
    bool? improvedUnderstanding,
    bool? caregiversSupportSchool,
    String? awarenessSessionsDetails,
    String? understandingImprovementDetails,
    String? caregiverSupportDetails,
    
    // Additional Support
    bool? receivedFinancialSupport,
    bool? referralsMade,
    bool? ongoingFollowUpPlanned,
    String? financialSupportDetails,
    String? referralsDetails,
    String? followUpPlanDetails,
    
    // Overall Assessment
    bool? consideredRemediated,
    
    // Follow-up Cycle
    bool? visitsSpacedCorrectly,
    bool? confirmedNotInChildLabour,
    bool? followUpCycleComplete,
  }) {
    final currentData = formData.value;
    
    formData.value = currentData.copyWith(
      // Education Progress
      isEnrolledInSchool: isEnrolledInSchool ?? currentData.isEnrolledInSchool,
      attendanceImproved: attendanceImproved ?? currentData.attendanceImproved,
      receivedSchoolMaterials: receivedSchoolMaterials ?? currentData.receivedSchoolMaterials,
      canReadBasicText: canReadBasicText ?? currentData.canReadBasicText,
      canWriteBasicText: canWriteBasicText ?? currentData.canWriteBasicText,
      canDoCalculations: canDoCalculations ?? currentData.canDoCalculations,
      advancedToNextGrade: advancedToNextGrade ?? currentData.advancedToNextGrade,
      academicYearEnded: academicYearEnded ?? currentData.academicYearEnded,
      promoted: promoted ?? currentData.promoted,
      academicImprovement: academicImprovement ?? currentData.academicImprovement,
      
      // Child Labour Risk
      engagedInHazardousWork: engagedInHazardousWork ?? currentData.engagedInHazardousWork,
      reducedWorkHours: reducedWorkHours ?? currentData.reducedWorkHours,
      involvedInLightWork: involvedInLightWork ?? currentData.involvedInLightWork,
      outOfHazardousWork: outOfHazardousWork ?? currentData.outOfHazardousWork,
      hazardousWorkDetails: hazardousWorkDetails ?? currentData.hazardousWorkDetails,
      reducedWorkHoursDetails: reducedWorkHoursDetails ?? currentData.reducedWorkHoursDetails,
      lightWorkDetails: lightWorkDetails ?? currentData.lightWorkDetails,
      hazardousWorkFreePeriodDetails: hazardousWorkFreePeriodDetails ?? currentData.hazardousWorkFreePeriodDetails,
      
      // Legal Documentation
      hasBirthCertificate: hasBirthCertificate ?? currentData.hasBirthCertificate,
      ongoingBirthCertProcess: ongoingBirthCertProcess ?? currentData.ongoingBirthCertProcess,
      birthCertificateStatus: birthCertificateStatus ?? currentData.birthCertificateStatus,
      ongoingBirthCertProcessDetails: ongoingBirthCertProcessDetails ?? currentData.ongoingBirthCertProcessDetails,
      
      // Family & Caregiver Engagement
      receivedAwarenessSessions: receivedAwarenessSessions ?? currentData.receivedAwarenessSessions,
      improvedUnderstanding: improvedUnderstanding ?? currentData.improvedUnderstanding,
      caregiversSupportSchool: caregiversSupportSchool ?? currentData.caregiversSupportSchool,
      awarenessSessionsDetails: awarenessSessionsDetails ?? currentData.awarenessSessionsDetails,
      understandingImprovementDetails: understandingImprovementDetails ?? currentData.understandingImprovementDetails,
      caregiverSupportDetails: caregiverSupportDetails ?? currentData.caregiverSupportDetails,
      
      // Additional Support
      receivedFinancialSupport: receivedFinancialSupport ?? currentData.receivedFinancialSupport,
      referralsMade: referralsMade ?? currentData.referralsMade,
      ongoingFollowUpPlanned: ongoingFollowUpPlanned ?? currentData.ongoingFollowUpPlanned,
      financialSupportDetails: financialSupportDetails ?? currentData.financialSupportDetails,
      referralsDetails: referralsDetails ?? currentData.referralsDetails,
      followUpPlanDetails: followUpPlanDetails ?? currentData.followUpPlanDetails,
      
      // Overall Assessment
      consideredRemediated: consideredRemediated ?? currentData.consideredRemediated,
      
      // Follow-up Cycle
      visitsSpacedCorrectly: visitsSpacedCorrectly ?? currentData.visitsSpacedCorrectly,
      confirmedNotInChildLabour: confirmedNotInChildLabour ?? currentData.confirmedNotInChildLabour,
      followUpCycleComplete: followUpCycleComplete ?? currentData.followUpCycleComplete,
    );
    
    updateScore();
    update();
  }

  // Form Submission
  Future<bool> submitForm() async {
    if (!validateForm()) {
      return false;
    }
    
    try {
      final monitoringModel = prepareMonitoringModel(status: 1); // 1 = submitted
      
      await MonitoringDBHelper.instance.insertMonitoringRecord(monitoringModel);
      
      Get.snackbar(
        'Success', 
        'Monitoring assessment submitted successfully',
        backgroundColor: Colors.green, 
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      
      clearForm();
      return true;
    } catch (e) {
      print('Error submitting form: $e');
      Get.snackbar(
        'Error', 
        'Failed to submit form: ${e.toString()}',
        backgroundColor: Colors.red, 
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      return false;
    }
  }

  // Save as Draft
  Future<bool> saveAsDraft() async {
    try {
      final monitoringModel = prepareMonitoringModel(status: 0); // 0 = draft
      
      await MonitoringDBHelper.instance.insertMonitoringRecord(monitoringModel);
      
      Get.snackbar(
        'Saved', 
        'Form saved as draft',
        backgroundColor: Colors.blue, 
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      
      return true;
    } catch (e) {
      print('Error saving draft: $e');
      Get.snackbar(
        'Error', 
        'Failed to save draft: ${e.toString()}',
        backgroundColor: Colors.red, 
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      return false;
    }
  }

  // Clear Form
  void clearForm() {
    // Clear all controllers
    childIdController.clear();
    childNameController.clear();
    ageController.clear();
    communityController.clear();
    farmerIdController.clear();
    interventionDateController.clear();
    remediationTypeController.dispose();
    followUpVisitsController.clear();
    recommendationsController.clear();
    noBirthCertReasonController.clear();
    additionalCommentsController.clear();
    followUpVisitsCountController.clear();
    
    // Reset all observable values
    selectedGender.value = '';
    selectedCommunity.value = '';
    selectedFarmerId.value = '';
    selectedRemediationClass.value = '';
    selectedCurrentGrade.value = '';
    selectedChildCode.value = '';
    
    // Reset form data
    formData.value = MonitoringModel(visitDate: DateTime.now());
    monitoringScore.value = 0;
    
    update();
  }

  // Load existing data for editing
  void loadExistingData(MonitoringModel data) {
    formData.value = data;
    
    // Load text fields
    childIdController.text = data.childId;
    childNameController.text = data.childName;
    ageController.text = data.age;
    communityController.text = data.community;
    farmerIdController.text = data.farmerId;
    interventionDateController.text = data.firstRemediationDate;
    remediationTypeController.text = data.remediationFormProvided;
    followUpVisitsController.text = data.followUpVisitsCount;
    recommendationsController.text = data.recommendations ?? '';
    noBirthCertReasonController.text = data.noBirthCertificateReason ?? '';
    additionalCommentsController.text = data.additionalComments;
    followUpVisitsCountController.text = data.followUpVisitsCountSinceIdentification;
    
    // Load selection fields
    selectedGender.value = data.sex;
    selectedCommunity.value = data.community;
    selectedFarmerId.value = data.farmerId;
    selectedRemediationClass.value = data.classAtRemediation;
    selectedCurrentGrade.value = data.promotedGrade ?? '';
    
    updateScore();
    update();
  }
}