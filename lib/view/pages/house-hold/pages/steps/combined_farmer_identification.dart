import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../theme/app_theme.dart';

// ===========================================================================
// MODELS
// ===========================================================================

class VisitInformationData {
  final String? respondentNameCorrect;
  final String? respondentNationality;
  final String? countryOfOrigin;
  final String? isFarmOwner;
  final String? farmOwnershipType;
  final String correctedRespondentName;
  final String respondentOtherNames;
  final String otherCountry;

  const VisitInformationData({
    this.respondentNameCorrect,
    this.respondentNationality,
    this.countryOfOrigin,
    this.isFarmOwner,
    this.farmOwnershipType,
    this.correctedRespondentName = '',
    this.respondentOtherNames = '',
    this.otherCountry = '',
  });

  VisitInformationData copyWith({
    String? respondentNameCorrect,
    String? respondentNationality,
    String? countryOfOrigin,
    String? isFarmOwner,
    String? farmOwnershipType,
    String? correctedRespondentName,
    String? respondentOtherNames,
    String? otherCountry,
  }) {
    return VisitInformationData(
      respondentNameCorrect:
          respondentNameCorrect ?? this.respondentNameCorrect,
      respondentNationality:
          respondentNationality ?? this.respondentNationality,
      countryOfOrigin: countryOfOrigin ?? this.countryOfOrigin,
      isFarmOwner: isFarmOwner ?? this.isFarmOwner,
      farmOwnershipType: farmOwnershipType ?? this.farmOwnershipType,
      correctedRespondentName:
          correctedRespondentName ?? this.correctedRespondentName,
      respondentOtherNames: respondentOtherNames ?? this.respondentOtherNames,
      otherCountry: otherCountry ?? this.otherCountry,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'respondentNameCorrect': respondentNameCorrect,
      'respondentNationality': respondentNationality,
      'countryOfOrigin': countryOfOrigin,
      'isFarmOwner': isFarmOwner,
      'farmOwnershipType': farmOwnershipType,
      'correctedRespondentName': correctedRespondentName,
      'respondentOtherNames': respondentOtherNames,
      'otherCountry': otherCountry,
    };
  }

  factory VisitInformationData.fromMap(Map<String, dynamic> map) {
    return VisitInformationData(
      respondentNameCorrect: map['respondentNameCorrect'],
      respondentNationality: map['respondentNationality'],
      countryOfOrigin: map['countryOfOrigin'],
      isFarmOwner: map['isFarmOwner'],
      farmOwnershipType: map['farmOwnershipType'],
      correctedRespondentName: map['correctedRespondentName'] ?? '',
      respondentOtherNames: map['respondentOtherNames'] ?? '',
      otherCountry: map['otherCountry'] ?? '',
    );
  }

  static VisitInformationData empty() {
    return const VisitInformationData();
  }

  bool get isFormComplete {
    return respondentNameCorrect != null &&
        respondentNationality != null &&
        (respondentNationality != 'Non-Ghanaian' ||
            (countryOfOrigin != null &&
                (countryOfOrigin != 'Other' || otherCountry.isNotEmpty))) &&
        isFarmOwner != null &&
        (isFarmOwner != 'Yes' || farmOwnershipType != null) &&
        (isFarmOwner != 'No' || farmOwnershipType != null);
  }
}

class IdentificationOfOwnerData {
  final String ownerName;
  final String ownerFirstName;
  final String? nationality;
  final String? specificNationality;
  final String otherNationality;
  final String yearsWithOwner;

  const IdentificationOfOwnerData({
    this.ownerName = '',
    this.ownerFirstName = '',
    this.nationality,
    this.specificNationality,
    this.otherNationality = '',
    this.yearsWithOwner = '',
  });

  IdentificationOfOwnerData copyWith({
    String? ownerName,
    String? ownerFirstName,
    String? nationality,
    String? specificNationality,
    String? otherNationality,
    String? yearsWithOwner,
  }) {
    return IdentificationOfOwnerData(
      ownerName: ownerName ?? this.ownerName,
      ownerFirstName: ownerFirstName ?? this.ownerFirstName,
      nationality: nationality ?? this.nationality,
      specificNationality: specificNationality ?? this.specificNationality,
      otherNationality: otherNationality ?? this.otherNationality,
      yearsWithOwner: yearsWithOwner ?? this.yearsWithOwner,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerName': ownerName,
      'ownerFirstName': ownerFirstName,
      'nationality': nationality,
      'specificNationality': specificNationality,
      'otherNationality': otherNationality,
      'yearsWithOwner': yearsWithOwner,
    };
  }

  factory IdentificationOfOwnerData.fromMap(Map<String, dynamic> map) {
    return IdentificationOfOwnerData(
      ownerName: map['ownerName'] ?? '',
      ownerFirstName: map['ownerFirstName'] ?? '',
      nationality: map['nationality'],
      specificNationality: map['specificNationality'],
      otherNationality: map['otherNationality'] ?? '',
      yearsWithOwner: map['yearsWithOwner'] ?? '',
    );
  }

  static IdentificationOfOwnerData empty() {
    return const IdentificationOfOwnerData();
  }

  bool get isFormComplete {
    return ownerName.isNotEmpty &&
        ownerFirstName.isNotEmpty &&
        nationality != null &&
        (nationality != 'Non-Ghanaian' ||
            (specificNationality != null &&
                (specificNationality != 'Other' ||
                    otherNationality.isNotEmpty))) &&
        yearsWithOwner.isNotEmpty;
  }
}

class WorkersInFarmData {
  final String? hasRecruitedWorker;
  final String? everRecruitedWorker;
  final String? workerAgreementType;
  final String? tasksClarified;
  final String? additionalTasks;
  final String? refusalAction;
  final String? salaryPaymentFrequency;
  final bool permanentLabor;
  final bool casualLabor;
  final String otherAgreement;
  final Map<String, String?> agreementResponses;

  const WorkersInFarmData({
    this.hasRecruitedWorker,
    this.everRecruitedWorker,
    this.workerAgreementType,
    this.tasksClarified,
    this.additionalTasks,
    this.refusalAction,
    this.salaryPaymentFrequency,
    this.permanentLabor = false,
    this.casualLabor = false,
    this.otherAgreement = '',
    this.agreementResponses = const {
      'salary_workers': null,
      'recruit_1': null,
      'recruit_2': null,
      'recruit_3': null,
      'conditions_1': null,
      'conditions_2': null,
      'conditions_3': null,
      'conditions_4': null,
      'conditions_5': null,
      'leaving_1': null,
      'leaving_2': null,
    },
  });

  WorkersInFarmData copyWith({
    String? hasRecruitedWorker,
    String? everRecruitedWorker,
    String? workerAgreementType,
    String? tasksClarified,
    String? additionalTasks,
    String? refusalAction,
    String? salaryPaymentFrequency,
    bool? permanentLabor,
    bool? casualLabor,
    String? otherAgreement,
    Map<String, String?>? agreementResponses,
  }) {
    return WorkersInFarmData(
      hasRecruitedWorker: hasRecruitedWorker ?? this.hasRecruitedWorker,
      everRecruitedWorker: everRecruitedWorker ?? this.everRecruitedWorker,
      workerAgreementType: workerAgreementType ?? this.workerAgreementType,
      tasksClarified: tasksClarified ?? this.tasksClarified,
      additionalTasks: additionalTasks ?? this.additionalTasks,
      refusalAction: refusalAction ?? this.refusalAction,
      salaryPaymentFrequency:
          salaryPaymentFrequency ?? this.salaryPaymentFrequency,
      permanentLabor: permanentLabor ?? this.permanentLabor,
      casualLabor: casualLabor ?? this.casualLabor,
      otherAgreement: otherAgreement ?? this.otherAgreement,
      agreementResponses: agreementResponses ?? this.agreementResponses,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'hasRecruitedWorker': hasRecruitedWorker,
      'everRecruitedWorker': everRecruitedWorker,
      'workerAgreementType': workerAgreementType,
      'tasksClarified': tasksClarified,
      'additionalTasks': additionalTasks,
      'refusalAction': refusalAction,
      'salaryPaymentFrequency': salaryPaymentFrequency,
      'permanentLabor': permanentLabor,
      'casualLabor': casualLabor,
      'otherAgreement': otherAgreement,
      'agreementResponses': agreementResponses,
    };
  }

  factory WorkersInFarmData.fromMap(Map<String, dynamic> map) {
    return WorkersInFarmData(
      hasRecruitedWorker: map['hasRecruitedWorker'],
      everRecruitedWorker: map['everRecruitedWorker'],
      workerAgreementType: map['workerAgreementType'],
      tasksClarified: map['tasksClarified'],
      additionalTasks: map['additionalTasks'],
      refusalAction: map['refusalAction'],
      salaryPaymentFrequency: map['salaryPaymentFrequency'],
      permanentLabor: map['permanentLabor'] ?? false,
      casualLabor: map['casualLabor'] ?? false,
      otherAgreement: map['otherAgreement'] ?? '',
      agreementResponses: Map<String, String?>.from(map['agreementResponses'] ??
          {
            'salary_workers': null,
            'recruit_1': null,
            'recruit_2': null,
            'recruit_3': null,
            'conditions_1': null,
            'conditions_2': null,
            'conditions_3': null,
            'conditions_4': null,
            'conditions_5': null,
            'leaving_1': null,
            'leaving_2': null,
          }),
    );
  }

  static WorkersInFarmData empty() {
    return const WorkersInFarmData();
  }

  bool get isFormComplete {
    if (hasRecruitedWorker == null) return false;

    if (hasRecruitedWorker == '1') {
      if (!permanentLabor && !casualLabor) return false;
      if (agreementResponses.values.any((response) => response == null)) {
        return false;
      }
    }

    if (hasRecruitedWorker == '0') {
      if (everRecruitedWorker == null) return false;
      if (everRecruitedWorker == 'Yes' &&
          agreementResponses.values.any((response) => response == null)) {
        return false;
      }
    }

    if (refusalAction == 'Other' && otherAgreement.trim().isEmpty) {
      return false;
    }

    if (salaryPaymentFrequency == null) return false;

    if (hasRecruitedWorker == '1' ||
        (hasRecruitedWorker == '0' && everRecruitedWorker == 'Yes')) {
      for (var response in agreementResponses.values) {
        if (response == null) return false;
      }
    }

    return true;
  }
}

class AdultsInformationData {
  final int? numberOfAdults;
  final List<HouseholdMember> members;

  const AdultsInformationData({
    this.numberOfAdults,
    this.members = const [],
  });

  AdultsInformationData copyWith({
    int? numberOfAdults,
    List<HouseholdMember>? members,
  }) {
    return AdultsInformationData(
      numberOfAdults: numberOfAdults ?? this.numberOfAdults,
      members: members ?? this.members,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'numberOfAdults': numberOfAdults,
      'members': members.map((member) => member.toMap()).toList(),
    };
  }

  factory AdultsInformationData.fromMap(Map<String, dynamic> map) {
    return AdultsInformationData(
      numberOfAdults: map['numberOfAdults'],
      members: List<HouseholdMember>.from(
        (map['members'] ?? []).map((x) => HouseholdMember.fromMap(x)),
      ),
    );
  }

  static AdultsInformationData empty() {
    return const AdultsInformationData();
  }

  bool get isFormComplete {
    if (numberOfAdults == null || numberOfAdults == 0) return false;

    for (final member in members) {
      if (!member.isNameValid || !member.producerDetails.isComplete) {
        return false;
      }
    }

    return true;
  }
}

class HouseholdMember {
  final String name;
  final ProducerDetailsModel producerDetails;

  const HouseholdMember({
    this.name = '',
    this.producerDetails = const ProducerDetailsModel(),
  });

  HouseholdMember copyWith({
    String? name,
    ProducerDetailsModel? producerDetails,
  }) {
    return HouseholdMember(
      name: name ?? this.name,
      producerDetails: producerDetails ?? this.producerDetails,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'producerDetails': producerDetails.toMap(),
    };
  }

  factory HouseholdMember.fromMap(Map<String, dynamic> map) {
    return HouseholdMember(
      name: map['name'] ?? '',
      producerDetails:
          ProducerDetailsModel.fromMap(map['producerDetails'] ?? {}),
    );
  }

  bool get isNameValid {
    return name.trim().isNotEmpty && name.trim().split(' ').length >= 2;
  }
}

class ProducerDetailsModel {
  final String? gender;
  final String? nationality;
  final int? yearOfBirth;
  final String? selectedCountry;
  final String? ghanaCardId;
  final String? otherIdType;
  final String? otherIdNumber;
  final bool? consentToTakePhoto;
  final String? noConsentReason;
  final String? idPhotoPath;
  final String? relationshipToRespondent;
  final String? otherRelationship;
  final String? hasBirthCertificate;
  final String? occupation;
  final String? otherOccupation;

  const ProducerDetailsModel({
    this.gender,
    this.nationality,
    this.yearOfBirth,
    this.selectedCountry,
    this.ghanaCardId,
    this.otherIdType,
    this.otherIdNumber,
    this.consentToTakePhoto,
    this.noConsentReason,
    this.idPhotoPath,
    this.relationshipToRespondent,
    this.otherRelationship,
    this.hasBirthCertificate,
    this.occupation,
    this.otherOccupation,
  });

  ProducerDetailsModel copyWith({
    String? gender,
    String? nationality,
    int? yearOfBirth,
    String? selectedCountry,
    String? ghanaCardId,
    String? otherIdType,
    String? otherIdNumber,
    bool? consentToTakePhoto,
    String? noConsentReason,
    String? idPhotoPath,
    String? relationshipToRespondent,
    String? otherRelationship,
    String? hasBirthCertificate,
    String? occupation,
    String? otherOccupation,
  }) {
    return ProducerDetailsModel(
      gender: gender ?? this.gender,
      nationality: nationality ?? this.nationality,
      yearOfBirth: yearOfBirth ?? this.yearOfBirth,
      selectedCountry: selectedCountry ?? this.selectedCountry,
      ghanaCardId: ghanaCardId ?? this.ghanaCardId,
      otherIdType: otherIdType ?? this.otherIdType,
      otherIdNumber: otherIdNumber ?? this.otherIdNumber,
      consentToTakePhoto: consentToTakePhoto ?? this.consentToTakePhoto,
      noConsentReason: noConsentReason ?? this.noConsentReason,
      idPhotoPath: idPhotoPath ?? this.idPhotoPath,
      relationshipToRespondent:
          relationshipToRespondent ?? this.relationshipToRespondent,
      otherRelationship: otherRelationship ?? this.otherRelationship,
      hasBirthCertificate: hasBirthCertificate ?? this.hasBirthCertificate,
      occupation: occupation ?? this.occupation,
      otherOccupation: otherOccupation ?? this.otherOccupation,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'gender': gender,
      'nationality': nationality,
      'yearOfBirth': yearOfBirth,
      'selectedCountry': selectedCountry,
      'ghanaCardId': ghanaCardId,
      'otherIdType': otherIdType,
      'otherIdNumber': otherIdNumber,
      'consentToTakePhoto': consentToTakePhoto,
      'noConsentReason': noConsentReason,
      'idPhotoPath': idPhotoPath,
      'relationshipToRespondent': relationshipToRespondent,
      'otherRelationship': otherRelationship,
      'hasBirthCertificate': hasBirthCertificate,
      'occupation': occupation,
      'otherOccupation': otherOccupation,
    };
  }

  factory ProducerDetailsModel.fromMap(Map<String, dynamic> map) {
    return ProducerDetailsModel(
      gender: map['gender'],
      nationality: map['nationality'],
      yearOfBirth: map['yearOfBirth'],
      selectedCountry: map['selectedCountry'],
      ghanaCardId: map['ghanaCardId'],
      otherIdType: map['otherIdType'],
      otherIdNumber: map['otherIdNumber'],
      consentToTakePhoto: map['consentToTakePhoto'],
      noConsentReason: map['noConsentReason'],
      idPhotoPath: map['idPhotoPath'],
      relationshipToRespondent: map['relationshipToRespondent'],
      otherRelationship: map['otherRelationship'],
      hasBirthCertificate: map['hasBirthCertificate'],
      occupation: map['occupation'],
      otherOccupation: map['otherOccupation'],
    );
  }

  bool get isComplete {
    return gender != null &&
        nationality != null &&
        yearOfBirth != null &&
        relationshipToRespondent != null &&
        hasBirthCertificate != null &&
        occupation != null &&
        (nationality != 'non_ghanaian' || selectedCountry != null) &&
        _isGhanaCardComplete &&
        _isConsentComplete;
  }

  bool get _isGhanaCardComplete {
    if (ghanaCardId != null && ghanaCardId!.isNotEmpty) {
      return true;
    }
    if (otherIdType != null && otherIdType != 'none') {
      return otherIdNumber != null && otherIdNumber!.isNotEmpty;
    }
    if (otherIdType == 'none') {
      return true;
    }
    return false;
  }

  bool get _isConsentComplete {
    final hasValidId = (ghanaCardId != null && ghanaCardId!.isNotEmpty) ||
        (otherIdType != null && otherIdType != 'none');

    if (!hasValidId) {
      return true;
    }

    if (consentToTakePhoto == true) {
      return true;
    }
    if (consentToTakePhoto == false) {
      return noConsentReason != null && noConsentReason!.isNotEmpty;
    }
    return false;
  }
}

class CountryLists {
  static final List<Map<String, String>> countries = [
    {'value': 'Burkina Faso', 'display': 'Burkina Faso'},
    {'value': 'Mali', 'display': 'Mali'},
    {'value': 'Guinea', 'display': 'Guinea'},
    {'value': 'Ivory Coast', 'display': 'Ivory Coast'},
    {'value': 'Liberia', 'display': 'Liberia'},
    {'value': 'Togo', 'display': 'Togo'},
    {'value': 'Benin', 'display': 'Benin'},
    {'value': 'Niger', 'display': 'Niger'},
    {'value': 'Nigeria', 'display': 'Nigeria'},
    {'value': 'Other', 'display': 'Other (specify)'},
  ];

  static final List<Map<String, String>> nationalityOptions = [
    {'value': 'Burkina Faso', 'display': 'Burkina Faso'},
    {'value': 'Mali', 'display': 'Mali'},
    {'value': 'Guinea', 'display': 'Guinea'},
    {'value': 'Ivory Coast', 'display': 'Ivory Coast'},
    {'value': 'Liberia', 'display': 'Liberia'},
    {'value': 'Togo', 'display': 'Togo'},
    {'value': 'Benin', 'display': 'Benin'},
    {'value': 'Other', 'display': 'Other (specify)'},
  ];
}

/// A collection of reusable spacing constants for consistent UI layout.
class _Spacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

// ===========================================================================
// MAIN COMBINED PAGE
// ===========================================================================

class CombinedFarmIdentificationPage extends StatefulWidget {
  final int initialPageIndex;
  final ValueChanged<int> onPageChanged;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback? onSubmit;

  // Add this to check if we can go to next sub-page
  final ValueChanged<bool>? onCanProceedChanged;

  const CombinedFarmIdentificationPage({
    super.key,
    this.initialPageIndex = 0,
    required this.onPageChanged,
    this.onPrevious,
    this.onNext,
    this.onSubmit,
    this.onCanProceedChanged,
  });

  @override
  State<CombinedFarmIdentificationPage> createState() =>
      _CombinedFarmIdentificationPageState();
}

class _CombinedFarmIdentificationPageState
    extends State<CombinedFarmIdentificationPage> {
  late PageController _pageController;
  late int _currentPageIndex;
  final int _totalPages = 4;

  // Individual models for each page
  VisitInformationData _visitInfoData = VisitInformationData.empty();
  IdentificationOfOwnerData _ownerData = IdentificationOfOwnerData.empty();
  WorkersInFarmData _workersData = WorkersInFarmData.empty();
  AdultsInformationData _adultsData = AdultsInformationData.empty();

  @override
  void initState() {
    super.initState();
    _currentPageIndex = widget.initialPageIndex;
    _pageController = PageController(initialPage: _currentPageIndex);
    _notifyCanProceed();
  }

  @override
  void didUpdateWidget(CombinedFarmIdentificationPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Remove the jumpToPage call here to avoid circular dependencies
    if (oldWidget.initialPageIndex != widget.initialPageIndex) {
      _currentPageIndex = widget.initialPageIndex;
    }
  }

  bool get _isCurrentPageComplete {
    switch (_currentPageIndex) {
      case 0:
        return _visitInfoData.isFormComplete;
      case 1:
        return _ownerData.isFormComplete;
      case 2:
        return _workersData.isFormComplete;
      case 3:
        return _adultsData.isFormComplete;
      default:
        return false;
    }
  }

  void _notifyCanProceed() {
    widget.onCanProceedChanged?.call(_isCurrentPageComplete);
  }

  void _handlePageChanged(int index) {
    // Only update if the page actually changed
    if (_currentPageIndex != index) {
      setState(() {
        _currentPageIndex = index;
      });
      // Use a post-frame callback to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.onPageChanged(index);
        }
      });
      _notifyCanProceed();
    }
  }

  void _goToNextPage() {
    if (_currentPageIndex < _totalPages - 1 && _isCurrentPageComplete) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else if (_currentPageIndex == _totalPages - 1 && _isCurrentPageComplete) {
      // This is the last sub-page, notify parent to go to next main page
      widget.onNext?.call();
    }
  }

  void _goToPreviousPage() {
    if (_currentPageIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // This is the first sub-page, notify parent to go to previous main page
      widget.onPrevious?.call();
    }
  }

  // Update your data change handlers to check completion
  void _updateVisitInfoData(VisitInformationData newData) {
    setState(() {
      _visitInfoData = newData;
    });
    _notifyCanProceed();
  }

  void _updateOwnerData(IdentificationOfOwnerData newData) {
    setState(() {
      _ownerData = newData;
    });
    _notifyCanProceed();
  }

  void _updateWorkersData(WorkersInFarmData newData) {
    setState(() {
      _workersData = newData;
    });
    _notifyCanProceed();
  }

  void _updateAdultsData(AdultsInformationData newData) {
    setState(() {
      _adultsData = newData;
    });
    _notifyCanProceed();
  }

  void _submitForm() {
    final allData = {
      'visitInformation': _visitInfoData.toMap(),
      'ownerIdentification': _ownerData.toMap(),
      'workersInFarm': _workersData.toMap(),
      'adultsInformation': _adultsData.toMap(),
    };

    print('Submitting all data: $allData');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Submit Survey',
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w600, color: Colors.blue.shade700)),
        content: Text(
            'Are you sure you want to submit the farm identification survey?',
            style: GoogleFonts.inter(color: Colors.grey.shade700)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: GoogleFonts.inter(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Survey submitted successfully!',
                      style: GoogleFonts.inter()),
                  backgroundColor: Colors.green.shade600,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              );
              widget.onSubmit?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child:
                Text('Submit', style: GoogleFonts.inter(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.darkBackground : AppTheme.backgroundColor,
      body: Column(
        children: [
          // Progress indicator for sub-pages
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: _Spacing.lg, vertical: _Spacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Step ${_currentPageIndex + 1} of $_totalPages',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppTheme.darkTextSecondary
                        : AppTheme.textSecondary,
                  ),
                ),
                Text(
                  _getSubPageTitle(_currentPageIndex),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppTheme.darkTextPrimary
                        : AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: _handlePageChanged,
              children: [
                // Page 1: Visit Information
                _VisitInformationContent(
                  data: _visitInfoData,
                  onDataChanged: _updateVisitInfoData,
                ),

                // Page 2: Identification of Owner
                _IdentificationOfOwnerContent(
                  data: _ownerData,
                  onDataChanged: _updateOwnerData,
                ),

                // Page 3: Workers in Farm
                _WorkersInFarmContent(
                  data: _workersData,
                  onDataChanged: _updateWorkersData,
                ),

                // Page 4: Adults Information
                _AdultsInformationPage(
                  data: _adultsData,
                  onDataChanged: _updateAdultsData,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getSubPageTitle(int index) {
    switch (index) {
      case 0:
        return 'Visit Information';
      case 1:
        return 'Owner Identification';
      case 2:
        return 'Workers Information';
      case 3:
        return 'Household Adults';
      default:
        return 'Farm Details';
    }
  }
}

// ===========================================================================
// PAGE 1: VISIT INFORMATION CONTENT
// ===========================================================================

class _VisitInformationContent extends StatefulWidget {
  final VisitInformationData data;
  final ValueChanged<VisitInformationData> onDataChanged;

  const _VisitInformationContent({
    required this.data,
    required this.onDataChanged,
  });

  @override
  State<_VisitInformationContent> createState() =>
      _VisitInformationContentState();
}

class _VisitInformationContentState extends State<_VisitInformationContent> {
  late TextEditingController _respondentNameController;
  late TextEditingController _respondentOtherNamesController;
  late TextEditingController _otherCountryController;

  @override
  void initState() {
    super.initState();
    _respondentNameController =
        TextEditingController(text: widget.data.correctedRespondentName);
    _respondentOtherNamesController =
        TextEditingController(text: widget.data.respondentOtherNames);
    _otherCountryController =
        TextEditingController(text: widget.data.otherCountry);
  }

  @override
  void didUpdateWidget(_VisitInformationContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data.correctedRespondentName != _respondentNameController.text) {
      _respondentNameController.text = widget.data.correctedRespondentName;
    }
    if (widget.data.respondentOtherNames !=
        _respondentOtherNamesController.text) {
      _respondentOtherNamesController.text = widget.data.respondentOtherNames;
    }
    if (widget.data.otherCountry != _otherCountryController.text) {
      _otherCountryController.text = widget.data.otherCountry;
    }
  }

  void _updateData(VisitInformationData newData) {
    widget.onDataChanged(newData);
  }

  @override
  void dispose() {
    _respondentNameController.dispose();
    _respondentOtherNamesController.dispose();
    _otherCountryController.dispose();
    super.dispose();
  }

  Widget _buildQuestionCard({required Widget child}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: _Spacing.lg),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(
          color: isDark ? AppTheme.darkCard : Colors.grey.shade200,
          width: 1,
        ),
      ),
      color: isDark ? AppTheme.darkCard : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(_Spacing.lg),
        child: child,
      ),
    );
  }

  Widget _buildRadioOption({
    required String value,
    required String? groupValue,
    required String label,
    required ValueChanged<String?> onChanged,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return RadioListTile<String>(
      title: Text(
        label,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: isDark ? AppTheme.darkTextSecondary : AppTheme.textPrimary,
        ),
      ),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: AppTheme.primaryColor,
      contentPadding: EdgeInsets.zero,
      dense: true,
      controlAffinity: ListTileControlAffinity.leading,
      tileColor: isDark ? AppTheme.darkCard : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
    String hintText = '',
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(
            color: isDark ? AppTheme.darkTextSecondary : AppTheme.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: _Spacing.md),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color:
                  isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: isDark ? AppTheme.darkCard : Colors.grey.shade300,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: isDark ? AppTheme.darkCard : Colors.grey.shade300,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: theme.primaryColor,
                width: 1.5,
              ),
            ),
            filled: true,
            fillColor: isDark ? AppTheme.darkCard : Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: _Spacing.lg,
              vertical: _Spacing.md,
            ),
          ),
          style: theme.textTheme.bodyLarge?.copyWith(
            color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<Map<String, String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(
            color: isDark ? AppTheme.darkTextSecondary : AppTheme.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: _Spacing.sm),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
              color: isDark ? AppTheme.darkCard : Colors.grey.shade300,
            ),
            color: isDark ? AppTheme.darkCard : Colors.white,
          ),
          padding: const EdgeInsets.symmetric(horizontal: _Spacing.md),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down, color: theme.primaryColor),
              iconSize: 24,
              elevation: 16,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
              ),
              onChanged: onChanged,
              dropdownColor: isDark ? AppTheme.darkCard : Colors.white,
              items: items
                  .map<DropdownMenuItem<String>>((Map<String, String> item) {
                return DropdownMenuItem<String>(
                  value: item['value'],
                  child: Text(
                    item['display']!,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: isDark
                          ? AppTheme.darkTextPrimary
                          : AppTheme.textPrimary,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(_Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name Confirmation Question
          _buildQuestionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Is the respondent's name correct?",
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: isDark
                        ? AppTheme.darkTextSecondary
                        : AppTheme.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: _Spacing.md),
                Wrap(
                  spacing: 20,
                  children: [
                    _buildRadioOption(
                      value: 'Yes',
                      groupValue: widget.data.respondentNameCorrect,
                      label: 'Yes',
                      onChanged: (value) {
                        _updateData(widget.data.copyWith(
                          respondentNameCorrect: value,
                          correctedRespondentName: value == 'Yes'
                              ? ''
                              : widget.data.correctedRespondentName,
                        ));
                      },
                    ),
                    _buildRadioOption(
                      value: 'No',
                      groupValue: widget.data.respondentNameCorrect,
                      label: 'No',
                      onChanged: (value) {
                        _updateData(widget.data.copyWith(
                          respondentNameCorrect: value,
                        ));
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Show the name field when "No" is selected
          if (widget.data.respondentNameCorrect == 'No') ...[
            _buildQuestionCard(
              child: _buildTextField(
                label: 'If No, fill the exact surname of the producer?',
                controller: _respondentNameController,
                onChanged: (value) {
                  _updateData(
                      widget.data.copyWith(correctedRespondentName: value));
                },
                hintText: 'Enter surname',
              ),
            ),
            const SizedBox(height: 16),
            _buildQuestionCard(
              child: _buildTextField(
                label:
                    'If No, fill the exact first and other names of the producer?',
                controller: _respondentOtherNamesController,
                onChanged: (value) {
                  _updateData(
                      widget.data.copyWith(respondentOtherNames: value));
                },
                hintText: 'Enter first and other names',
              ),
            ),
          ],

          // Nationality Question
          if ((widget.data.respondentNameCorrect == 'Yes' ||
              (widget.data.respondentNameCorrect == 'No' &&
                  _respondentNameController.text.isNotEmpty)))
            _buildQuestionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What is the nationality of the respondent ?',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: isDark
                          ? AppTheme.darkTextSecondary
                          : AppTheme.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: _Spacing.md),
                  Wrap(
                    spacing: 20,
                    children: [
                      _buildRadioOption(
                        value: 'Ghanaian',
                        groupValue: widget.data.respondentNationality,
                        label: 'Ghanaian',
                        onChanged: (value) {
                          _updateData(widget.data.copyWith(
                            respondentNationality: value,
                            countryOfOrigin: null,
                            otherCountry: '',
                          ));
                        },
                      ),
                      _buildRadioOption(
                        value: 'Non-Ghanaian',
                        groupValue: widget.data.respondentNationality,
                        label: 'Non-Ghanaian',
                        onChanged: (value) {
                          _updateData(widget.data.copyWith(
                            respondentNationality: value,
                          ));
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // Country of Origin (only shown for non-Ghanaian respondents)
          if (widget.data.respondentNationality == 'Non-Ghanaian')
            _buildQuestionCard(
              child: _buildDropdownField(
                label: 'If Non-Ghanaian, specify the country of origin',
                value: widget.data.countryOfOrigin,
                items: CountryLists.countries,
                onChanged: (value) {
                  _updateData(widget.data.copyWith(
                    countryOfOrigin: value,
                    otherCountry:
                        value != 'Other' ? '' : widget.data.otherCountry,
                  ));
                },
              ),
            ),

          // Other Country Specification
          if (widget.data.respondentNationality == 'Non-Ghanaian' &&
              widget.data.countryOfOrigin == 'Other')
            _buildQuestionCard(
              child: _buildTextField(
                label: 'If Other, please specify',
                controller: _otherCountryController,
                onChanged: (value) {
                  _updateData(widget.data.copyWith(otherCountry: value));
                },
                hintText: 'Enter country name',
              ),
            ),

          // Farm Ownership Question
          if (widget.data.respondentNationality != null &&
              (widget.data.respondentNationality == 'Ghanaian' ||
                  (widget.data.respondentNationality == 'Non-Ghanaian' &&
                      widget.data.countryOfOrigin != null &&
                      (widget.data.countryOfOrigin != 'Other' ||
                          _otherCountryController.text.isNotEmpty))))
            _buildQuestionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Is the respondent the owner of this farm?',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: isDark
                          ? AppTheme.darkTextSecondary
                          : AppTheme.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: _Spacing.md),
                  Wrap(
                    spacing: 20,
                    children: [
                      _buildRadioOption(
                        value: 'Yes',
                        groupValue: widget.data.isFarmOwner,
                        label: 'Yes',
                        onChanged: (value) {
                          _updateData(widget.data.copyWith(
                            isFarmOwner: value,
                            farmOwnershipType: value == 'Yes'
                                ? null
                                : widget.data.farmOwnershipType,
                          ));
                        },
                      ),
                      _buildRadioOption(
                        value: 'No',
                        groupValue: widget.data.isFarmOwner,
                        label: 'No',
                        onChanged: (value) {
                          _updateData(widget.data.copyWith(
                            isFarmOwner: value,
                            farmOwnershipType: value == 'No'
                                ? null
                                : widget.data.farmOwnershipType,
                          ));
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // Farm Ownership Type (shown when respondent is the farm owner)
          if (widget.data.isFarmOwner == 'Yes' ||
              widget.data.isFarmOwner == 'No')
            _buildQuestionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Which of these best describes you?',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: isDark
                          ? AppTheme.darkTextSecondary
                          : AppTheme.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: _Spacing.md),
                  Column(
                    children: [
                      _buildRadioOption(
                        value: 'Complete Owner',
                        groupValue: widget.data.farmOwnershipType,
                        label: 'Complete Owner',
                        onChanged: (value) {
                          _updateData(
                              widget.data.copyWith(farmOwnershipType: value));
                        },
                      ),
                      _buildRadioOption(
                        value: 'Sharecropper',
                        groupValue: widget.data.farmOwnershipType,
                        label: 'Sharecropper',
                        onChanged: (value) {
                          _updateData(
                              widget.data.copyWith(farmOwnershipType: value));
                        },
                      ),
                      _buildRadioOption(
                        value: 'Owner/Sharecropper',
                        groupValue: widget.data.farmOwnershipType,
                        label: 'Owner/Sharecropper',
                        onChanged: (value) {
                          _updateData(
                              widget.data.copyWith(farmOwnershipType: value));
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

// ===========================================================================
// PAGE 2: IDENTIFICATION OF OWNER CONTENT
// ===========================================================================

class _IdentificationOfOwnerContent extends StatefulWidget {
  final IdentificationOfOwnerData data;
  final ValueChanged<IdentificationOfOwnerData> onDataChanged;

  const _IdentificationOfOwnerContent({
    required this.data,
    required this.onDataChanged,
  });

  @override
  State<_IdentificationOfOwnerContent> createState() =>
      _IdentificationOfOwnerContentState();
}

class _IdentificationOfOwnerContentState
    extends State<_IdentificationOfOwnerContent> {
  late TextEditingController _ownerNameController;
  late TextEditingController _ownerFirstNameController;
  late TextEditingController _otherNationalityController;
  late TextEditingController _yearsWithOwnerController;

  @override
  void initState() {
    super.initState();
    _ownerNameController = TextEditingController(text: widget.data.ownerName);
    _ownerFirstNameController =
        TextEditingController(text: widget.data.ownerFirstName);
    _otherNationalityController =
        TextEditingController(text: widget.data.otherNationality);
    _yearsWithOwnerController =
        TextEditingController(text: widget.data.yearsWithOwner);
  }

  @override
  void didUpdateWidget(_IdentificationOfOwnerContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data.ownerName != _ownerNameController.text) {
      _ownerNameController.text = widget.data.ownerName;
    }
    if (widget.data.ownerFirstName != _ownerFirstNameController.text) {
      _ownerFirstNameController.text = widget.data.ownerFirstName;
    }
    if (widget.data.otherNationality != _otherNationalityController.text) {
      _otherNationalityController.text = widget.data.otherNationality;
    }
    if (widget.data.yearsWithOwner != _yearsWithOwnerController.text) {
      _yearsWithOwnerController.text = widget.data.yearsWithOwner;
    }
  }

  void _updateData(IdentificationOfOwnerData newData) {
    widget.onDataChanged(newData);
  }

  @override
  void dispose() {
    _ownerNameController.dispose();
    _ownerFirstNameController.dispose();
    _otherNationalityController.dispose();
    _yearsWithOwnerController.dispose();
    super.dispose();
  }

  Widget _buildQuestionCard({required Widget child}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: _Spacing.lg),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(
          color: isDark ? AppTheme.darkCard : Colors.grey.shade200,
          width: 1,
        ),
      ),
      color: isDark ? AppTheme.darkCard : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(_Spacing.lg),
        child: child,
      ),
    );
  }

  Widget _buildRadioOption({
    required String value,
    required String? groupValue,
    required String label,
    required ValueChanged<String?> onChanged,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return RadioListTile<String>(
      title: Text(
        label,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: isDark ? AppTheme.darkTextSecondary : AppTheme.textPrimary,
        ),
      ),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: AppTheme.primaryColor,
      contentPadding: EdgeInsets.zero,
      dense: true,
      controlAffinity: ListTileControlAffinity.leading,
      tileColor: isDark ? AppTheme.darkCard : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
    String hintText = '',
    TextInputType? keyboardType,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(
            color: isDark ? AppTheme.darkTextSecondary : AppTheme.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: _Spacing.md),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color:
                  isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: isDark ? AppTheme.darkCard : Colors.grey.shade300,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: isDark ? AppTheme.darkCard : Colors.grey.shade300,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: theme.primaryColor,
                width: 1.5,
              ),
            ),
            filled: true,
            fillColor: isDark ? AppTheme.darkCard : Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: _Spacing.lg,
              vertical: _Spacing.md,
            ),
          ),
          style: theme.textTheme.bodyLarge?.copyWith(
            color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<Map<String, String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(
            color: isDark ? AppTheme.darkTextSecondary : AppTheme.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: _Spacing.sm),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
              color: isDark ? AppTheme.darkCard : Colors.grey.shade300,
            ),
            color: isDark ? AppTheme.darkCard : Colors.white,
          ),
          padding: const EdgeInsets.symmetric(horizontal: _Spacing.md),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down, color: theme.primaryColor),
              iconSize: 24,
              elevation: 16,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
              ),
              onChanged: onChanged,
              dropdownColor: isDark ? AppTheme.darkCard : Colors.white,
              items: items
                  .map<DropdownMenuItem<String>>((Map<String, String> item) {
                return DropdownMenuItem<String>(
                  value: item['value'],
                  child: Text(
                    item['display']!,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: isDark
                          ? AppTheme.darkTextPrimary
                          : AppTheme.textPrimary,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(_Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Owner Name
          _buildQuestionCard(
            child: _buildTextField(
              label: 'Name of the owner?',
              controller: _ownerNameController,
              onChanged: (value) {
                _updateData(widget.data.copyWith(ownerName: value));
              },
              hintText:
                  'Verify this information with his identification document or any other document of identification. In capital letters',
            ),
          ),

          // Owner First Name
          _buildQuestionCard(
            child: _buildTextField(
              label: 'First name of the owner?',
              controller: _ownerFirstNameController,
              onChanged: (value) {
                _updateData(widget.data.copyWith(ownerFirstName: value));
              },
              hintText:
                  'Verify this information with his identification document or any other document of identification. In capital letters',
            ),
          ),

          // Nationality Card
          _buildQuestionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What is the nationality of the owner?',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppTheme.darkTextSecondary
                            : AppTheme.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: _Spacing.md),
                Wrap(
                  spacing: 20,
                  children: [
                    _buildRadioOption(
                      value: 'Ghanaian',
                      groupValue: widget.data.nationality,
                      label: 'Ghanaian',
                      onChanged: (value) {
                        _updateData(widget.data.copyWith(
                          nationality: value,
                          specificNationality: null,
                          otherNationality: '',
                        ));
                      },
                    ),
                    _buildRadioOption(
                      value: 'Non-Ghanaian',
                      groupValue: widget.data.nationality,
                      label: 'Non-Ghanaian',
                      onChanged: (value) {
                        _updateData(widget.data.copyWith(
                          nationality: value,
                        ));
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Show nationality selection only if Non-Ghanaian is selected
          if (widget.data.nationality == 'Non-Ghanaian')
            _buildQuestionCard(
              child: _buildDropdownField(
                label: 'If Non Ghanaian , specify country of origin',
                value: widget.data.specificNationality,
                items: CountryLists.nationalityOptions,
                onChanged: (value) {
                  _updateData(widget.data.copyWith(
                    specificNationality: value,
                    otherNationality:
                        value != 'Other' ? '' : widget.data.otherNationality,
                  ));
                },
              ),
            ),

          // Show 'Other' specification when 'Other' is selected
          if (widget.data.nationality == 'Non-Ghanaian' &&
              widget.data.specificNationality == 'Other')
            _buildQuestionCard(
              child: _buildTextField(
                label: 'Please specify nationality',
                controller: _otherNationalityController,
                onChanged: (value) {
                  _updateData(widget.data.copyWith(otherNationality: value));
                },
                hintText: 'Enter nationality',
              ),
            ),

          // Years working with owner
          _buildQuestionCard(
            child: _buildTextField(
              label:
                  'For how many years has the respondent been working with owner?',
              controller: _yearsWithOwnerController,
              onChanged: (value) {
                _updateData(widget.data.copyWith(yearsWithOwner: value));
              },
              keyboardType: TextInputType.number,
              hintText: 'Enter number of years',
            ),
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

// ===========================================================================
// PAGE 3: WORKERS IN FARM CONTENT
// ===========================================================================

class _WorkersInFarmContent extends StatefulWidget {
  final WorkersInFarmData data;
  final ValueChanged<WorkersInFarmData> onDataChanged;

  const _WorkersInFarmContent({
    required this.data,
    required this.onDataChanged,
  });

  @override
  State<_WorkersInFarmContent> createState() => _WorkersInFarmContentState();
}

class _WorkersInFarmContentState extends State<_WorkersInFarmContent> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _otherAgreementController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing data
    _otherAgreementController.text = widget.data.otherAgreement;
  }

  @override
  void didUpdateWidget(_WorkersInFarmContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data.otherAgreement != _otherAgreementController.text) {
      _otherAgreementController.text = widget.data.otherAgreement;
    }
  }

  void _updateData(WorkersInFarmData newData) {
    widget.onDataChanged(newData);
  }

  @override
  void dispose() {
    _otherAgreementController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildRecruitmentTypeCheckbox({
    required bool value,
    required String label,
    required ValueChanged<bool?> onChanged,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return CheckboxListTile(
      title: Text(
        label,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: isDark ? AppTheme.darkTextSecondary : AppTheme.textPrimary,
        ),
      ),
      value: value,
      onChanged: (value) {
        onChanged(value);
        _updateParentData();
      },
      activeColor: AppTheme.primaryColor,
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
      dense: true,
    );
  }

  Widget _buildRadioOption({
    required String value,
    required String? groupValue,
    required String label,
    required ValueChanged<String?> onChanged,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return RadioListTile<String>(
      title: Text(
        label,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: isDark ? AppTheme.darkTextSecondary : AppTheme.textPrimary,
        ),
      ),
      value: value,
      groupValue: groupValue,
      onChanged: (newValue) {
        // Call the onChanged callback which should update the state
        onChanged(newValue);
      },
      activeColor: AppTheme.primaryColor,
      contentPadding: EdgeInsets.zero,
      dense: true,
      controlAffinity: ListTileControlAffinity.leading,
      tileColor: isDark ? AppTheme.darkCard : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }

  Widget _buildCard({
    required Widget child,
    double? elevation,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: elevation ?? 0,
      margin: const EdgeInsets.only(bottom: _Spacing.lg),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(
          color: isDark ? AppTheme.darkCard : Colors.grey.shade200,
          width: 1,
        ),
      ),
      color: isDark ? AppTheme.darkCard : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(_Spacing.lg),
        child: child,
      ),
    );
  }

  Widget _buildAgreementSection({
    required List<String> statements,
    required List<String> ids,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: _Spacing.md),
        ...List.generate(statements.length, (index) {
          return _buildAgreementCard(
            statement: '${index + 1}. ${statements[index]}',
            statementId: ids[index],
          );
        }),
      ],
    );
  }

  Widget _buildAgreementCard({
    required String statement,
    required String statementId,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            statement,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.normal,
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: _Spacing.md),
          Row(
            children: [
              _buildAgreementButton(
                label: 'Agree',
                isSelected:
                    widget.data.agreementResponses[statementId] == 'Agree',
                onPressed: () {
                  setState(() {
                    final newResponses = Map<String, String?>.from(
                        widget.data.agreementResponses);
                    newResponses[statementId] = 'Agree';
                    _updateData(
                        widget.data.copyWith(agreementResponses: newResponses));
                  });
                },
              ),
              const SizedBox(width: 16),
              _buildAgreementButton(
                label: 'Disagree',
                isSelected:
                    widget.data.agreementResponses[statementId] == 'Disagree',
                onPressed: () {
                  setState(() {
                    final newResponses = Map<String, String?>.from(
                        widget.data.agreementResponses);
                    newResponses[statementId] = 'Disagree';
                    _updateData(
                        widget.data.copyWith(agreementResponses: newResponses));
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAgreementButton({
    required String label,
    required bool isSelected,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: isSelected
              ? AppTheme.primaryColor.withOpacity(0.1)
              : Colors.transparent,
          side: BorderSide(
            color: isSelected
                ? AppTheme.primaryColor
                : isDark
                    ? Colors.grey.shade700
                    : Colors.grey.shade300,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: const EdgeInsets.symmetric(vertical: _Spacing.md),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: isSelected
                ? AppTheme.primaryColor
                : isDark
                    ? AppTheme.darkTextSecondary
                    : AppTheme.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
    String hintText = '',
    int maxLines = 1,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(
            color: isDark ? AppTheme.darkTextSecondary : AppTheme.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: _Spacing.md),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          onChanged: (value) {
            onChanged(value);
            _updateParentData();
          },
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 10.0,
            ),
          ),
        ),
      ],
    );
  }

  void _updateParentData() {
    // Update the parent data whenever any field changes
    _updateData(widget.data.copyWith(
      otherAgreement: _otherAgreementController.text,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(_Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // First Card: Recruitment Question
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Have you recruited at least one worker during the past year?',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppTheme.darkTextPrimary
                        : AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: _Spacing.md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRadioOption(
                      value: '1',
                      groupValue: widget.data.hasRecruitedWorker,
                      label: 'Yes',
                      onChanged: (value) {
                        setState(() {
                          _updateData(
                              widget.data.copyWith(hasRecruitedWorker: value));
                        });
                      },
                    ),
                    _buildRadioOption(
                      value: '0',
                      groupValue: widget.data.hasRecruitedWorker,
                      label: 'No',
                      onChanged: (value) {
                        setState(() {
                          _updateData(widget.data.copyWith(
                            hasRecruitedWorker: value,
                            permanentLabor: false,
                            casualLabor: false,
                          ));
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Worker Recruitment Type Card (Conditional)
          if (widget.data.hasRecruitedWorker == '1') ...[
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Do you recruit workers for...',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppTheme.darkTextPrimary
                          : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: _Spacing.md),
                  _buildRecruitmentTypeCheckbox(
                    value: widget.data.permanentLabor,
                    label: 'Permanent labor',
                    onChanged: (value) {
                      setState(() {
                        _updateData(widget.data
                            .copyWith(permanentLabor: value ?? false));
                      });
                    },
                  ),
                  _buildRecruitmentTypeCheckbox(
                    value: widget.data.casualLabor,
                    label: 'Casual labor',
                    onChanged: (value) {
                      setState(() {
                        _updateData(
                            widget.data.copyWith(casualLabor: value ?? false));
                      });
                    },
                  ),
                ],
              ),
            ),
          ],

          // Second Card: Follow-up question when 'No' is selected in the first question
          if (widget.data.hasRecruitedWorker == '0')
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Have you ever recruited a worker before?',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppTheme.darkTextPrimary
                          : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: _Spacing.md),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRadioOption(
                        value: 'Yes',
                        groupValue: widget.data.everRecruitedWorker,
                        label: 'Yes',
                        onChanged: (value) {
                          setState(() {
                            _updateData(widget.data
                                .copyWith(everRecruitedWorker: value));
                          });
                        },
                      ),
                      _buildRadioOption(
                        value: 'No',
                        groupValue: widget.data.everRecruitedWorker,
                        label: 'No',
                        onChanged: (value) {
                          setState(() {
                            _updateData(widget.data
                                .copyWith(everRecruitedWorker: value));
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // Workers Recruitment Title
          Padding(
            padding:
                const EdgeInsets.only(top: _Spacing.lg, bottom: _Spacing.sm),
            child: Text(
              'Workers Recruitment',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
              ),
            ),
          ),

          // Worker Agreement Type Card
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What kind of agreement do you have with your workers?',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppTheme.darkTextPrimary
                        : AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: _Spacing.md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRadioOption(
                      value: 'Verbal agreement without witness',
                      groupValue: widget.data.workerAgreementType,
                      label: 'Verbal agreement without witness',
                      onChanged: (value) {
                        setState(() {
                          _updateData(
                              widget.data.copyWith(workerAgreementType: value));
                        });
                      },
                    ),
                    _buildRadioOption(
                      value: 'Verbal agreement with witness',
                      groupValue: widget.data.workerAgreementType,
                      label: 'Verbal agreement with witness',
                      onChanged: (value) {
                        setState(() {
                          _updateData(
                              widget.data.copyWith(workerAgreementType: value));
                        });
                      },
                    ),
                    _buildRadioOption(
                      value: 'Written agreement without witness',
                      groupValue: widget.data.workerAgreementType,
                      label: 'Written agreement without witness',
                      onChanged: (value) {
                        setState(() {
                          _updateData(
                              widget.data.copyWith(workerAgreementType: value));
                        });
                      },
                    ),
                    _buildRadioOption(
                      value: 'Written contract with witness',
                      groupValue: widget.data.workerAgreementType,
                      label: 'Written contract with witness',
                      onChanged: (value) {
                        setState(() {
                          _updateData(
                              widget.data.copyWith(workerAgreementType: value));
                        });
                      },
                    ),
                    _buildRadioOption(
                      value: 'Other (specify)',
                      groupValue: widget.data.workerAgreementType,
                      label: 'Other (specify)',
                      onChanged: (value) {
                        setState(() {
                          _updateData(
                              widget.data.copyWith(workerAgreementType: value));
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Other Agreement Type Specification Card
          if (widget.data.workerAgreementType == 'Other (specify)')
            _buildCard(
              child: _buildTextField(
                label: 'If other,please specify',
                controller: _otherAgreementController,
                onChanged: (value) {
                  _updateData(widget.data.copyWith(otherAgreement: value));
                },
                hintText: 'Enter agreement type',
                maxLines: 2,
              ),
            ),

          // Task Clarification Card
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Were the tasks to be performed by the worker clarified with them during the recruitment?',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppTheme.darkTextPrimary
                        : AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: _Spacing.md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRadioOption(
                      value: 'Yes',
                      groupValue: widget.data.tasksClarified,
                      label: 'Yes',
                      onChanged: (value) {
                        setState(() {
                          _updateData(
                              widget.data.copyWith(tasksClarified: value));
                        });
                      },
                    ),
                    _buildRadioOption(
                      value: 'No',
                      groupValue: widget.data.tasksClarified,
                      label: 'No',
                      onChanged: (value) {
                        setState(() {
                          _updateData(
                              widget.data.copyWith(tasksClarified: value));
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Additional tasks question
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Does the worker perform tasks for you or your family members other than those agreed upon?',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppTheme.darkTextPrimary
                        : AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: _Spacing.md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRadioOption(
                      value: 'Yes',
                      groupValue: widget.data.additionalTasks,
                      label: 'Yes',
                      onChanged: (value) {
                        setState(() {
                          _updateData(
                              widget.data.copyWith(additionalTasks: value));
                        });
                      },
                    ),
                    _buildRadioOption(
                      value: 'No',
                      groupValue: widget.data.additionalTasks,
                      label: 'No',
                      onChanged: (value) {
                        setState(() {
                          _updateData(
                              widget.data.copyWith(additionalTasks: value));
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Refusal Action Card
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What do you do when a worker refuses to perform a task?',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppTheme.darkTextPrimary
                        : AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: _Spacing.md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRadioOption(
                      value: 'I find a compromise',
                      groupValue: widget.data.refusalAction,
                      label: 'I find a compromise',
                      onChanged: (value) {
                        setState(() {
                          _updateData(
                              widget.data.copyWith(refusalAction: value));
                        });
                      },
                    ),
                    _buildRadioOption(
                      value: 'I withdraw part of their salary',
                      groupValue: widget.data.refusalAction,
                      label: 'I withdraw part of their salary',
                      onChanged: (value) {
                        setState(() {
                          _updateData(
                              widget.data.copyWith(refusalAction: value));
                        });
                      },
                    ),
                    _buildRadioOption(
                      value: 'I issue a warning',
                      groupValue: widget.data.refusalAction,
                      label: 'I issue a warning',
                      onChanged: (value) {
                        setState(() {
                          _updateData(
                              widget.data.copyWith(refusalAction: value));
                        });
                      },
                    ),
                    _buildRadioOption(
                      value: 'Other',
                      groupValue: widget.data.refusalAction,
                      label: 'Other',
                      onChanged: (value) {
                        setState(() {
                          _updateData(
                              widget.data.copyWith(refusalAction: value));
                        });
                      },
                    ),
                    _buildRadioOption(
                      value: 'Not applicable',
                      groupValue: widget.data.refusalAction,
                      label: 'Not applicable',
                      onChanged: (value) {
                        setState(() {
                          _updateData(
                              widget.data.copyWith(refusalAction: value));
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Additional card for 'Other' specification
          if (widget.data.refusalAction == 'Other')
            _buildCard(
              child: _buildTextField(
                label: 'If other,please specify',
                controller: _otherAgreementController,
                onChanged: (value) {
                  _updateData(widget.data.copyWith(otherAgreement: value));
                },
                hintText: 'Enter your response',
                maxLines: 3,
              ),
            ),

          // Salary payment frequency question
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Do your workers receive their full salaries?',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppTheme.darkTextPrimary
                        : AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: _Spacing.md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRadioOption(
                      value: 'Always',
                      groupValue: widget.data.salaryPaymentFrequency,
                      label: 'Always',
                      onChanged: (value) {
                        setState(() {
                          _updateData(widget.data
                              .copyWith(salaryPaymentFrequency: value));
                        });
                      },
                    ),
                    _buildRadioOption(
                      value: 'Sometimes',
                      groupValue: widget.data.salaryPaymentFrequency,
                      label: 'Sometimes',
                      onChanged: (value) {
                        setState(() {
                          _updateData(widget.data
                              .copyWith(salaryPaymentFrequency: value));
                        });
                      },
                    ),
                    _buildRadioOption(
                      value: 'Rarely',
                      groupValue: widget.data.salaryPaymentFrequency,
                      label: 'Rarely',
                      onChanged: (value) {
                        setState(() {
                          _updateData(widget.data
                              .copyWith(salaryPaymentFrequency: value));
                        });
                      },
                    ),
                    _buildRadioOption(
                      value: 'Never',
                      groupValue: widget.data.salaryPaymentFrequency,
                      label: 'Never',
                      onChanged: (value) {
                        setState(() {
                          _updateData(widget.data
                              .copyWith(salaryPaymentFrequency: value));
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Show agreement section if applicable
          if (widget.data.hasRecruitedWorker == '1' ||
              (widget.data.hasRecruitedWorker == '0' &&
                  widget.data.everRecruitedWorker == 'Yes')) ...[
            // Note for the respondent
            Padding(
              padding: const EdgeInsets.only(bottom: _Spacing.lg),
              child: Text(
                'For the following section, please read the statements to the respondent, and ask him/her if he/she agrees or disagrees.',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: isDark ? Colors.grey[400] : Colors.grey[700],
                  fontSize: 14,
                ),
              ),
            ),

            // Agreement Statements Section - Salary and Debt
            _buildAgreementSection(
              statements: [
                'It is acceptable to withhold a worker\'s salary without their consent.',
                'It is acceptable for a person who cannot pay their debts to work for the creditor to reimburse the debt.',
              ],
              ids: ['salary_workers', 'recruit_1'],
            ),

            // Agreement Statements Section - Recruitment
            _buildAgreementSection(
              statements: [
                'It is acceptable for an employer not to reveal the true nature of the work during the recruitment.',
                'A worker is obliged to work whenever he is called upon by his employer.',
              ],
              ids: ['recruit_2', 'recruit_3'],
            ),

            // Agreement Statements Section - Working Conditions
            _buildAgreementSection(
              statements: [
                'A worker is not entitled to move freely.',
                'A worker must be free to communicate with his or her family and friends.',
                'A worker is obliged to adapt to any living conditions imposed by the employer.',
                'It is acceptable for an employer and their family to interfere in a worker\'s private life.',
                'A worker should not have the freedom to leave work whenever they wish.',
              ],
              ids: [
                'conditions_1',
                'conditions_2',
                'conditions_3',
                'conditions_4',
                'conditions_5',
              ],
            ),

            // Agreement Statements Section - Leaving Employment
            _buildAgreementSection(
              statements: [
                'A worker should be required to stay longer than expected while waiting for unpaid salary.',
                'A worker should not be able to leave their employer when they owe money to their employer.',
              ],
              ids: ['leaving_1', 'leaving_2'],
            ),
          ],

          const SizedBox(height: _Spacing.xxl),
        ],
      ),
    );
  }
}

// ===========================================================================
// PAGE 4: ADULTS INFORMATION CONTENT (COMPLETE)
// ===========================================================================

class _AdultsInformationPage extends StatefulWidget {
  final AdultsInformationData data;
  final ValueChanged<AdultsInformationData> onDataChanged;

  const _AdultsInformationPage({
    required this.data,
    required this.onDataChanged,
  });

  @override
  State<_AdultsInformationPage> createState() => __AdultsInformationPageState();
}

class __AdultsInformationPageState extends State<_AdultsInformationPage> {
  late TextEditingController _adultsCountController;
  late List<TextEditingController> _nameControllers;
  late List<bool> _showProducerDetailsList;
  late List<ProducerDetailsModel> _producerDetailsList;

  @override
  void initState() {
    super.initState();
    _adultsCountController = TextEditingController(
      text: widget.data.numberOfAdults?.toString() ?? '',
    );
    _initializeFromExistingData();
  }

  void _initializeFromExistingData() {
    _nameControllers = [];
    _showProducerDetailsList = [];
    _producerDetailsList = [];

    if (widget.data.members.isNotEmpty) {
      for (final member in widget.data.members) {
        _nameControllers.add(TextEditingController(text: member.name));
        _showProducerDetailsList.add(false);
        _producerDetailsList.add(member.producerDetails);
      }
    } else if (widget.data.numberOfAdults != null) {
      for (int i = 0; i < widget.data.numberOfAdults!; i++) {
        _nameControllers.add(TextEditingController());
        _showProducerDetailsList.add(false);
        _producerDetailsList.add(ProducerDetailsModel());
      }
    }
  }

  void _updateParentData() {
    final members = List.generate(_nameControllers.length, (index) {
      return HouseholdMember(
        name: _nameControllers[index].text,
        producerDetails: _producerDetailsList[index],
      );
    });

    widget.onDataChanged(
      AdultsInformationData(
        numberOfAdults:
            _nameControllers.isEmpty ? null : _nameControllers.length,
        members: members,
      ),
    );
  }

  void _onCountChanged(String value) {
    final count = int.tryParse(value);

    if (count == null || count < 0) {
      setState(() {
        _nameControllers.clear();
        _showProducerDetailsList.clear();
        _producerDetailsList.clear();
      });
      _updateParentData();
      return;
    }

    // Dispose old controllers
    for (var controller in _nameControllers) {
      controller.dispose();
    }

    // Initialize new lists
    final newNameControllers = <TextEditingController>[];
    final newShowDetailsList = <bool>[];
    final newProducerDetails = <ProducerDetailsModel>[];

    for (int i = 0; i < count; i++) {
      if (i < _nameControllers.length) {
        // Keep existing data
        newNameControllers.add(_nameControllers[i]);
        newShowDetailsList.add(_showProducerDetailsList[i]);
        newProducerDetails.add(_producerDetailsList[i]);
      } else {
        // Add new entries
        newNameControllers.add(TextEditingController());
        newShowDetailsList.add(false);
        newProducerDetails.add(ProducerDetailsModel());
      }
    }

    setState(() {
      _nameControllers = newNameControllers;
      _showProducerDetailsList = newShowDetailsList;
      _producerDetailsList = newProducerDetails;
    });

    _updateParentData();
  }

  void _toggleProducerDetails(int index) {
    if (index < _nameControllers.length &&
        index < _showProducerDetailsList.length &&
        _isNameValid(_nameControllers[index].text)) {
      setState(() {
        _showProducerDetailsList[index] = !_showProducerDetailsList[index];
      });
    }
  }

  void _updateProducerDetails(int index, ProducerDetailsModel details) {
    if (index < _producerDetailsList.length) {
      setState(() {
        _producerDetailsList[index] = details;
      });
      _updateParentData();
    }
  }

  bool _isNameValid(String name) {
    return name.trim().isNotEmpty && name.trim().split(' ').length >= 2;
  }

  Widget _buildQuestionCard({required Widget child}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: _Spacing.lg),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(
          color: isDark ? AppTheme.darkCard : Colors.grey.shade200,
          width: 1,
        ),
      ),
      color: isDark ? AppTheme.darkCard : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(_Spacing.lg),
        child: child,
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String hintText = '',
    TextInputType keyboardType = TextInputType.text,
    ValueChanged<String>? onChanged,
    bool? isValid,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(
            color: isDark ? AppTheme.darkTextSecondary : AppTheme.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: _Spacing.md),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color:
                  isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: isDark ? AppTheme.darkCard : Colors.grey.shade300,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: (isValid == true)
                    ? Colors.green.shade400
                    : (isDark ? AppTheme.darkCard : Colors.grey.shade300),
                width: (isValid == true) ? 2.0 : 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: (isValid == true)
                    ? Colors.green.shade600
                    : AppTheme.primaryColor,
                width: 2.0,
              ),
            ),
            filled: true,
            fillColor: isDark ? AppTheme.darkCard : Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: _Spacing.lg,
              vertical: _Spacing.md,
            ),
            suffixIcon: (isValid == true)
                ? Icon(Icons.check_circle, color: Colors.green.shade600)
                : null,
          ),
          style: theme.textTheme.bodyLarge?.copyWith(
            color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _adultsCountController.dispose();
    for (var controller in _nameControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(_Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Number of adults input
          _buildQuestionCard(
            child: _buildTextField(
              label: 'Total number of adults in the household '
                  '(Producer/manager/owner not included). '
                  'Include the manager\'s family only if they live in the producer\'s household. *',
              controller: _adultsCountController,
              hintText: 'Enter number of adults',
              keyboardType: TextInputType.number,
              onChanged: _onCountChanged,
            ),
          ),

          // Household members section
          if (_nameControllers.isNotEmpty) ...[
            _buildQuestionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Full name of household members',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: isDark
                          ? AppTheme.darkTextSecondary
                          : AppTheme.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: _Spacing.sm),
                  Text(
                    'List all members of the producer\'s household. Do not include the manager/farmer. '
                    'Include the manager\'s family only if they live in the producer\'s household. '
                    'Write the first and last names of household members.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark
                          ? AppTheme.darkTextSecondary
                          : AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Individual household member cards
            ...List.generate(_nameControllers.length, (index) {
              final nameController = _nameControllers[index];
              final isNameValid = _isNameValid(nameController.text);
              final producerDetails = _producerDetailsList[index];
              final isDetailsComplete = producerDetails.isComplete;

              return Column(
                children: [
                  _buildQuestionCard(
                    child: _buildTextField(
                      label: 'Full Name of Household Member ${index + 1}',
                      controller: nameController,
                      hintText: 'Enter first and last name',
                      isValid: isNameValid,
                      onChanged: (value) {
                        setState(() {});
                        _updateParentData();
                      },
                    ),
                  ),

                  // Producer details section
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    child: Card(
                      margin: const EdgeInsets.only(bottom: _Spacing.lg),
                      color: isNameValid
                          ? (isDark
                              ? Colors.green.shade900.withOpacity(0.3)
                              : Colors.green.shade50)
                          : (isDark
                              ? Colors.grey.shade800
                              : Colors.grey.shade200),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        side: BorderSide(
                          color: isNameValid
                              ? Colors.green.shade300
                              : Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'PRODUCER DETAILS - ${nameController.text.isNotEmpty ? nameController.text.toUpperCase() : 'ENTER FULL NAME'}',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: isNameValid
                                          ? Colors.green.shade800
                                          : Colors.grey.shade600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                                if (isNameValid)
                                  Icon(
                                    isDetailsComplete
                                        ? Icons.check_circle
                                        : Icons.error,
                                    color: isDetailsComplete
                                        ? Colors.green
                                        : Colors.orange,
                                    size: 16,
                                  ),
                              ],
                            ),
                            trailing: Icon(
                              _showProducerDetailsList[index]
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                              color: isNameValid
                                  ? Colors.green.shade800
                                  : Colors.grey.shade600,
                            ),
                            onTap: () => _toggleProducerDetails(index),
                          ),

                          // Producer details form
                          if (_showProducerDetailsList[index] && isNameValid)
                            Padding(
                              padding: const EdgeInsets.all(_Spacing.lg),
                              child: _ProducerDetailsForm(
                                personName: nameController.text,
                                details: producerDetails,
                                onDetailsUpdated: (details) =>
                                    _updateProducerDetails(index, details),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

// Producer Details Form for Adults Information Page
class _ProducerDetailsForm extends StatefulWidget {
  final String personName;
  final ProducerDetailsModel details;
  final ValueChanged<ProducerDetailsModel> onDetailsUpdated;

  const _ProducerDetailsForm({
    required this.personName,
    required this.details,
    required this.onDetailsUpdated,
  });

  @override
  State<_ProducerDetailsForm> createState() => __ProducerDetailsFormState();
}

class __ProducerDetailsFormState extends State<_ProducerDetailsForm> {
  late TextEditingController _yearOfBirthController;
  late TextEditingController _ghanaCardIdController;
  late TextEditingController _otherIdNumberController;
  late TextEditingController _noConsentReasonController;
  late TextEditingController _otherRelationshipController;
  late TextEditingController _otherOccupationController;
  late TextEditingController _otherCountryController;

  File? _idPhoto;

  @override
  void initState() {
    super.initState();
    _yearOfBirthController = TextEditingController(
        text: widget.details.yearOfBirth?.toString() ?? '');
    _ghanaCardIdController =
        TextEditingController(text: widget.details.ghanaCardId ?? '');
    _otherIdNumberController =
        TextEditingController(text: widget.details.otherIdNumber ?? '');
    _noConsentReasonController =
        TextEditingController(text: widget.details.noConsentReason ?? '');
    _otherRelationshipController =
        TextEditingController(text: widget.details.otherRelationship ?? '');
    _otherOccupationController =
        TextEditingController(text: widget.details.otherOccupation ?? '');
    _otherCountryController =
        TextEditingController(text: widget.details.selectedCountry ?? '');
  }

  void _updateParentDetails() {
    final newDetails = widget.details.copyWith(
      yearOfBirth: int.tryParse(_yearOfBirthController.text),
      ghanaCardId: _ghanaCardIdController.text.isEmpty
          ? null
          : _ghanaCardIdController.text,
      otherIdNumber: _otherIdNumberController.text.isEmpty
          ? null
          : _otherIdNumberController.text,
      noConsentReason: _noConsentReasonController.text.isEmpty
          ? null
          : _noConsentReasonController.text,
      otherRelationship: _otherRelationshipController.text.isEmpty
          ? null
          : _otherRelationshipController.text,
      otherOccupation: _otherOccupationController.text.isEmpty
          ? null
          : _otherOccupationController.text,
      selectedCountry: _otherCountryController.text.isEmpty
          ? null
          : _otherCountryController.text,
      idPhotoPath: _idPhoto?.path,
    );

    widget.onDetailsUpdated(newDetails);
  }

  Future<void> _takePhoto() async {
    try {
      final picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 800,
      );

      if (photo != null) {
        setState(() {
          _idPhoto = File(photo.path);
          _updateParentDetails();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to capture image'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _buildQuestionCard({required Widget child}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: _Spacing.md),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
          width: 1,
        ),
      ),
      color: isDark ? AppTheme.darkCard : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(_Spacing.md),
        child: child,
      ),
    );
  }

  Widget _buildRadioOption({
    required String value,
    required String? groupValue,
    required String label,
    required ValueChanged<String?> onChanged,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return RadioListTile<String>(
      title: Text(
        label,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: isDark ? AppTheme.darkTextSecondary : AppTheme.textPrimary,
        ),
      ),
      value: value,
      groupValue: groupValue,
      onChanged: (value) {
        onChanged(value);
        _updateParentDetails();
      },
      activeColor: AppTheme.primaryColor,
      contentPadding: EdgeInsets.zero,
      dense: true,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String hintText = '',
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDark ? AppTheme.darkTextSecondary : AppTheme.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: _Spacing.sm),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          onChanged: (_) => _updateParentDetails(),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color:
                  isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: isDark ? AppTheme.darkCard : Colors.grey.shade300,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: isDark ? AppTheme.darkCard : Colors.grey.shade300,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: theme.primaryColor,
                width: 1.5,
              ),
            ),
            filled: true,
            fillColor: isDark ? AppTheme.darkCard : Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: _Spacing.md,
              vertical: _Spacing.sm,
            ),
          ),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<Map<String, String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDark ? AppTheme.darkTextSecondary : AppTheme.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: _Spacing.sm),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
              color: isDark ? AppTheme.darkCard : Colors.grey.shade300,
            ),
            color: isDark ? AppTheme.darkCard : Colors.white,
          ),
          padding: const EdgeInsets.symmetric(horizontal: _Spacing.md),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down, color: theme.primaryColor),
              iconSize: 20,
              elevation: 16,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
              ),
              onChanged: (value) {
                onChanged(value);
                _updateParentDetails();
              },
              dropdownColor: isDark ? AppTheme.darkCard : Colors.white,
              items: items
                  .map<DropdownMenuItem<String>>((Map<String, String> item) {
                return DropdownMenuItem<String>(
                  value: item['value'],
                  child: Text(
                    item['display'] ?? item['label'] ?? '',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark
                          ? AppTheme.darkTextPrimary
                          : AppTheme.textPrimary,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Gender
        _buildQuestionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gender',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: _Spacing.sm),
              Wrap(
                spacing: 20,
                children: [
                  _buildRadioOption(
                    value: 'male',
                    groupValue: widget.details.gender,
                    label: 'Male',
                    onChanged: (value) {
                      setState(() {
                        widget.onDetailsUpdated(
                            widget.details.copyWith(gender: value));
                      });
                    },
                  ),
                  _buildRadioOption(
                    value: 'female',
                    groupValue: widget.details.gender,
                    label: 'Female',
                    onChanged: (value) {
                      setState(() {
                        widget.onDetailsUpdated(
                            widget.details.copyWith(gender: value));
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),

        // Nationality
        _buildQuestionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nationality',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: _Spacing.sm),
              Wrap(
                spacing: 20,
                children: [
                  _buildRadioOption(
                    value: 'ghanaian',
                    groupValue: widget.details.nationality,
                    label: 'Ghanaian',
                    onChanged: (value) {
                      setState(() {
                        widget.onDetailsUpdated(widget.details.copyWith(
                          nationality: value,
                          selectedCountry: null,
                        ));
                      });
                    },
                  ),
                  _buildRadioOption(
                    value: 'non_ghanaian',
                    groupValue: widget.details.nationality,
                    label: 'Non-Ghanaian',
                    onChanged: (value) {
                      setState(() {
                        widget.onDetailsUpdated(
                            widget.details.copyWith(nationality: value));
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),

        // Country of Origin (for non-Ghanaians)
        if (widget.details.nationality == 'non_ghanaian')
          _buildQuestionCard(
            child: Column(
              children: [
                _buildDropdownField(
                  label: 'If Non Ghanaian, specify country of origin',
                  value: widget.details.selectedCountry,
                  items: CountryLists.countries,
                  onChanged: (value) {
                    setState(() {
                      widget.onDetailsUpdated(
                          widget.details.copyWith(selectedCountry: value));
                    });
                  },
                ),
                if (widget.details.selectedCountry == 'Other') ...[
                  const SizedBox(height: _Spacing.md),
                  _buildTextField(
                    label: 'If Other, please specify',
                    controller: _otherCountryController,
                    hintText: 'Enter country name',
                  ),
                ],
              ],
            ),
          ),

        // Year of Birth
        _buildQuestionCard(
          child: _buildTextField(
            label: 'Year of Birth',
            controller: _yearOfBirthController,
            hintText: 'Enter year of birth',
            keyboardType: TextInputType.number,
          ),
        ),

        // Ghana Card Question
        _buildQuestionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Does ${widget.personName} have a Ghana card?',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: _Spacing.sm),
              Wrap(
                spacing: 20,
                children: [
                  _buildRadioOption(
                    value: 'Yes',
                    groupValue:
                        widget.details.ghanaCardId != null ? 'Yes' : 'No',
                    label: 'Yes',
                    onChanged: (value) {
                      setState(() {
                        if (value == 'Yes') {
                          widget.onDetailsUpdated(widget.details.copyWith(
                            ghanaCardId: '',
                            otherIdType: null,
                            otherIdNumber: null,
                          ));
                        } else {
                          widget.onDetailsUpdated(widget.details.copyWith(
                            ghanaCardId: null,
                          ));
                        }
                      });
                    },
                  ),
                  _buildRadioOption(
                    value: 'No',
                    groupValue:
                        widget.details.ghanaCardId != null ? 'Yes' : 'No',
                    label: 'No',
                    onChanged: (value) {
                      setState(() {
                        widget.onDetailsUpdated(widget.details.copyWith(
                          ghanaCardId: null,
                        ));
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),

        // Ghana Card ID (if Yes)
        if (widget.details.ghanaCardId != null)
          _buildQuestionCard(
            child: _buildTextField(
              label: 'Ghana Card ID',
              controller: _ghanaCardIdController,
              hintText: 'Enter Ghana Card ID',
            ),
          ),

        // Other ID Type (if No Ghana Card)
        if (widget.details.ghanaCardId == null)
          _buildQuestionCard(
            child: Column(
              children: [
                _buildDropdownField(
                  label: 'Which other national id card is available',
                  value: widget.details.otherIdType,
                  items: [
                    {'value': 'voter_id', 'label': 'Voter ID'},
                    {'value': 'nhis', 'label': 'NHIS Card'},
                    {'value': 'birth_cert', 'label': 'Birth Certificate'},
                    {'value': 'passport', 'label': 'Passport'},
                    {'value': 'drivers_license', 'label': 'Driver\'s License'},
                    {'value': 'none', 'label': 'None'},
                  ],
                  onChanged: (value) {
                    setState(() {
                      widget.onDetailsUpdated(widget.details.copyWith(
                        otherIdType: value,
                        otherIdNumber: value != 'none' ? '' : null,
                      ));
                    });
                  },
                ),
                if (widget.details.otherIdType != null &&
                    widget.details.otherIdType != 'none') ...[
                  const SizedBox(height: _Spacing.md),
                  _buildTextField(
                    label: 'ID Number',
                    controller: _otherIdNumberController,
                    hintText: 'Enter ID number',
                  ),
                ],
              ],
            ),
          ),

        // Consent to Take Photo
        if ((widget.details.ghanaCardId != null &&
                widget.details.ghanaCardId!.isNotEmpty) ||
            (widget.details.otherIdType != null &&
                widget.details.otherIdType != 'none'))
          _buildQuestionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Do you consent to us taking a picture of your identification document?',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: _Spacing.sm),
                Wrap(
                  spacing: 20,
                  children: [
                    _buildRadioOption(
                      value: 'Yes',
                      groupValue: widget.details.consentToTakePhoto == true
                          ? 'Yes'
                          : widget.details.consentToTakePhoto == false
                              ? 'No'
                              : null,
                      label: 'Yes',
                      onChanged: (value) {
                        setState(() {
                          widget.onDetailsUpdated(widget.details.copyWith(
                            consentToTakePhoto: value == 'Yes',
                            noConsentReason: null,
                          ));
                        });
                      },
                    ),
                    _buildRadioOption(
                      value: 'No',
                      groupValue: widget.details.consentToTakePhoto == true
                          ? 'Yes'
                          : widget.details.consentToTakePhoto == false
                              ? 'No'
                              : null,
                      label: 'No',
                      onChanged: (value) {
                        setState(() {
                          widget.onDetailsUpdated(widget.details.copyWith(
                            consentToTakePhoto: value == 'Yes',
                          ));
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

        // ID Photo Section (if consent is given)
        if (widget.details.consentToTakePhoto == true &&
            ((widget.details.ghanaCardId != null &&
                    widget.details.ghanaCardId!.isNotEmpty) ||
                (widget.details.otherIdType != null &&
                    widget.details.otherIdType != 'none')))
          _buildQuestionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ID Photo',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: _Spacing.sm),
                GestureDetector(
                  onTap: _takePhoto,
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppTheme.darkCard
                            : Colors.grey.shade300,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppTheme.darkCard
                          : Colors.grey[100],
                    ),
                    child: _idPhoto == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt,
                                  size: 30,
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white70
                                      : Colors.grey[500]),
                              const SizedBox(height: 8),
                              Text(
                                'Tap to take photo of ID',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white70
                                          : Colors.grey[600],
                                    ),
                              ),
                            ],
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              _idPhoto!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),

        // No Consent Reason (if consent is false)
        if (widget.details.consentToTakePhoto == false)
          _buildQuestionCard(
            child: _buildTextField(
              label: 'Reason for not providing photo',
              controller: _noConsentReasonController,
              hintText: 'Please specify reason',
              maxLines: 2,
            ),
          ),

        // Relationship to Respondent
        _buildQuestionCard(
          child: Column(
            children: [
              _buildDropdownField(
                label: 'Relationship to respondent (Farmer/Manager/Caretaker)',
                value: widget.details.relationshipToRespondent,
                items: [
                  {'value': 'husband_wife', 'label': 'Husband/Wife'},
                  {'value': 'son_daughter', 'label': 'Son/Daughter'},
                  {'value': 'brother_sister', 'label': 'Brother/Sister'},
                  {
                    'value': 'son_in_law_daughter_in_law',
                    'label': 'Son-in-law/Daughter-in-law'
                  },
                  {
                    'value': 'grandson_granddaughter',
                    'label': 'Grandson/Granddaughter'
                  },
                  {'value': 'niece_nephew', 'label': 'Niece/Nephew'},
                  {'value': 'cousin', 'label': 'Cousin'},
                  {
                    'value': 'workers_family_member',
                    'label': "Worker's family member"
                  },
                  {'value': 'worker', 'label': 'Worker'},
                  {'value': 'father_mother', 'label': 'Father/Mother'},
                  {'value': 'other', 'label': 'Other (specify)'},
                ],
                onChanged: (value) {
                  setState(() {
                    widget.onDetailsUpdated(widget.details.copyWith(
                      relationshipToRespondent: value,
                      otherRelationship: value == 'other' ? '' : null,
                    ));
                  });
                },
              ),
              if (widget.details.relationshipToRespondent == 'other') ...[
                const SizedBox(height: _Spacing.md),
                _buildTextField(
                  label: 'If Other, please specify',
                  controller: _otherRelationshipController,
                  hintText: 'Enter relationship',
                ),
              ],
            ],
          ),
        ),

        // Birth Certificate
        _buildQuestionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Does ${widget.personName} have a birth certificate?',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: _Spacing.sm),
              Wrap(
                spacing: 20,
                children: [
                  _buildRadioOption(
                    value: 'yes',
                    groupValue: widget.details.hasBirthCertificate,
                    label: 'Yes',
                    onChanged: (value) {
                      setState(() {
                        widget.onDetailsUpdated(widget.details
                            .copyWith(hasBirthCertificate: value));
                      });
                    },
                  ),
                  _buildRadioOption(
                    value: 'no',
                    groupValue: widget.details.hasBirthCertificate,
                    label: 'No',
                    onChanged: (value) {
                      setState(() {
                        widget.onDetailsUpdated(widget.details
                            .copyWith(hasBirthCertificate: value));
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),

        // Occupation
        _buildQuestionCard(
          child: Column(
            children: [
              _buildDropdownField(
                label: 'Work/main occupation',
                value: widget.details.occupation,
                items: [
                  {'value': 'Farmer (cocoa)', 'label': 'Farmer (cocoa)'},
                  {'value': 'Farmer (coffee)', 'label': 'Farmer (coffee)'},
                  {'value': 'Farmer (other)', 'label': 'Farmer (other)'},
                  {'value': 'Merchant', 'label': 'Merchant'},
                  {'value': 'Student', 'label': 'Student'},
                  {
                    'value': 'Other (to specify)',
                    'label': 'Other (to specify)'
                  },
                  {'value': 'No activity', 'label': 'No activity'},
                ],
                onChanged: (value) {
                  setState(() {
                    widget.onDetailsUpdated(widget.details.copyWith(
                      occupation: value,
                      otherOccupation:
                          value == 'Other (to specify)' ? '' : null,
                    ));
                  });
                },
              ),
              if (widget.details.occupation == 'Other (to specify)') ...[
                const SizedBox(height: _Spacing.md),
                _buildTextField(
                  label: 'If other, please specify',
                  controller: _otherOccupationController,
                  hintText: 'Enter occupation',
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: _Spacing.md),
      ],
    );
  }
}
