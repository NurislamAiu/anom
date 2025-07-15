class UserModel {
  final String username;
  final String passwordHash;

  UserModel({required this.username, required this.passwordHash});

  Map<String, dynamic> toJson() => {
    'username': username,
    'passwordHash': passwordHash,
  };

  static UserModel fromJson(Map<String, dynamic> json) => UserModel(
    username: json['username'],
    passwordHash: json['passwordHash'],
  );
}