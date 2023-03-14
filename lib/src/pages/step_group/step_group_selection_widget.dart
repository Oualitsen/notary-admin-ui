import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:infinite_scroll_list_view/infinite_scroll_list_view.dart';
import 'package:notary_admin/src/pages/steps/add_step.dart';
import 'package:notary_admin/src/services/admin/step_group_service.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_model/model/step_group.dart';
import 'package:notary_model/model/selection_type.dart';
import 'package:rxdart/subjects.dart';

class StepGroupSelection extends StatefulWidget {
  final SelectionType selectionType;
  const StepGroupSelection(
      {super.key, this.selectionType = SelectionType.MULTIPLE});

  @override
  State<StepGroupSelection> createState() => _StepGroupSelectionState();
}

class _StepGroupSelectionState extends BasicState<StepGroupSelection>
    with WidgetUtilsMixin {
  final service = GetIt.instance.get<StepGroupService>();
  final listKey = GlobalKey<InfiniteScrollListViewState>();
  final selectedStepGroupStream = BehaviorSubject.seeded(<StepGroup>[]);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      width: 400,
      child: Scaffold(
        appBar: AppBar(
          title: Text(lang.steps),
          actions: [
            ElevatedButton(
                onPressed: () {
                  push(context, AddStepWidget());
                },
                child: Text(lang.addStepGroup))
          ],
        ),
        floatingActionButton: ElevatedButton(
          onPressed: save,
          child: Text(lang.ok.toUpperCase()),
        ),
        body: widget.selectionType == SelectionType.MULTIPLE
            ? selectMultiple()
            : selectOne(),
      ),
    );
  }

  Widget selectMultiple() {
    return StreamBuilder<List<StepGroup>>(
      stream: selectedStepGroupStream,
      initialData: selectedStepGroupStream.value,
      builder: (context, snapshot) {
        return InfiniteScrollListView<StepGroup>(
          elementBuilder:
              (BuildContext context, element, int index, animation) {
            final selectedStepGroups = snapshot.data!;

            return CheckboxListTile(
              value: selectedStepGroups.contains(element),
              onChanged: (bool? newValue) {
                if (newValue != null) {
                  if (newValue) {
                    selectedStepGroups.add(element);
                  } else {
                    selectedStepGroups.remove(element);
                  }
                  selectedStepGroupStream.add(selectedStepGroups);
                }
              },
              title: ListTile(
                leading: CircleAvatar(
                  child: Text("${element.name[0].toUpperCase()}"),
                ),
                title: Text("${element.name}"),
                subtitle: Text("${lang.formatDate(element.creationDate)}"),
                onTap: null,
              ),
            );
          },
          pageLoader: getData,
        );
      },
    );
  }

  Widget selectOne() {
    return InfiniteScrollListView(
        elementBuilder: (context, element, index, animation) {
          return ListTile(
            leading: CircleAvatar(
              child: Text("${element.name[0]}"),
            ),
            title: Text("${element.name}"),
            subtitle: Text("${lang.formatDate(element.creationDate)}"),
            onTap: () {
              Navigator.of(context).pop(element);
            },
          );
        },
        pageLoader: getData);
  }

  Future<List<StepGroup>> getData(int index) {
    return service.getStepGroupList(index: index, size: 10);
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];

  void save() {
    Navigator.of(context).pop(selectedStepGroupStream.value);
  }
}
