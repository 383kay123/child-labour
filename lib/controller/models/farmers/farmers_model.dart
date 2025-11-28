class Farmer {
  final String firstName;
  final String lastName;
  final String farmerCode;
  final int? societyName;
  final String? nationalIdNo;
  final String? contact;
  final String? idType;
  final String? idExpiryDate;
  final int? noOfCocoaFarms;
  final int? noOfCertifiedCrop;
  final int? totalCocoaBagsHarvestedPreviousYear;
  final int? totalCocoaBagsSoldGroupPreviousYear;
  final int? currentYearYieldEstimate;
  final int? staffTblForeignkey;
  final String? uuid;
  final String? farmerPhoto;
  final int? calNoMappedFarms;
  final String? mappedStatus;
  final String? newFarmerCode;

  Farmer({
    required this.firstName,
    required this.lastName,
    required this.farmerCode,
    this.societyName,
    this.nationalIdNo,
    this.contact,
    this.idType,
    this.idExpiryDate,
    this.noOfCocoaFarms,
    this.noOfCertifiedCrop,
    this.totalCocoaBagsHarvestedPreviousYear,
    this.totalCocoaBagsSoldGroupPreviousYear,
    this.currentYearYieldEstimate,
    this.staffTblForeignkey,
    this.uuid,
    this.farmerPhoto,
    this.calNoMappedFarms,
    this.mappedStatus,
    this.newFarmerCode,
  });

  factory Farmer.fromJson(Map<String, dynamic> json) {
    return Farmer(
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      farmerCode: json['farmer_code']?.toString() ?? '',
      societyName: int.tryParse(json['society_name']?.toString() ?? '0') ?? 0,
      nationalIdNo: json['national_id_no']?.toString(),
      contact: json['contact']?.toString(),
      idType: json['id_type']?.toString(),
      idExpiryDate: json['id_expiry_date']?.toString(),
      noOfCocoaFarms: int.tryParse(json['no_of_cocoa_farms']?.toString() ?? '0') ?? 0,
      noOfCertifiedCrop: int.tryParse(json['no_of_certified_crop']?.toString() ?? '0') ?? 0,
      totalCocoaBagsHarvestedPreviousYear: int.tryParse(json['total_cocoa_bags_harvested_previous_year']?.toString() ?? '0') ?? 0,
      totalCocoaBagsSoldGroupPreviousYear: int.tryParse(json['total_cocoa_bags_sold_group_previous_year']?.toString() ?? '0') ?? 0,
      currentYearYieldEstimate: int.tryParse(json['current_year_yeild_estimate']?.toString() ?? '0') ?? 0,
      staffTblForeignkey: int.tryParse(json['staffTbl_foreignkey']?.toString() ?? '0'),
      uuid: json['uuid']?.toString(),
      farmerPhoto: json['farmer_photo']?.toString(),
      calNoMappedFarms: int.tryParse(json['cal_no_mapped_farms']?.toString() ?? '0') ?? 0,
      mappedStatus: json['mapped_status']?.toString(),
      newFarmerCode: json['new_farmer_code']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'farmer_code': farmerCode,
      'society_name': societyName,
      'national_id_no': nationalIdNo,
      'contact': contact,
      'id_type': idType,
      'id_expiry_date': idExpiryDate,
      'no_of_cocoa_farms': noOfCocoaFarms,
      'no_of_certified_crop': noOfCertifiedCrop,
      'total_cocoa_bags_harvested_previous_year': totalCocoaBagsHarvestedPreviousYear,
      'total_cocoa_bags_sold_group_previous_year': totalCocoaBagsSoldGroupPreviousYear,
      'current_year_yeild_estimate': currentYearYieldEstimate,
      'staffTbl_foreignkey': staffTblForeignkey,
      'uuid': uuid,
      'farmer_photo': farmerPhoto,
      'cal_no_mapped_farms': calNoMappedFarms,
      'mapped_status': mappedStatus,
      'new_farmer_code': newFarmerCode,
    };
  }

  @override
  String toString() {
    return 'Farmer(firstName: $firstName, lastName: $lastName, farmerCode: $farmerCode, societyName: $societyName, nationalIdNo: $nationalIdNo, contact: $contact, idType: $idType, idExpiryDate: $idExpiryDate, noOfCocoaFarms: $noOfCocoaFarms, noOfCertifiedCrop: $noOfCertifiedCrop, totalCocoaBagsHarvestedPreviousYear: $totalCocoaBagsHarvestedPreviousYear, totalCocoaBagsSoldGroupPreviousYear: $totalCocoaBagsSoldGroupPreviousYear, currentYearYieldEstimate: $currentYearYieldEstimate, staffTblForeignkey: $staffTblForeignkey, uuid: $uuid, farmerPhoto: $farmerPhoto, calNoMappedFarms: $calNoMappedFarms, mappedStatus: $mappedStatus, newFarmerCode: $newFarmerCode)';
  }
}