import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http_error_handler/error_handler.dart';
import 'package:lazy_paginated_data_table/lazy_paginated_data_table.dart';
import 'package:notary_admin/src/pages/assistant/assistant_details_input.dart';
import 'package:notary_admin/src/services/assistant/admin_assistant_service.dart';
import 'package:notary_admin/src/utils/validation_utils.dart';
import 'package:notary_admin/src/utils/widget_mixin_new.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_admin/src/widgets/password_input.dart';
import 'package:notary_model/model/admin.dart';
import 'package:notary_model/model/assistant_input.dart';
import 'package:rxdart/src/subjects/subject.dart';

class AssistantTableWidget extends StatefulWidget {
  final GlobalKey<LazyPaginatedDataTableState>? tableKey;
  AssistantTableWidget({super.key, this.tableKey});

  @override
  State<AssistantTableWidget> createState() => AssistantTableWidgetState();
}

class AssistantTableWidgetState extends BasicState<AssistantTableWidget>
    with WidgetUtilsMixin {
  final service = GetIt.instance.get<AdminAssistantService>();
  bool initialized = false;
  final columnSpacing = 65.0;
  List<DataColumn> columns = [];
  final assistantKey = GlobalKey<AssistantDetailsInputState>();
  final _formKeyNewPassword = GlobalKey<FormState>();
  final newPwdCtr = TextEditingController();
  @override
  Widget build(BuildContext context) {
    columns = [
      DataColumn(label: Text(lang.firstName.toUpperCase())),
      DataColumn(label: Text(lang.lastName.toUpperCase())),
      DataColumn(label: Text(lang.userName.toUpperCase())),
      DataColumn(label: Text(lang.gender.toUpperCase())),
      DataColumn(label: Text(lang.edit)),
      DataColumn(label: Text(lang.resetPassword.toUpperCase())),
      DataColumn(label: Text(lang.delete.toUpperCase()))
    ];

    return SingleChildScrollView(
      child: LazyPaginatedDataTable<Admin>(
          key: widget.tableKey,
          columnSpacing: columnSpacing,
          getData: getData,
          getTotal: getTotal,
          columns: columns,
          dataToRow: dataToRow),
    );
  }

  Future<List<Admin>> getData(PageInfo page) {
    return service.getAssistants(index: page.pageIndex, size: page.pageSize);
  }

  Future<int> getTotal() {
    return service.getAssistantsCount();
  }

  DataRow dataToRow(Admin data, int indexInCurrentPage) {
    var cellList = [
      DataCell(Text(data.firstName)),
      DataCell(Text(data.lastName)),
      DataCell(Text(data.username)),
      DataCell(Text(lang.genderName(data.gender))),
      DataCell(
        TextButton(
          child: Text(lang.edit),
          onPressed: (() => editAssistant(context, data)),
        ),
      ),
      DataCell(
        TextButton(
            child: Text(lang.reset), onPressed: (() => resetPassword(data))),
      ),
      DataCell(
        TextButton(
          child: Text(lang.delete),
          onPressed: () {
            deleteConfirmation(data.id);
          },
        ),
      ),
    ];
    return DataRow(cells: cellList);
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
  void deleteConfirmation(String assistantId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lang.confirm),
        content: Text(lang.confirmDelete),
        actions: <Widget>[
          TextButton(
            child: Text(lang.no.toUpperCase()),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: Text(lang.yes.toUpperCase()),
            onPressed: (() => delete(assistantId)),
          ),
        ],
      ),
    );
  }

  void delete(String assistantId) async {
    progressSubject.add(true);
    try {
      await service.deleteAssistant(assistantId);
      Navigator.of(context).pop(false);
      widget.tableKey?.currentState?.refreshPage();
      showSnackBar2(context, lang.deletedSuccessfully);
    } catch (error, stacktrace) {
      showServerError(context, error: error);
      print(stacktrace);
    } finally {
      progressSubject.add(false);
    }
  }

  void editAssistant(BuildContext context, Admin assistant) async {
    return WidgetMixin.showDialog2(
      context,
      label: lang.addSteps,
      content: Container(
        height: 200,
        child: AssistantDetailsInput(
          key: assistantKey,
          assistant: assistant,
        ),
      ),
      actions: <Widget>[
        getButtons(onSave: () => saveAssistant(assistant)),
      ],
    );
  }

  void saveAssistant(Admin assistant) async {
    Navigator.pop(context);
    AssistantDetails? value = assistantKey.currentState?.readDetails();
    if (value != null) {
      var input = AssistantInput(
        id: assistant.id,
        firstName: value.firstName,
        lastName: value.lastName,
        username: assistant.username,
        password: assistant.password,
        roles: assistant.roles,
        gender: value.gender,
      );
      try {
        progressSubject.add(true);
        await service.saveAssistant(input);
        widget.tableKey?.currentState?.refreshPage();
        await showSnackBar2(context, lang.updatedSuccessfully);
      } catch (error, stacktrace) {
        showServerError(context, error: error);
        print(stacktrace);
      } finally {
        progressSubject.add(false);
      }
    }
  }

  void resetPassword(Admin assistant) {
    WidgetMixin.showDialog2(
      context,
      label: lang.resetPassword.toUpperCase(),
      content: Container(
        height: 100,
        width: 400,
        child: Form(
          key: _formKeyNewPassword,
          child: PasswordInput(
            controller: newPwdCtr,
            label: Text(lang.newPassword),
            validator: (text) {
              return ValidationUtils.requiredField(text, context);
            },
          ),
        ),
      ),
      actions: <Widget>[
        getButtons(
          onSave: () => setPasswordAssistant(assistant),
          saveLabel: lang.submit.toUpperCase(),
          skipCancel: true,
        ),
      ],
    );
  }

  setPasswordAssistant(Admin assistant) async {
    if (_formKeyNewPassword.currentState!.validate()) {
      progressSubject.add(true);
      try {
        await service.ResetPasswordAssistant(assistant.id, newPwdCtr.text);

        showSnackBar2(context, lang.passwordChanged);
        Navigator.pop(context);
      } catch (error, stacktrace) {
        showServerError(context, error: error);
        print(stacktrace);
      } finally {
        progressSubject.add(false);
      }
    }
  }
}
