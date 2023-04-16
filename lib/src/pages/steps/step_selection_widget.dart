import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http_error_handler/error_handler.dart';
import 'package:infinite_scroll_list_view/infinite_scroll_list_view.dart';
import 'package:notary_admin/src/pages/steps/add_step_widget.dart';
import 'package:notary_admin/src/services/admin/steps_service.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_model/model/steps.dart';
import 'package:notary_model/model/selection_type.dart';
import 'package:rxdart/subjects.dart';

class StepsSelection extends StatefulWidget {
  final SelectionType selectionType;
  const StepsSelection(
      {super.key, this.selectionType = SelectionType.MULTIPLE});

  @override
  State<StepsSelection> createState() => _StepsSelectionState();
}

class _StepsSelectionState extends BasicState<StepsSelection>
    with WidgetUtilsMixin {
  final service = GetIt.instance.get<StepsService>();
  final listKey = GlobalKey<InfiniteScrollListViewState>();
  final selectedStepsStream = BehaviorSubject.seeded(<Steps>[]);
  final stepsKey = GlobalKey<AddStepWidgetState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(lang.steps),
        actions: [
          ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(lang.addSteps),
                    content: AddStepWidget(key: stepsKey),
                    actions: [getButtons(onSave: onSave)],
                  ),
                );
              },
              child: Text(lang.addSteps))
        ],
      ),
      floatingActionButton: ElevatedButton(
        onPressed: save,
        child: Text(lang.ok.toUpperCase()),
      ),
      body: widget.selectionType == SelectionType.MULTIPLE
          ? selectMultiple()
          : selectOne(),
    );
  }

  Widget selectMultiple() {
    return StreamBuilder<List<Steps>>(
      stream: selectedStepsStream,
      initialData: selectedStepsStream.value,
      builder: (context, snapshot) {
        return InfiniteScrollListView<Steps>(
          key: listKey,
          elementBuilder:
              (BuildContext context, element, int index, animation) {
            final selectedSteps = snapshot.data!;

            return CheckboxListTile(
              value: selectedSteps.contains(element),
              onChanged: (bool? newValue) {
                if (newValue != null) {
                  if (newValue) {
                    selectedSteps.add(element);
                  } else {
                    selectedSteps.remove(element);
                  }
                  selectedStepsStream.add(selectedSteps);
                }
              },
              title: ListTile(
                leading: CircleAvatar(
                  child: Text("${element.name[0].toUpperCase()} "),
                ),
                title: Text("${element.name}"),
                subtitle: Text("${lang.formatDate(element.estimatedTime)}"),
                trailing: selectedSteps.indexOf(element) >= 0
                    ? Text("${(selectedSteps.indexOf(element) + 1)}")
                    : null,
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
            subtitle: Text("${lang.formatDate(element.estimatedTime)}"),
            onTap: () {
              Navigator.of(context).pop(element);
            },
          );
        },
        pageLoader: getData);
  }

  Future<List<Steps>> getData(int index) {
    return service.getStepList(index: index, size: 10);
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];

  void save() {
    Navigator.of(context).pop(selectedStepsStream.value);
  }

  onSave() async {
    var input = stepsKey.currentState?.read();
    if (input != null) {
      try {
        await service.saveStep(input);
        Navigator.of(context).pop();
        listKey.currentState?.reload();
      } catch (error, stacktrace) {
        print(stacktrace);
        showServerError(context, error: error);
        throw error;
      }
    }
  }
}
