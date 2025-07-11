class User {
  final int? id;
  final String phone;
  final String password;
  final String? username;
  final String? avatar;
  final String? email;
  final String? address;
  final String? createdAt;

  User({
    this.id,
    required this.phone,
    required this.password,
    this.username,
    this.avatar,
    this.email,
    this.address,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    phone: json['phone'] ?? '',
    password: json['password'] ?? '',
    username: json['username'],
    avatar: json['avatar'],
    email: json['email'],
    address: json['address'],
    createdAt: json['createdAt'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'phone': phone,
    'password': password,
    'username': username,
    'avatar': avatar,
    'email': email,
    'address': address,
    'createdAt': createdAt,
  };

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      phone: map['phone'],
      password: map['password'],
      username: map['username'],
      avatar: map['avatar'],
      email: map['email'],
      address: map['address'],
      createdAt: map['created_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'phone': phone,
      'password': password,
      'username': username,
      'avatar': avatar,
      'email': email,
      'address': address,
      'created_at': createdAt,
    };
  }

  User copyWith({
    int? id,
    String? phone,
    String? password,
    String? username,
    String? avatar,
    String? email,
    String? address,
    String? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      username: username ?? this.username,
      avatar: avatar ?? this.avatar,
      email: email ?? this.email,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
    );
  }
} 