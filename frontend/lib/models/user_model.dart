class UserModel {
  final int id;
  final String email;
  final String? fullName;
  final String? accountType;
  final int? universityId;
  final String? countryCode;
  final String? city;
  final String? profilePictureUrl;

  UserModel({
    required this.id,
    required this.email,
    this.fullName,
    this.accountType,
    this.universityId,
    this.countryCode,
    this.city,
    this.profilePictureUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: int.parse(json['id'].toString()),
      email: json['email'].toString(),
      fullName: json['full_name']?.toString(),
      accountType: json['account_type']?.toString(),
      universityId: json['university_id'] == null
          ? null
          : int.tryParse(json['university_id'].toString()),
      countryCode: json['country_code']?.toString(),
      city: json['city']?.toString(),
      profilePictureUrl: json['profile_picture_url']?.toString(),
    );
  }
}