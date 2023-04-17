import 'package:flutter/material.dart';
import 'package:flutter_responsive_tools/device_screen_type.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:rxdart/subjects.dart';

class SearchWidget extends StatefulWidget {
  final DeviceScreenType? type;
  final bool useType;
  final Function(String searchValue) onChange;
  final List<Widget>? moreActions;
  const SearchWidget(
      {super.key,
      this.useType = true,
      required this.type,
      required this.onChange,
      this.moreActions});

  @override
  State<SearchWidget> createState() => SearchWidgetState();
}

class SearchWidgetState extends BasicState<SearchWidget> with WidgetUtilsMixin {
  final searchCtrl = TextEditingController();
  final searchStream = BehaviorSubject.seeded(false);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
        initialData: searchStream.value,
        stream: searchStream,
        builder: (context, snapshot) {
          var doSearch = snapshot.data!;
          if (doSearch) {
            return widget.useType
                ? Expanded(
                    child: searchWidget(),
                  )
                : searchWidget();
          }
          if (widget.useType) {
            return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (widget.type == DeviceScreenType.desktop) ...[
                    ...widget.moreActions ?? [],
                    createSearchButton(lang.search.toUpperCase(),
                        Theme.of(context).canvasColor),
                  ],
                  if (widget.type != DeviceScreenType.desktop) ...[
                    ...widget.moreActions ?? [],
                    createSearchButton("", Theme.of(context).canvasColor),
                  ]
                ]);
          }
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ...widget.moreActions ?? [],
              createSearchButton(
                  lang.search.toUpperCase(), Theme.of(context).primaryColor),
            ],
          );
        });
  }

  Widget createSearchButton(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextButton.icon(
          onPressed: () {
            searchStream.add(true);
          },
          icon: Icon(
            Icons.search,
            color: color,
          ),
          label: Text(label.toUpperCase(), style: TextStyle(color: color))),
    );
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];

  Widget searchWidget() {
    return Container(
      width: double.minPositive,
      height: 50,
      decoration: BoxDecoration(
        color: Theme.of(context).canvasColor,
      ),
      child: Center(
        child: TextFormField(
          autofocus: true,
          onChanged: (value) {
            widget.onChange(value);
          },
          controller: searchCtrl,
          decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
              labelText: lang.search,
              suffixIcon: IconButton(
                  onPressed: () {
                    searchStream.add(false);
                    searchCtrl.clear();
                    widget.onChange("");
                  },
                  icon: Icon(Icons.close))),
        ),
      ),
    );
  }
}
