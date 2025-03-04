import 'package:hive/hive.dart';

part 'account.g.dart';

@HiveType(typeId: 28)
class Account {
  const Account({
    required this.account,
    required this.password,
    this.username,
    this.isGuest,
  });

  @HiveField(0)
  final String account;

  @HiveField(1)
  final String password;

  @HiveField(2)
  final String? username;

  @HiveField(3)
  final bool? isGuest;

  bool equals(Account other) {
    return account == other.account &&
        password == other.password &&
        username == other.username;
  }
}
