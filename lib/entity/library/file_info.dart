class FileInfo {
  final String name;
  final int size;
  final String uuid;

  FileInfo({
    required this.name,
    required this.size,
    required this.uuid,
  });

  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    if (size < 1024 * 1024 * 1024) {
      return '${(size / 1024 / 1024).toStringAsFixed(1)} MB';
    }

    return '${(size / 1024 / 1024 / 1024).toStringAsFixed(1)} GB';
  }
}
