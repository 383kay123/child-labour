import 'package:uuid/uuid.dart';

class FarmerIdentificationData {
  final String? id;
  final String? householdId;
  final String? hasGhanaCard;
  final String? ghanaCardNumber;
  final String? idType;
  final String? idNumber;
  final String? idImagePath;
  final String? idPictureConsent;
  final String? noConsentReason;
  final String? phoneNumber;
  final List<Child>? children;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  FarmerIdentificationData({
    this.id,
    this.householdId,
    this.hasGhanaCard,
    this.ghanaCardNumber,
    this.idType,
    this.idNumber,
    this.idImagePath,
    this.idPictureConsent,
    this.noConsentReason,
    this.phoneNumber,
    this.children,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id ?? const Uuid().v4(),
      'householdId': householdId,
      'hasGhanaCard': hasGhanaCard,
      'ghanaCardNumber': ghanaCardNumber,
      'idType': idType,
      'idNumber': idNumber,
      'idImagePath': idImagePath,
      'idPictureConsent': idPictureConsent,
      'noConsentReason': noConsentReason,
      'phoneNumber': phoneNumber,
      'children': children?.map((child) => child.toJson()).toList(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory FarmerIdentificationData.fromJson(Map<String, dynamic> json) {
    return FarmerIdentificationData(
      id: json['id'],
      householdId: json['householdId'],
      hasGhanaCard: json['hasGhanaCard'],
      ghanaCardNumber: json['ghanaCardNumber'],
      idType: json['idType'],
      idNumber: json['idNumber'],
      idImagePath: json['idImagePath'],
      idPictureConsent: json['idPictureConsent'],
      noConsentReason: json['noConsentReason'],
      phoneNumber: json['phoneNumber'],
      children: json['children'] != null
          ? (json['children'] as List)
              .map((child) => Child.fromJson(child))
              .toList()
          : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  FarmerIdentificationData copyWith({
    String? id,
    String? householdId,
    String? hasGhanaCard,
    String? ghanaCardNumber,
    String? idType,
    String? idNumber,
    String? idImagePath,
    String? idPictureConsent,
    String? noConsentReason,
    String? phoneNumber,
    List<Child>? children,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FarmerIdentificationData(
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      hasGhanaCard: hasGhanaCard ?? this.hasGhanaCard,
      ghanaCardNumber: ghanaCardNumber ?? this.ghanaCardNumber,
      idType: idType ?? this.idType,
      idNumber: idNumber ?? this.idNumber,
      idImagePath: idImagePath ?? this.idImagePath,
      idPictureConsent: idPictureConsent ?? this.idPictureConsent,
      noConsentReason: noConsentReason ?? this.noConsentReason,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      children: children ?? this.children,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class Child {
  final String id;
  final String firstName;
  final String surname;
  final String dateOfBirth;
  final String gender;
  final String relationshipToFarmer;
  final bool isInSchool;

  Child({
    String? id,
    required this.firstName,
    required this.surname,
    required this.dateOfBirth,
    required this.gender,
    required this.relationshipToFarmer,
    required this.isInSchool,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'surname': surname,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'relationshipToFarmer': relationshipToFarmer,
      'isInSchool': isInSchool,
    };
  }

  factory Child.fromJson(Map<String, dynamic> json) {
    return Child(
      id: json['id'],
      firstName: json['firstName'] ?? '',
      surname: json['surname'] ?? '',
      dateOfBirth: json['dateOfBirth'] ?? '',
      gender: json['gender'] ?? '',
      relationshipToFarmer: json['relationshipToFarmer'] ?? 'Child',
      isInSchool: json['isInSchool'] ?? false,
    );
  }

  Child copyWith({
    String? id,
    String? firstName,
    String? surname,
    String? dateOfBirth,
    String? gender,
    String? relationshipToFarmer,
    bool? isInSchool,
  }) {
    return Child(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      surname: surname ?? this.surname,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      relationshipToFarmer: relationshipToFarmer ?? this.relationshipToFarmer,
      isInSchool: isInSchool ?? this.isInSchool,
    );
  }
}
