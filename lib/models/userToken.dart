// ignore_for_file: file_names

class UserToken {
  final String token;
  final int userId;

  UserToken({
    required this.token,
    required this.userId
  });

  factory UserToken.fromJson(Map<String, dynamic> json) {
    return UserToken(
        token: json['token'] as String,
        userId: json['user_id'] as int
    );
  }

  Map<String, dynamic> toJson() => {
    'token': token,
    'user_id': userId
  };
}