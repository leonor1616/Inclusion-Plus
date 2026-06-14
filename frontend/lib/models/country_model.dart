class CountryModel {
  final String code;
  final String name;
  final String? phoneCode;

  CountryModel({
    required this.code,
    required this.name,
    this.phoneCode,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return CountryModel(
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      phoneCode: json['phone_code']?.toString(),
    );
  }

  String get displayName => name;
}