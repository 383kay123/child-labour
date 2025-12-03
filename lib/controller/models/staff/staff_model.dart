import 'package:human_rights_monitor/controller/models/auth/user_model.dart';

class StaffModel {
  final int id;
  final String firstName;
  final String lastName;
  final String gender;
  final String contact;
  final int designation;
  final String emailAddress;
  final String staffId;
  final String? district;
  final List<AssignedDistrict> assignedDistricts;

  StaffModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.contact,
    required this.designation,
    required this.emailAddress,
    required this.staffId,
    this.district,
    required this.assignedDistricts,
  });

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    return StaffModel(
      id: json['id'] as int,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      gender: json['gender'] as String,
      contact: json['contact'] as String,
      designation: json['designation'] as int,
      emailAddress: json['email_address'] as String,
      staffId: json['staffid'] as String,
      district: json['district'],
      assignedDistricts: (json['assigned_districts'] as List)
          .map((districtJson) => AssignedDistrict.fromJson(districtJson))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'gender': gender,
      'contact': contact,
      'designation': designation,
      'email_address': emailAddress,
      'staffid': staffId,
      'district': district,
      'assigned_districts': assignedDistricts.map((district) => district.toJson()).toList(),
    };
  }

  // For easier debugging
  @override
  String toString() {
    return 'StaffModel(id: $id, firstName: $firstName, lastName: $lastName, staffId: $staffId)';
  }

    StaffModel copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? gender,
    String? contact,
    int? designation,
    String? emailAddress,
    String? staffId,
    String? district,
    List<AssignedDistrict>? assignedDistricts,
  }) {
    return StaffModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      gender: gender ?? this.gender,
      contact: contact ?? this.contact,
      designation: designation ?? this.designation,
      emailAddress: emailAddress ?? this.emailAddress,
      staffId: staffId ?? this.staffId,
      district: district ?? this.district,
      assignedDistricts: assignedDistricts ?? this.assignedDistricts,
    );
  }
}