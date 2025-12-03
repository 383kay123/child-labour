class UserModel {
  final int id;
  final String firstName;
  final String lastName;
  final String gender;
  final String contact;
  final int designation;
  final String emailAddress;
  final String staffid;
  final String? district;
  final List<AssignedDistrict> assignedDistricts;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.contact,
    required this.designation,
    required this.emailAddress,
    required this.staffid,
    this.district,
    required this.assignedDistricts,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      gender: json['gender'] as String,
      contact: json['contact'] as String,
      designation: json['designation'] as int,
      emailAddress: json['email_address'] as String,
      staffid: json['staffid'] as String,
      district: json['district'] as String?,
      assignedDistricts: (json['assigned_districts'] as List)
          .map((district) => AssignedDistrict.fromJson(district))
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
      'staffid': staffid,
      'district': district,
      'assigned_districts': assignedDistricts.map((d) => d.toJson()).toList(),
    };
  }
}

class AssignedDistrict {
  final int id;
  final String name;

  AssignedDistrict({
    required this.id,
    required this.name,
  });

  factory AssignedDistrict.fromJson(Map<String, dynamic> json) {
    return AssignedDistrict(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}