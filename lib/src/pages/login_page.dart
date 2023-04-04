import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_admin/src/widgets/progress_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_responsive_tools/screen_type_layout.dart';
import 'package:get_it/get_it.dart';
import 'package:notary_admin/src/db_services/token_db_service.dart';
import 'package:notary_admin/src/services/login_service.dart';
import 'package:notary_admin/src/utils/injector.dart';
import 'package:notary_admin/src/utils/validation_utils.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/password_input.dart';
import 'package:notary_model/model/login_object.dart';
import 'package:http_error_handler/error_handler.dart';
import 'package:rxdart/rxdart.dart';

class LoginPage extends StatefulWidget {
  static const login = "/login";

  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends BasicState<LoginPage> with WidgetUtilsMixin {
  final key = GlobalKey<FormState>();
  final userNameCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final service = GetIt.instance.get<LoginService>();

  final _authMan = Injector.provideAuthManager();
  final _tokenDbService = GetIt.instance.get<TokenDbService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(lang.login),
      ),
      body: AutoScreenTypeLayout(
        child: Form(
          key: key,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: userNameCtrl,
                validator: (text) {
                  if (text?.isEmpty ?? true) {
                    return lang.requiredField;
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: lang.userName,
                ),
              ),
              const SizedBox(height: 10),
              PasswordInput(
                controller: passwordCtrl,
                validator: (text) =>
                    ValidationUtils.requiredField(text, context),
                label: Text(lang.password),
              ),
              const SizedBox(height: 10),
              ProgressWrapper(
                progressStream: progressSubject,
                child: ElevatedButton(
                  onPressed: () {
                    _login(context);
                  },
                  child: Text(lang.login.toUpperCase()),
                ),
                progressChild: ElevatedButton(
                  onPressed: null,
                  child: Text(lang.login.toUpperCase()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _login(BuildContext context) async {
    var state = key.currentState;

    if (state != null) {
      if (state.validate()) {
        LoginObject object = LoginObject(
            username: userNameCtrl.text, password: passwordCtrl.text);
        progressSubject.add(true);
        try {
          print("@@@@@@@@@@@@ ${object.username}");
          var result = await service.login(loginObject: object);
          print("@@@@@@@@@@@@ ${result.user.userType}");
          await _tokenDbService.save(result.token);

          await _authMan.save(result.user);
        }   catch (error, stacktrace) {
                  showServerError(context, error: error);
                  print(stacktrace);
                } finally {
          progressSubject.add(false);
        }
      }
    }
  }

  @override
  List<ChangeNotifier> get notifiers => [userNameCtrl, passwordCtrl];

  @override
  List<Subject> get subjects => [];
}
