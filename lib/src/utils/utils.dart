class ListUtils {
  static T? getFirstElement<T>(List<T>? list) {
    if (list == null) return null;
    return list.isNotEmpty ? list.first : null;
  }
}
