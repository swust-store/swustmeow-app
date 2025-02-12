import 'package:hive/hive.dart';

part 'version.g.dart';

@HiveType(typeId: 26)
class Version {
  @HiveField(0)final int a;
  @HiveField(1)final int b;
  @HiveField(2)final int c;

  const Version(this.a, this.b, this.c);

  factory Version.parse(String abc) {
    final parts = abc.split('.').map(int.parse).toList();
    if (parts.length != 3) {
      throw FormatException('未知版本：$abc');
    }
    return Version(parts[0], parts[1], parts[2]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Version) return false;
    return a == other.a && b == other.b && c == other.c;
  }

  @override
  int get hashCode => Object.hash(a, b, c);

  @override
  String toString() => '$a.$b.$c';

  bool operator <(Version other) => compareTo(other) < 0;

  bool operator >(Version other) => compareTo(other) > 0;

  bool operator <=(Version other) => compareTo(other) <= 0;

  bool operator >=(Version other) => compareTo(other) >= 0;

  int compareTo(Version other) {
    if (a != other.a) return a.compareTo(other.a);
    if (b != other.b) return b.compareTo(other.b);
    return c.compareTo(other.c);
  }
}
