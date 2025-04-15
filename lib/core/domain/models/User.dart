class User {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  final String bio;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.bio,
  });

  factory User.fromMap(String id, Map<String, dynamic> data) {
    return User(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      avatarUrl: data['avatarUrl'] ?? '',
      bio: data['bio'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'bio': bio,
    };
  }
}
