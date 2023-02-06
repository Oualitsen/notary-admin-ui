import 'package:notary_admin/src/utils/validation_utils.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_model/model/preferences.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/src/subjects/subject.dart';

class PreferencesInputWidget extends StatefulWidget {
  const PreferencesInputWidget({Key? key}) : super(key: key);

  @override
  State<PreferencesInputWidget> createState() => PreferencesInputWidgetState();
}

class PreferencesInputWidgetState extends BasicState<PreferencesInputWidget>
    with WidgetUtilsMixin {
  final _formKey = GlobalKey<FormState>();
  final langCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
              controller: langCtrl,
              validator: (text) => ValidationUtils.requiredField(text, context),
              decoration: getDecoration(lang.language, true)),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Preferences? readPreferences() {
    if (_formKey.currentState?.validate() ?? false) {
      /**
       * Get the coordinqtes first
       */

      var preferences = Preferences(langCtrl.text);
      return preferences;
    }
    return null;
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
}
