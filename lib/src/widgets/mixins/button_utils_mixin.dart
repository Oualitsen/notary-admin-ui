import 'package:flutter/material.dart';
import 'package:http_error_handler/error_handler.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/progress_wrapper.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:rapidoc_utils/utils/Utils.dart';
import 'package:rxdart/rxdart.dart';

mixin WidgetUtilsMixin<T extends StatefulWidget> on BasicState<T> {
  final progressSubject = BehaviorSubject.seeded(false);

  Widget getButtons({
    Function()? onCancel,
    required Function() onSave,
    String? saveLabel,
    String? cancelLabel,
    Stream<bool>? progressStream,
    bool skipCancel = false,
  }) =>
      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        if (!skipCancel) ...[
          TextButton(
            onPressed: onCancel ?? Navigator.of(context).pop,
            child: Text(cancelLabel ?? lang.cancel.toUpperCase()),
          ),
          const SizedBox(width: 16),
        ],
        ProgressWrapper(
            progressStream: progressStream ?? progressSubject,
            child: _getSaveButton(saveLabel, onSave),
            progressChild: _getSaveButton(saveLabel, null))
      ]);

  Widget _getSaveButton(String? label, Function()? onPressed) {
    return ElevatedButton(
        onPressed: onPressed, child: Text(label ?? lang.save.toUpperCase()));
  }

  Widget getOkButton([String? label, Object? returnValue]) => TextButton(
      onPressed: () => Navigator.of(context).pop(returnValue ?? true),
      child: Text(label ?? lang.ok.toString()));

  Widget getCancelButton([String? label, Object? returnValue]) => TextButton(
      onPressed: () => Navigator.of(context).pop(returnValue ?? false),
      child: Text(label ?? lang.cancel.toString()));

  List<Widget> getOkCancel() => [getCancelButton(), getOkButton()];

  InputDecoration getDecoration(String label, bool required,
          [String? hinttext, Widget? suffix]) =>
      InputDecoration(
        border: const OutlineInputBorder(),
        label: getLabel(label, required),
        hintText: hinttext,
        suffix: suffix,
      );

  Widget getLabel(String label, bool required) {
    return required
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label),
              const SizedBox(width: 10),
              const SizedBox(width: 5),
              const Text(
                "*",
                style: TextStyle(color: Colors.red),
              ),
            ],
          )
        : Text(label);
  }

  Future<SnackBarClosedReason> showSnackBar2(
      BuildContext context, String content) {
    return ScaffoldMessenger.of(context)
        .showSnackBar(
          SnackBar(
            content: Text(content),
            action: SnackBarAction(
              label: lang.ok.toUpperCase(),
              onPressed: () {},
            ),
          ),
        )
        .closed;
  }

  Stream confirm(String title, String message) {
    return showAlertDialog(
            context: context,
            title: title,
            message: message,
            actions: getOkCancel())
        .asStream()
        .where((event) => event == true);
  }

  Widget title(String title) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(title, style: Theme.of(context).textTheme.headline6),
    );
  }

  Stream<E> push<E extends Object?>(BuildContext context, Widget widget,
      {bool dialog = false}) {
    if (dialog) {
      return showDialog<E>(
        context: context,
        builder: (context) => widget,
      ).asStream().where((event) => event != null).map((event) => event!);
    }
    return Navigator.of(context)
        .push<E>(
          MaterialPageRoute(
            builder: (context) => widget,
          ),
        )
        .asStream()
        .where((event) => event != null)
        .map((event) => event!);
  }

  Widget wrapInIgnorePointer(
          {required Widget child, required void Function() onTap}) =>
      InkWell(
        onTap: onTap,
        child: IgnorePointer(
          child: child,
        ),
      );

  Stream<E> runFuture<E>(Future<E> f) {
    return f
        .asStream()
        .doOnListen(() => progressSubject.add(true))
        .doOnError((p0, p1) => showServerError(context, error: p0))
        .doOnDone(() => progressSubject.add(false));
  }

  Future<List<DateTime>?> checkDates(OmniDateTimePickerType dateTime) async {
    List<DateTime>? dateTimeList = await showDateTime(dateTime);
    if ((dateTimeList![1].isBefore(dateTimeList[0])) ||
        (dateTimeList[1].isAtSameMomentAs(dateTimeList[0]))) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(lang.invalidDateRange),
        ),
      );
      return null;
    }

    return dateTimeList;
  }

  Future<List<DateTime>?> showDateTime(OmniDateTimePickerType dateTime) async =>
      await showOmniDateTimeRangePicker(
        context: context,
        type: dateTime,
        primaryColor: Colors.cyan,
        backgroundColor: Colors.grey[900],
        calendarTextColor: Colors.white,
        tabTextColor: Colors.white,
        unselectedTabBackgroundColor: Colors.grey[700],
        buttonTextColor: Colors.white,
        timeSpinnerTextStyle:
            const TextStyle(color: Colors.white70, fontSize: 18),
        timeSpinnerHighlightedTextStyle:
            const TextStyle(color: Colors.white, fontSize: 24),
        is24HourMode: true,
        isShowSeconds: false,
        startInitialDate: DateTime.now(),
        startFirstDate: DateTime.now().subtract(const Duration(days: 365)),
        startLastDate: DateTime.now().add(
          const Duration(days: 365),
        ),
        endInitialDate: DateTime.now(),
        endFirstDate: DateTime.now().subtract(const Duration(days: 365)),
        endLastDate: DateTime.now().add(
          const Duration(days: 365),
        ),
        borderRadius: const Radius.circular(16),
      );

  Future<void> showMyDialog(Widget textButton) async {
    return showAlertDialog(
      context: context,
      title: lang.pleaseConfirm,
      message: lang.confirmDelete,
      actions: <Widget>[
        TextButton(
          child: Text(lang.no.toUpperCase()),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        textButton,
      ],
    );
  }
}
