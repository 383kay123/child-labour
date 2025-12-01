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
      // Salary and Debt Related
      'salary_workers': null,
      'recruit_1': null,
      'recruit_2': null,
      'recruit_3': null,

      // Working Conditions
      'conditions_1': null,
      'conditions_2': null,
      'conditions_3': null,
      'conditions_4': null,
      'conditions_5': null,

      // Leaving Employment
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

  /// Converts the model to a JSON-compatible map
  Map<String, dynamic> toJson() {
    return {
      'hasRecruitedWorker': hasRecruitedWorker,
      'everRecruitedWorker': everRecruitedWorker,
      'permanentLabor': permanentLabor,
      'casualLabor': casualLabor,
      'workerAgreementType': workerAgreementType,
      'otherAgreement': otherAgreement,
      'tasksClarified': tasksClarified,
      'additionalTasks': additionalTasks,
      'refusalAction': refusalAction,
      'salaryPaymentFrequency': salaryPaymentFrequency,
      'agreementResponses': agreementResponses,
    };
  }

  /// For backward compatibility
  factory WorkersInFarmData.fromMap(Map<String, dynamic> map) =>
      WorkersInFarmData.fromJson(map);

  /// For backward compatibility
  Map<String, dynamic> toMap() => toJson();

  /// Creates a WorkersInFarmData from a JSON map
  factory WorkersInFarmData.fromJson(Map<String, dynamic> json) {
    final responses = json['agreementResponses'] != null
        ? Map<String, String?>.from(json['agreementResponses'] as Map)
        : const <String, String?>{};

    // Ensure all response keys exist with null values if not present
    final defaultResponses = <String, String?>{
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
    }..addAll(responses.cast<String, String?>());
    
    return WorkersInFarmData(
      hasRecruitedWorker: json['hasRecruitedWorker'],
      everRecruitedWorker: json['everRecruitedWorker'],
      permanentLabor: json['permanentLabor'] == true || json['permanentLabor'] == 1,
      casualLabor: json['casualLabor'] == true || json['casualLabor'] == 1,
      workerAgreementType: json['workerAgreementType'],
      otherAgreement: json['otherAgreement'] ?? '',
      tasksClarified: json['tasksClarified'],
      additionalTasks: json['additionalTasks'],
      refusalAction: json['refusalAction'],
      salaryPaymentFrequency: json['salaryPaymentFrequency'],
      agreementResponses: defaultResponses,
    );
  }

  /// Creates an empty instance of WorkersInFarmData
  static WorkersInFarmData empty() {
    return const WorkersInFarmData();
  }

  bool get isFormComplete {
    // Check if the main recruitment question is answered
    if (hasRecruitedWorker == null) return false;

    // If recruited workers in past year, check if at least one type is selected
    if (hasRecruitedWorker == '1') {
      if (!permanentLabor && !casualLabor) return false;

      // Check if all agreement responses are filled
      if (agreementResponses.values.any((response) => response == null)) {
        return false;
      }
    }

    // If not recruited in past year, check if ever recruited question is answered
    if (hasRecruitedWorker == '0') {
      if (everRecruitedWorker == null) return false;

      // If they have recruited before, check agreement responses
      if (everRecruitedWorker == 'Yes' &&
          agreementResponses.values.any((response) => response == null)) {
        return false;
      }
    }

    // If 'Other' is selected, check if text is provided
    if (refusalAction == 'Other' && otherAgreement.trim().isEmpty) {
      return false;
    }

    // Check if salary payment frequency is answered
    if (salaryPaymentFrequency == null) return false;

    // Check if all agreement statements are answered when applicable
    if (hasRecruitedWorker == '1' ||
        (hasRecruitedWorker == '0' && everRecruitedWorker == 'Yes')) {
      for (var response in agreementResponses.values) {
        if (response == null) return false;
      }
    }

    return true;
  }

  @override
  String toString() {
    return 'WorkersInFarmData(hasRecruitedWorker: $hasRecruitedWorker, everRecruitedWorker: $everRecruitedWorker, workerAgreementType: $workerAgreementType, tasksClarified: $tasksClarified, additionalTasks: $additionalTasks, refusalAction: $refusalAction, salaryPaymentFrequency: $salaryPaymentFrequency, permanentLabor: $permanentLabor, casualLabor: $casualLabor, otherAgreement: $otherAgreement, agreementResponses: $agreementResponses)';
  }
}
