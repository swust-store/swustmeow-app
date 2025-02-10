import 'package:hive/hive.dart';

part 'auth_token.g.dart';

@HiveType(typeId: 21)
class AuthToken {
  const AuthToken({
    required this.tokenType,
    required this.token,
    required this.expireDate,
  });

  @HiveField(0)
  final String tokenType;
  @HiveField(1)
  final String token;
  @HiveField(2)
  final DateTime expireDate;
}
