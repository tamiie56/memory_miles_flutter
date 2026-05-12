// lib/models/user.dart

class User {
  final String id;
  final String username;
  final String email;
  final String profilePicture;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.profilePicture = '',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      profilePicture: json['profilePicture'] ?? '',
    );
  }
}