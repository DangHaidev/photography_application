class Like {
  final String userId;

  Like({required this.userId});

  factory Like.fromMap(Map<String, dynamic> data) {
    return Like(userId: data['userId']);
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
    };
  }
}
