class Address {
  final int? id;
  final int? userId;
  final String name;
  final String phone;
  final String province;
  final String city;
  final String district;
  final String detailAddress;
  final bool isDefault;

  Address({
    this.id,
    this.userId,
    required this.name,
    required this.phone,
    required this.province,
    required this.city,
    required this.district,
    required this.detailAddress,
    this.isDefault = false,
  });

  // 获取完整地址字符串
  String get fullAddress => '$province $city $district $detailAddress';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'phone': phone,
      'province': province,
      'city': city,
      'district': district,
      'detail_address': detailAddress,
      'is_default': isDefault ? 1 : 0,
    };
  }

  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      id: map['id'] as int?,
      userId: map['user_id'] as int?,
      name: (map['name'] as String?) ?? '',
      phone: (map['phone'] as String?) ?? '',
      province: (map['province'] as String?) ?? '',
      city: (map['city'] as String?) ?? '',
      district: (map['district'] as String?) ?? '',
      detailAddress: (map['detail_address'] as String?) ?? '',
      isDefault: ((map['is_default'] as int?) ?? 0) == 1,
    );
  }
} 