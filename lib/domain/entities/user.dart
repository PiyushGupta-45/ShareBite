class User {
  const User({
    required this.id,
    required this.email,
    required this.name,
    this.picture,
    this.isEmailVerified = false,
    this.authProvider = 'email',
    this.role = 'user', // 'user', 'admin', 'restaurant', or 'ngo_admin'
  });

  final String id;
  final String email;
  final String name;
  final String? picture;
  final bool isEmailVerified;
  final String authProvider;
  final String role; // 'user', 'admin', 'restaurant', or 'ngo_admin'

  bool get isAdmin => role.toLowerCase() == 'admin';
  bool get isRestaurant => role.toLowerCase() == 'restaurant';
  bool get isNgoAdmin => role.toLowerCase() == 'ngo_admin';
  bool get isVolunteer => role.toLowerCase() == 'user';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      picture: json['picture'] as String?,
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      authProvider: json['authProvider'] as String? ?? 'email',
      role: json['role'] as String? ?? 'user',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'picture': picture,
      'isEmailVerified': isEmailVerified,
      'authProvider': authProvider,
      'role': role,
    };
  }
}

