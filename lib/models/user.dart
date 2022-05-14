class User {

  final int? id;
  final String username;

  User({
    this.id,
    required this.username
  });

  User copyWith({
    int? id,
    String? username,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        id: json['id'] as int,
        username: json['username'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': this.id,
    'username': this.username
  };

  @override
  String toString() => username;
}