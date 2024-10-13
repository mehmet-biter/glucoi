import 'dart:io';

extension StringEx on String? {
  bool get isValid => this != null && this!.isNotEmpty;

  String toCapitalizeFirst() {
    return isValid ? "${this![0].toUpperCase()}${this!.substring(1).toLowerCase()}" : "";
  }

  String substringBetween(String first, String last) {
    if (this != null || this!.isNotEmpty) {
      final startIndex = this!.indexOf(first);
      final endIndex = this!.indexOf(last);
      if (startIndex != -1 && endIndex != -1) {
        final text = this!.substring(startIndex + first.length, endIndex);
        return text;
      }
    }
    return "";
  }
}

extension ListEx on List? {
  bool get isValid => this != null && this!.isNotEmpty;

  bool hasIndex(int index) {
    return this != null && this!.isNotEmpty && this!.length > index && index != -1;
  }
}

extension FileExtention on FileSystemEntity? {
  String get name => (this?.path.split("/").last) ?? "";
}
