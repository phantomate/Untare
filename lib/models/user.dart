import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class User {

  @HiveField(0)
  final int? id;
  @HiveField(1)
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