import 'package:rxdart/rxdart.dart';

mixin SelectableRowsMixin<T> {
  final Set<String> selectedIds = {};
  final selected = BehaviorSubject<List<T>>.seeded([]);
  void onSelectChanged(bool? s, String id, void Function() updateUi) {
    if (s != null) {
      bool update;
      if (s) {
        update = selectedIds.add(id);
      } else {
        update = selectedIds.remove(id);
      }
      if (update) {
        updateUi();
      }
    }
  }
}
