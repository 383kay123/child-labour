// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import '../models/child_details_model.dart';

// class ChildDetailsController extends ChangeNotifier {
//   final GlobalKey<FormState> formKey = GlobalKey<FormState>();
//   final ChildDetailsModel _model;
//   final ImagePicker _imagePicker = ImagePicker();

//   // Form state
//   bool _isLoading = false;
//   bool get isLoading => _isLoading;
  
//   // Page state
//   int _currentStep = 0;
//   int get currentStep => _currentStep;
  
//   // Validation state
//   final Map<String, String> _fieldErrors = {};
//   Map<String, String> get fieldErrors => Map.unmodifiable(_fieldErrors);

//   ChildDetailsController({ChildDetailsModel? initialData})
//       : _model = initialData ?? ChildDetailsModel() {
//     _initializeControllers();
//   }

//   // ========== BASIC GETTERS ==========
//   ChildDetailsModel get model => _model;
  
//   // Basic Information
//   String? get name => _model.name;
//   String? get surname => _model.surname;
//   int? get childNumber => _model.childNumber;
//   int? get birthYear => _model.birthYear;
//   String? get gender => _model.gender;
//   bool? get isFarmerChild => _model.isFarmerChild;
//   bool? get canBeSurveyedNow => _model.canBeSurveyedNow;
//   DateTime? get selectedDate => _model.selectedDate;

//   // Survey Availability
//   List<String> get surveyNotPossibleReasons => _model.surveyNotPossibleReasons;
//   String? get otherReason => _model.otherReason;
//   String? get respondentType => _model.respondentType;
//   String? get otherRespondentType => _model.otherRespondentType;
//   String? get respondentName => _model.respondentName;
//   String? get otherRespondentSpecify => _model.otherRespondentSpecify;

//   // Birth and Documentation
//   bool? get hasBirthCertificate => _model.hasBirthCertificate;
//   String? get noBirthCertificateReason => _model.noBirthCertificateReason;
//   bool? get bornInCommunity => _model.bornInCommunity;
//   String? get birthCountry => _model.birthCountry;
  
//   // Household Relationship
//   String? get relationshipToHead => _model.relationshipToHead;
//   String? get otherRelationship => _model.otherRelationship;
//   Map<String, bool> get notLivingWithFamilyReasons => _model.notLivingWithFamilyReasons;
//   String? get otherNotLivingWithFamilyReason => _model.otherNotLivingWithFamilyReason;

//   // Family Decision Information
//   String? get whoDecidedChildJoin => _model.whoDecidedChildJoin;
//   String? get otherPersonDecided => _model.otherPersonDecided;
//   bool? get childAgreedWithDecision => _model.childAgreedWithDecision;
//   bool? get hasSpokenWithParents => _model.hasSpokenWithParents;
//   String? get lastContactWithParents => _model.lastContactWithParents;
//   String? get timeInHousehold => _model.timeInHousehold;
//   String? get whoAccompaniedChild => _model.whoAccompaniedChild;
//   String? get otherAccompaniedPerson => _model.otherAccompaniedPerson;

//   // Parent Residence
//   String? get fatherResidence => _model.fatherResidence;
//   String? get fatherCountry => _model.fatherCountry;
//   String? get otherFatherCountry => _model.otherFatherCountry;
//   String? get motherResidence => _model.motherResidence;
//   String? get motherCountry => _model.motherCountry;
//   String? get otherMotherCountry => _model.otherMotherCountry;

//   // Education
//   bool? get isCurrentlyEnrolled => _model.isCurrentlyEnrolled;
//   bool? get hasEverBeenToSchool => _model.hasEverBeenToSchool;
//   String? get schoolName => _model.schoolName;
//   String? get schoolType => _model.schoolType;
//   String? get gradeLevel => _model.gradeLevel;
//   String? get schoolAttendanceFrequency => _model.schoolAttendanceFrequency;
//   Set<String> get availableSchoolSupplies => _model.availableSchoolSupplies;
//   int? get leftSchoolYear => _model.leftSchoolYear;
//   set leftSchoolYear(int? value) {
//     _model.leftSchoolYear = value;
//     _leftSchoolYearController.text = value?.toString() ?? '';
//     notifyListeners();
//   }
//   DateTime? get leftSchoolDate => _model.leftSchoolDate;
//   String? get selectedEducationLevel => _model.selectedEducationLevel;
//   String? get childLeaveSchoolReason => _model.childLeaveSchoolReason;
//   String? get otherLeaveReason => _model.otherLeaveReason;
//   String? get neverBeenToSchoolReason => _model.neverBeenToSchoolReason;
//   String? get otherNeverSchoolReason => _model.otherNeverSchoolReason;

//   // School Attendance
//   bool? get attendedSchoolLast7Days => _model.attendedSchoolLast7Days;
//   bool? get missedSchoolDays => _model.missedSchoolDays;
//   String? get selectedLeaveReason => _model.selectedLeaveReason;
//   String? get otherAbsenceReason => _model.otherAbsenceReason;
//   String? get selectedMissedReason => _model.selectedMissedReason;
//   String? get otherMissedReason => _model.otherMissedReason;

//   // Work Information
//   bool? get workedInHouse => _model.workedInHouse;
//   bool? get workedOnCocoaFarm => _model.workedOnCocoaFarm;
//   String? get workFrequency => _model.workFrequency;
//   bool? get observedWorking => _model.observedWorking;
//   Set<String> get cocoaFarmTasks => _model.cocoaFarmTasks;

//   // Light Tasks
//   bool? get receivedRemuneration => _model.receivedRemuneration;
//   String? get longestLightDutyTime => _model.longestLightDutyTime;
//   String? get longestNonSchoolDayTime => _model.longestNonSchoolDayTime;
//   String? get taskLocation => _model.taskLocation;
//   String? get otherLocation => _model.otherLocation;
//   String? get schoolDayTaskDuration => _model.schoolDayTaskDuration;
//   String? get nonSchoolDayHours => _model.nonSchoolDayHours;
//   bool? get wasSupervisedByAdult => _model.wasSupervisedByAdult;

//   // Light Tasks 12 Months
//   Set<String> get tasksLast12Months => _model.tasksLast12Months;
//   bool? get activityRemuneration => _model.activityRemuneration;
//   String? get schoolDayTaskDuration12Months => _model.schoolDayTaskDuration12Months;
//   String? get nonSchoolDayTaskDuration12Months => _model.nonSchoolDayTaskDuration12Months;
//   String? get taskLocationType => _model.taskLocationType;
//   String? get totalSchoolDayHours => _model.totalSchoolDayHours;
//   String? get totalNonSchoolDayHours => _model.totalNonSchoolDayHours;
//   bool? get wasSupervisedDuringTask => _model.wasSupervisedDuringTask;

//   // Dangerous Tasks 7 Days
//   Set<String> get cocoaFarmTasksLast7DaysDangerous => _model.cocoaFarmTasksLast7DaysDangerous;
//   bool? get hasReceivedSalary => _model.hasReceivedSalary;
//   String? get taskDangerousLocation => _model.taskDangerousLocation;
//   String? get otherDangerousLocation => _model.otherDangerousLocation;
//   String? get longestSchoolDayTimeDangerous => _model.longestSchoolDayTimeDangerous;
//   String? get longestNonSchoolDayTimeDangerous => _model.longestNonSchoolDayTimeDangerous;
//   String? get schoolDayHoursDangerous => _model.schoolDayHoursDangerous;
//   String? get nonSchoolDayDangerousHours => _model.nonSchoolDayDangerousHours;
//   bool? get wasSupervisedByAdultDangerous => _model.wasSupervisedByAdultDangerous;

//   // Dangerous Tasks 12 Months
//   Set<String> get cocoaFarmTasksLast12Months => _model.cocoaFarmTasksLast12Months;
//   bool? get hasReceivedSalary12Months => _model.hasReceivedSalary12Months;
//   String? get taskDangerousLocation12Months => _model.taskDangerousLocation12Months;
//   String? get otherDangerousLocation12Months => _model.otherDangerousLocation12Months;
//   String? get longestSchoolDayTimeDangerous12Months => _model.longestSchoolDayTimeDangerous12Months;
//   String? get longestNonSchoolDayTimeDangerous12Months => _model.longestNonSchoolDayTimeDangerous12Months;
//   String? get schoolDayHoursDangerous12Months => _model.schoolDayHoursDangerous12Months;
//   String? get nonSchoolDayDangerousHours12Months => _model.nonSchoolDayDangerousHours12Months;
//   bool? get wasSupervisedByAdultDangerous12Months => _model.wasSupervisedByAdultDangerous12Months;

//   // Work Details
//   String? get workForWhom => _model.workForWhom;
//   String? get workForWhomOther => _model.workForWhomOther;
//   Set<String> get whyWorkReasons => _model.whyWorkReasons;
//   String? get whyWorkOtherReason => _model.whyWorkOtherReason;

//   // Health and Safety
//   bool? get appliedAgrochemicals => _model.appliedAgrochemicals;
//   bool? get onFarmDuringApplication => _model.onFarmDuringApplication;
//   bool? get sufferedInjury => _model.sufferedInjury;
//   String? get howWounded => _model.howWounded;
//   DateTime? get whenWounded => _model.whenWounded;
//   bool? get oftenFeelPains => _model.oftenFeelPains;
//   Set<String> get helpReceived => _model.helpReceived;
//   String? get otherHelpReceived => _model.otherHelpReceived;

//   // Photo Consent
//   bool? get parentConsentPhoto => _model.parentConsentPhoto;
//   String? get noConsentReason => _model.noConsentReason;
//   String? get childPhotoPath => _model.childPhotoPath;

//   // Additional Work Hours
//   String? get totalHoursWorked => _model.totalHoursWorked;
//   String? get totalHoursWorkedDangerous => _model.totalHoursWorkedDangerous;
//   String? get totalHoursWorkedNonSchoolDangerous => _model.totalHoursWorkedNonSchoolDangerous;
//   String? get schoolDayHours => _model.schoolDayHours;

//   // School Reasons
//   String? get otherReasonForSchool => _model.otherReasonForSchool;

//   // ========== TEXT EDITING CONTROLLERS ==========
//   late final TextEditingController _nameController;
//   late final TextEditingController _surnameController;
//   late final TextEditingController _childNumberController;
//   late final TextEditingController _birthYearController;
//   late final TextEditingController _otherReasonController;
//   late final TextEditingController _otherRespondentTypeController;
//   late final TextEditingController _respondentNameController;
//   late final TextEditingController _otherRespondentSpecifyController;
//   late final TextEditingController _noBirthCertificateReasonController;
//   late final TextEditingController _otherRelationshipController;
//   late final TextEditingController _otherNotLivingWithFamilyController;
//   late final TextEditingController _otherPersonController;
//   late final TextEditingController _otherAccompaniedController;
//   late final TextEditingController _otherFatherCountryController;
//   late final TextEditingController _otherMotherCountryController;
//   late final TextEditingController _schoolNameController;
//   late final TextEditingController _leftSchoolYearController;
//   late final TextEditingController _leftSchoolDateController;
//   late final TextEditingController _otherLeaveReasonController;
//   late final TextEditingController _otherNeverSchoolReasonController;
//   late final TextEditingController _otherAbsenceReasonController;
//   late final TextEditingController _otherMissedReasonController;
//   late final TextEditingController _otherLocationController;
//   late final TextEditingController _schoolDayTaskDurationController;
//   late final TextEditingController _nonSchoolDayHoursController;
//   late final TextEditingController _howWoundedController;
//   late final TextEditingController _whenWoundedController;
//   late final TextEditingController _otherHelpController;
//   late final TextEditingController _noConsentReasonController;
//   late final TextEditingController _workForWhomOtherController;
//   late final TextEditingController _whyWorkOtherController;
//   late final TextEditingController _otherLocationDangerousController;
//   late final TextEditingController _schoolDayHoursDangerousController;
//   late final TextEditingController _nonSchoolDayDangerousHoursController;
//   late final TextEditingController _otherLocationDangerousController12Months;
//   late final TextEditingController _schoolDayHoursDangerousController12Months;
//   late final TextEditingController _nonSchoolDayDangerousHoursController12Months;
//   late final TextEditingController _totalHoursWorkedController;
//   late final TextEditingController _totalHoursWorkedControllerDangerous;
//   late final TextEditingController _totalHoursWorkedControllerNonSchoolDangerous;
//   late final TextEditingController _schoolDayHoursController;
//   late final TextEditingController _otherReasonForSchoolController;

//   void _initializeControllers() {
//     _nameController = TextEditingController(text: _model.name);
//     _surnameController = TextEditingController(text: _model.surname);
//     _childNumberController = TextEditingController(text: _model.childNumber?.toString() ?? '');
//     _birthYearController = TextEditingController(text: _model.birthYear?.toString() ?? '');
//     _otherReasonController = TextEditingController(text: _model.otherReason);
//     _otherRespondentTypeController = TextEditingController(text: _model.otherRespondentType);
//     _respondentNameController = TextEditingController(text: _model.respondentName);
//     _otherRespondentSpecifyController = TextEditingController(text: _model.otherRespondentSpecify);
//     _noBirthCertificateReasonController = TextEditingController(text: _model.noBirthCertificateReason);
//     _otherRelationshipController = TextEditingController(text: _model.otherRelationship);
//     _otherNotLivingWithFamilyController = TextEditingController(text: _model.otherNotLivingWithFamilyReason);
//     _otherPersonController = TextEditingController(text: _model.otherPersonDecided);
//     _otherAccompaniedController = TextEditingController(text: _model.otherAccompaniedPerson);
//     _otherFatherCountryController = TextEditingController(text: _model.otherFatherCountry);
//     _otherMotherCountryController = TextEditingController(text: _model.otherMotherCountry);
//     _schoolNameController = TextEditingController(text: _model.schoolName);
//     _leftSchoolYearController = TextEditingController(text: _model.leftSchoolYear?.toString());
//     _leftSchoolDateController = TextEditingController(text: _model.leftSchoolDate?.toIso8601String());
//     _otherLeaveReasonController = TextEditingController(text: _model.otherLeaveReason);
//     _otherNeverSchoolReasonController = TextEditingController(text: _model.otherNeverSchoolReason);
//     _otherAbsenceReasonController = TextEditingController(text: _model.otherAbsenceReason);
//     _otherMissedReasonController = TextEditingController(text: _model.otherMissedReason);
//     _otherLocationController = TextEditingController(text: _model.otherLocation);
//     _schoolDayTaskDurationController = TextEditingController(text: _model.schoolDayTaskDuration);
//     _nonSchoolDayHoursController = TextEditingController(text: _model.nonSchoolDayHours);
//     _howWoundedController = TextEditingController(text: _model.howWounded);
//     _whenWoundedController = TextEditingController(text: _model.whenWounded?.toIso8601String());
//     _otherHelpController = TextEditingController(text: _model.otherHelpReceived);
//     _noConsentReasonController = TextEditingController(text: _model.noConsentReason);
//     _workForWhomOtherController = TextEditingController(text: _model.workForWhomOther);
//     _whyWorkOtherController = TextEditingController(text: _model.whyWorkOtherReason);
//     _otherLocationDangerousController = TextEditingController(text: _model.otherDangerousLocation);
//     _schoolDayHoursDangerousController = TextEditingController(text: _model.schoolDayHoursDangerous);
//     _nonSchoolDayDangerousHoursController = TextEditingController(text: _model.nonSchoolDayDangerousHours);
//     _otherLocationDangerousController12Months = TextEditingController(text: _model.otherDangerousLocation12Months);
//     _schoolDayHoursDangerousController12Months = TextEditingController(text: _model.schoolDayHoursDangerous12Months);
//     _nonSchoolDayDangerousHoursController12Months = TextEditingController(text: _model.nonSchoolDayDangerousHours12Months);
//     _totalHoursWorkedController = TextEditingController(text: _model.totalHoursWorked);
//     _totalHoursWorkedControllerDangerous = TextEditingController(text: _model.totalHoursWorkedDangerous);
//     _totalHoursWorkedControllerNonSchoolDangerous = TextEditingController(text: _model.totalHoursWorkedNonSchoolDangerous);
//     _schoolDayHoursController = TextEditingController(text: _model.schoolDayHours);
//     _otherReasonForSchoolController = TextEditingController(text: _model.otherReasonForSchool);
//   }

//   // ========== SETTERS WITH VALIDATION ==========
//   set name(String? value) {
//     if (value != null && value.length < 2) {
//       _fieldErrors['name'] = 'Name must be at least 2 characters';
//     } else {
//       _fieldErrors.remove('name');
//     }
//     _model.name = value;
//     _nameController.text = value ?? '';
//     notifyListeners();
//   }

//   set surname(String? value) {
//     _model.surname = value;
//     _surnameController.text = value ?? '';
//     notifyListeners();
//   }

//   set childNumber(int? value) {
//     if (value != null && value <= 0) {
//       _fieldErrors['childNumber'] = 'Child number must be positive';
//     } else {
//       _fieldErrors.remove('childNumber');
//     }
//     _model.childNumber = value;
//     _childNumberController.text = value?.toString() ?? '';
//     notifyListeners();
//   }

//   set birthYear(int? value) {
//     final currentYear = DateTime.now().year;
//     if (value != null && (value < 1900 || value > currentYear)) {
//       _fieldErrors['birthYear'] = 'Please enter a valid birth year';
//     } else {
//       _fieldErrors.remove('birthYear');
//     }
//     _model.birthYear = value;
//     _birthYearController.text = value?.toString() ?? '';
//     notifyListeners();
//   }

//   set gender(String? value) {
//     _model.gender = value;
//     notifyListeners();
//   }

//   set isFarmerChild(bool? value) {
//     _model.isFarmerChild = value;
//     notifyListeners();
//   }

//   set canBeSurveyedNow(bool? value) {
//     _model.canBeSurveyedNow = value;
//     notifyListeners();
//   }

//   set selectedDate(DateTime? value) {
//     _model.selectedDate = value;
//     notifyListeners();
//   }

//   // ========== COMPLEX STATE UPDATES ==========
//   void updateSurveyNotPossibleReasons(String reason, bool? selected) {
//     if (selected == true) {
//       if (!_model.surveyNotPossibleReasons.contains(reason)) {
//         _model.surveyNotPossibleReasons.add(reason);
//       }
//     } else {
//       _model.surveyNotPossibleReasons.remove(reason);
//     }
//     notifyListeners();
//   }

//   void updateNotLivingWithFamilyReason(String reason, bool? selected) {
//     if (_model.notLivingWithFamilyReasons.containsKey(reason)) {
//       _model.notLivingWithFamilyReasons[reason] = selected ?? false;
//       notifyListeners();
//     }
//   }

//   void updateCocoaFarmTasks(String task, bool? selected) {
//     if (selected == true) {
//       _model.cocoaFarmTasks.add(task);
//     } else {
//       _model.cocoaFarmTasks.remove(task);
//     }
//     notifyListeners();
//   }

//   void updateTasksLast12Months(String task, bool? selected) {
//     if (selected == true) {
//       _model.tasksLast12Months.add(task);
//     } else {
//       _model.tasksLast12Months.remove(task);
//     }
//     notifyListeners();
//   }

//   void updateWhyWorkReasons(String reason, bool? selected) {
//     if (selected == true) {
//       _model.whyWorkReasons.add(reason);
//     } else {
//       _model.whyWorkReasons.remove(reason);
//     }
//     notifyListeners();
//   }

//   void updateHelpReceived(String help, bool? selected) {
//     if (selected == true) {
//       _model.helpReceived.add(help);
//     } else {
//       _model.helpReceived.remove(help);
//     }
//     notifyListeners();
//   }

//   // ========== FORM OPERATIONS ==========
//   Future<void> pickImage() async {
//     try {
//       final XFile? image = await _imagePicker.pickImage(source: ImageSource.camera);
//       if (image != null) {
//         _model.childPhotoPath = image.path;
//         notifyListeners();
//       }
//     } catch (e) {
//       _fieldErrors['photo'] = 'Failed to capture image: $e';
//       notifyListeners();
//     }
//   }

//   // ========== VALIDATION ==========
//   bool validateCurrentStep() {
//     bool isValid = true;
    
//     switch (_currentStep) {
//       case 0: // Basic Information
//         if (_model.name?.isEmpty ?? true) {
//           _fieldErrors['name'] = 'Name is required';
//           isValid = false;
//         }
//         if (_model.birthYear == null) {
//           _fieldErrors['birthYear'] = 'Birth year is required';
//           isValid = false;
//         }
//         break;
//       // Add validation for other steps
//     }
    
//     notifyListeners();
//     return isValid;
//   }

//   bool validate() {
//     return formKey.currentState?.validate() ?? false;
//   }

//   // ========== NAVIGATION ==========
//   void nextStep() {
//     if (validateCurrentStep()) {
//       _currentStep++;
//       _fieldErrors.clear();
//       notifyListeners();
//     }
//   }

//   void previousStep() {
//     if (_currentStep > 0) {
//       _currentStep--;
//       _fieldErrors.clear();
//       notifyListeners();
//     }
//   }

//   // ========== DATA PERSISTENCE ==========
//   Map<String, dynamic> toJson() {
//     return _model.toJson();
//   }

//   Future<void> fromJson(Map<String, dynamic> json) async {
//     _isLoading = true;
//     notifyListeners();
    
//     try {
//       final updatedModel = ChildDetailsModel.fromJson(json);
//       // Update all model properties from JSON
//       _model.name = updatedModel.name;
//       _model.surname = updatedModel.surname;
//       _model.childNumber = updatedModel.childNumber;
//       _model.birthYear = updatedModel.birthYear;
//       _model.gender = updatedModel.gender;
//       _model.isFarmerChild = updatedModel.isFarmerChild;
//       _model.canBeSurveyedNow = updatedModel.canBeSurveyedNow;
//       _model.selectedDate = updatedModel.selectedDate;
      
//       // Update collections
//       _model.surveyNotPossibleReasons = updatedModel.surveyNotPossibleReasons;
//       _model.notLivingWithFamilyReasons = updatedModel.notLivingWithFamilyReasons;
//       _model.cocoaFarmTasks = updatedModel.cocoaFarmTasks;
//       _model.tasksLast12Months = updatedModel.tasksLast12Months;
//       _model.cocoaFarmTasksLast7DaysDangerous = updatedModel.cocoaFarmTasksLast7DaysDangerous;
//       _model.cocoaFarmTasksLast12Months = updatedModel.cocoaFarmTasksLast12Months;
//       _model.whyWorkReasons = updatedModel.whyWorkReasons;
//       _model.helpReceived = updatedModel.helpReceived;
      
//       // Update controllers
//       _initializeControllers();
      
//     } catch (e) {
//       _fieldErrors['load'] = 'Failed to load data: $e';
//       rethrow;
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<bool> save() async {
//     if (!validate()) return false;
    
//     _isLoading = true;
//     notifyListeners();
    
//     try {
//       // Save data to storage/API
//       // await _storageService.saveChildDetails(toJson());
//       return true;
//     } catch (e) {
//       _fieldErrors['save'] = 'Failed to save data: $e';
//       return false;
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   // ========== CLEANUP ==========
//   @override
//   void dispose() {
//     // Basic Information Controllers
//     _nameController.dispose();
//     _surnameController.dispose();
//     _childNumberController.dispose();
//     _birthYearController.dispose();
    
//     // Survey Related Controllers
//     _otherReasonController.dispose();
//     _otherRespondentTypeController.dispose();
//     _respondentNameController.dispose();
//     _otherRespondentSpecifyController.dispose();
    
//     // Birth Certificate Controllers
//     _noBirthCertificateReasonController.dispose();
  
//     // Relationship Controllers
//     _otherRelationshipController.dispose();
//     _otherNotLivingWithFamilyController.dispose();
//     _otherPersonController.dispose();
//     _otherAccompaniedController.dispose();
    
//     // Parent Residence Controllers
//     _otherFatherCountryController.dispose();
//     _otherMotherCountryController.dispose();
    
//     // Education Controllers
//     _schoolNameController.dispose();
//     _leftSchoolYearController.dispose();
//     _leftSchoolDateController.dispose();
//     _otherLeaveReasonController.dispose();
//     _otherNeverSchoolReasonController.dispose();
//     _otherAbsenceReasonController.dispose();
//     _otherMissedReasonController.dispose();
    
//     // Work Information Controllers
//     _otherLocationController.dispose();
//     _schoolDayTaskDurationController.dispose();
//     _nonSchoolDayHoursController.dispose();
    
//     // Health & Safety Controllers
//     _howWoundedController.dispose();
//     _whenWoundedController.dispose();
//     _otherHelpController.dispose();
    
//     // Photo Consent Controllers
//     _noConsentReasonController.dispose();
    
//     // Work Details Controllers
//     _workForWhomOtherController.dispose();
//     _whyWorkOtherController.dispose();
    
//     // Dangerous Tasks Controllers
//     _otherLocationDangerousController.dispose();
//     _schoolDayHoursDangerousController.dispose();
//     _nonSchoolDayDangerousHoursController.dispose();
//     _otherLocationDangerousController12Months.dispose();
//     _schoolDayHoursDangerousController12Months.dispose();
//     _nonSchoolDayDangerousHoursController12Months.dispose();
    
//     // Additional Work Hours Controllers
//     _totalHoursWorkedController.dispose();
//     _totalHoursWorkedControllerDangerous.dispose();
//     _totalHoursWorkedControllerNonSchoolDangerous.dispose();
//     _schoolDayHoursController.dispose();
    
//     // School Reasons Controllers
//     _otherReasonForSchoolController.dispose();

//     super.dispose();
//   }
  
//   // Reset form to initial state
//   void reset() {
//     _currentStep = 0;
//     _fieldErrors.clear();
//     _initializeControllers();
//     notifyListeners();
//   }
  
//   // ========== CONDITIONAL LOGIC ==========
//   // Survey Availability
//   bool get showOtherReasonField => _model.surveyNotPossibleReasons.contains('Other (specify)');
//   bool get showOtherRespondentFields => _model.respondentType == 'Other' || _model.respondentType == 'Other relative';
//   bool get showRespondentNameField => _model.canBeSurveyedNow == false;

//   // Personal Information
//   bool get showChildNameFields => _model.isFarmerChild == false;
//   bool get showBirthCertificateReason => _model.hasBirthCertificate == false;
//   bool get showBirthCountryField => _model.bornInCommunity == false && _model.birthCountry == 'other_country';
//   bool get showOtherRelationshipField => _model.relationshipToHead == 'Other (please specify)';
//   bool get showNotLivingWithFamilySection => 
//       _model.relationshipToHead == 'Child of the worker' ||
//       _model.relationshipToHead == 'Child of the farm owner' ||
//       _model.relationshipToHead == 'Other (please specify)';
//   bool get showOtherNotLivingWithFamilyField => _model.notLivingWithFamilyReasons['Other (specify)'] == true;

//   // Family Decision
//   bool get showOtherPersonField => _model.whoDecidedChildJoin == 'other_person';
//   bool get showChildAgreementField =>
//       _model.whoDecidedChildJoin == 'father_mother' ||
//       _model.whoDecidedChildJoin == 'grandparents' ||
//       _model.whoDecidedChildJoin == 'other_family' ||
//       _model.whoDecidedChildJoin == 'external_recruiter' ||
//       _model.whoDecidedChildJoin == 'other_person';
//   bool get showLastContactField => _model.hasSpokenWithParents != null;
//   bool get showOtherAccompaniedField => _model.whoAccompaniedChild == 'other';

//   // Parent Residence
//   bool get showFatherCountryFields => _model.fatherResidence == 'Abroad';
//   bool get showOtherFatherCountryField => _model.fatherCountry == 'Others to be specified';
//   bool get showMotherCountryFields => _model.motherResidence == 'Abroad';
//   bool get showOtherMotherCountryField => _model.motherCountry == 'Others to be specified';

//   // Education
//   bool get showSchoolFields => _model.isCurrentlyEnrolled == true;
//   bool get showSchoolSuppliesSection => _model.isCurrentlyEnrolled == true;
//   bool get showEverBeenToSchoolSection => _model.isCurrentlyEnrolled == false;
//   bool get showLeftSchoolSection => _model.hasEverBeenToSchool == true;
//   bool get showOtherLeaveReasonField => _model.childLeaveSchoolReason == 'other';
//   bool get showNeverBeenToSchoolSection => _model.hasEverBeenToSchool == false;
//   bool get showOtherNeverSchoolReasonField => _model.neverBeenToSchoolReason == 'other';
//   bool get showAbsenceReasonSection => _model.attendedSchoolLast7Days == false;
//   bool get showOtherAbsenceReasonField => _model.selectedLeaveReason == 'other';
//   bool get showMissedReasonSection => _model.missedSchoolDays == true;
//   bool get showOtherMissedReasonField => _model.selectedMissedReason == 'other';

//   // Assessment
//   bool get showAssessmentSection {
//     final childAge = _model.birthYear != null ? DateTime.now().year - _model.birthYear! : null;
//     return childAge != null &&
//         _model.canBeSurveyedNow == true &&
//         (_model.isCurrentlyEnrolled == true || (_model.isCurrentlyEnrolled == false && _model.hasEverBeenToSchool == true));
//   }

//   // Work Information
//   bool get showWorkDetailsSection => _model.canBeSurveyedNow == true;
//   bool get showCocoaFarmTasksSection => _model.workedOnCocoaFarm == true;
//   bool get showLightTasksSection => _model.workedOnCocoaFarm == true;
//   bool get showDangerousTasksSection => _model.workedOnCocoaFarm == true;
//   bool get showTaskLocationFields => _model.workedOnCocoaFarm == true;
//   bool get showTasksLast12MonthsSection => _model.workedOnCocoaFarm == true;
//   bool get showDangerousTasks7DaysSection => _model.workedOnCocoaFarm == true;
//   bool get showDangerousTasks12MonthsSection => _model.workedOnCocoaFarm == true;

//   // Work Details
//   bool get showWorkForWhomSection => _model.workedOnCocoaFarm == true || _model.workedInHouse == true;
//   bool get showOtherWorkForWhomField => _model.workForWhom == 'Other';
//   bool get showWhyWorkSection => _model.workedOnCocoaFarm == true || _model.workedInHouse == true;
//   bool get showOtherWhyWorkField => _model.whyWorkReasons.contains('Other');

//   // Health & Safety
//   bool get showInjuryDetailsSection => _model.sufferedInjury == true;
//   bool get showOtherHelpField => _model.helpReceived.contains('Other');
//   bool get showOnFarmDuringApplicationField => _model.appliedAgrochemicals == true;
//   bool get showHelpReceivedSection => _model.oftenFeelPains == true;

//   // Photo Consent
//   bool get showNoConsentReasonField => _model.parentConsentPhoto == false;
//   bool get showPhotoSection => _model.parentConsentPhoto == true;

//   // Task Locations
//   bool get showOtherLocationField => _model.taskLocation == 'other';
//   bool get showOtherLocationDangerousField => _model.taskDangerousLocation == 'other';
//   bool get showOtherLocationDangerous12MonthsField => _model.taskDangerousLocation12Months == 'other';

//   // Child Number Field
//   bool get showChildNumberField => _model.isFarmerChild == true;

//   // Section Visibility
//   bool get shouldShowEducationSection => _model.canBeSurveyedNow == true;
//   bool get shouldShowWorkSection => _model.canBeSurveyedNow == true;
//   bool get shouldShowFamilyDecisionSection => _model.isFarmerChild == false;
//   bool get shouldShowAssessmentSection => showAssessmentSection;
// }