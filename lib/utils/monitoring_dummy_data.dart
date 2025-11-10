import 'package:intl/intl.dart';
import '../view/models/monitoring_model.dart';

class MonitoringDummyData {
  // Generate a list of dummy monitoring records
  static List<MonitoringModel> generateDummyMonitoringData({int count = 5}) {
    final List<MonitoringModel> dummyData = [];
    final now = DateTime.now();
    
    for (int i = 0; i < count; i++) {
      final isEven = i % 2 == 0;
      final isSubmitted = i % 3 != 0; // Every 3rd record is a draft
      
      dummyData.add(MonitoringModel(
        id: i + 1,
        childName: _childNames[i % _childNames.length],
        childId: getChildCode(_childNames[i % _childNames.length]),
        age: (10 + i).toString(),
        sex: isEven ? 'Male' : 'Female',
        community: _communities[i % _communities.length],
        farmerId: 'FARM-${2000 + i}',
        firstRemediationDate: DateFormat('yyyy-MM-dd').format(
          now.subtract(Duration(days: 30 + (i * 10))),
        ),
        remediationFormProvided: isEven ? 'Yes' : 'No',
        followUpVisitsCount: (i + 1).toString(),
        classAtRemediation: 'P${3 + (i % 4)}',
        promotedGrade: isEven ? 'P${4 + (i % 4)}' : null,
        recommendations: isEven ? 'Continue monitoring progress' : 'Additional support needed',
        noBirthCertificateReason: isEven ? 'Application in progress' : 'Parents not available',
        additionalComments: 'Child showing ${isEven ? 'good' : 'slow'} progress',
        followUpVisitsCountSinceIdentification: (i + 2).toString(),
        isEnrolledInSchool: isEven,
        attendanceImproved: isEven,
        receivedSchoolMaterials: isEven,
        canReadBasicText: isEven,
        canWriteBasicText: isEven,
        advancedToNextGrade: isEven,
        academicYearEnded: isEven,
        promoted: isEven,
        improvementInSkills: isEven,
        engagedInHazardousWork: !isEven,
        reducedWorkHours: isEven,
        involvedInLightWork: isEven,
        outOfHazardousWork: isEven,
        hasBirthCertificate: isEven,
        birthCertificateProcess: isEven,
        status: isSubmitted ? 1 : 0, // 1 = Submitted, 0 = Draft
      ));
    }
    
    return dummyData;
  }

  // Sample data
  static const List<String> _childNames = [
    'John Doe',
    'Mary Johnson',
    'David Smith',
    'Sarah Williams',
    'Michael Brown',
  ];

  static const List<String> _childCodes = [
    'CHILD-1001',
    'CHILD-1002',
    'CHILD-1003',
    'CHILD-1004',
    'CHILD-1005',
  ];
  
  static String getChildCode(String name) {
    final index = _childNames.indexOf(name);
    return index >= 0 ? _childCodes[index] : 'CHILD-${DateTime.now().millisecondsSinceEpoch}';
  }

  static const List<String> _communities = [
    'Kawempe Division',
    'Makindye Division',
    'Nakawa Division',
    'Rubaga Division',
    'Central Division',
  ];
  
  // Sample farmer IDs
  static const List<String> _farmerIds = [
    'FARM-1001',
    'FARM-1002',
    'FARM-1003',
    'FARM-1004',
    'FARM-1005',
  ];
  
  // Public getter for communities
  static List<String> get communities => List.from(_communities);
  
  // Public getter for farmer IDs
  static List<String> get farmerIds => List.from(_farmerIds);

  // Get a single dummy record with all fields filled
  static MonitoringModel getCompleteDummyRecord() {
    return MonitoringModel(
      id: 999,
      childName: 'Test Child',
      childId: 'CHILD-9999',
      age: '12',
      sex: 'Male',
      community: 'Test Community',
      farmerId: _farmerIds.first,
      firstRemediationDate: DateFormat('yyyy-MM-dd').format(DateTime.now().subtract(const Duration(days: 30))),
      remediationFormProvided: 'Yes',
      followUpVisitsCount: '3',
      classAtRemediation: 'P5',
      promotedGrade: 'P6',
      recommendations: 'Continue current support',
      noBirthCertificateReason: 'Application submitted',
      additionalComments: 'Child is making good progress in all areas',
      followUpVisitsCountSinceIdentification: '4',
      isEnrolledInSchool: true,
      attendanceImproved: true,
      receivedSchoolMaterials: true,
      canReadBasicText: true,
      canWriteBasicText: true,
      advancedToNextGrade: true,
      academicYearEnded: true,
      promoted: true,
      improvementInSkills: true,
      engagedInHazardousWork: false,
      reducedWorkHours: true,
      involvedInLightWork: true,
      outOfHazardousWork: true,
      hasBirthCertificate: true,
      birthCertificateProcess: true,
      status: 1, // Submitted
    );
  }
}
