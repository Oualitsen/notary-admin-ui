import 'package:notary_admin/src/services/admin/profile_service.dart';
import 'package:notary_admin/src/utils/validation_utils.dart';
import 'package:notary_admin/src/widgets/password_input.dart';
import 'package:notary_model/model/admin.dart';
import 'package:notary_model/model/password_change.dart';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:notary_admin/main.dart';
import 'package:notary_admin/src/db_services/token_db_service.dart';
import 'package:notary_admin/src/utils/injector.dart';
import 'package:notary_admin/src/utils/widget_utils.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_admin/src/widgets/mixins/lang.dart';
import 'package:notary_admin/src/widgets/mixins/media_mixin.dart';
import 'package:http_error_handler/error_handler.dart';
import 'package:rxdart/rxdart.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  static const routeName = "profile";

  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends BasicState<ProfilePage>
    with MediaMixin, WidgetUtilsMixin {
  final authMan = Injector.provideAuthManager();

  final service = GetIt.instance.get<ProfileService>();
  final passwordKey = GlobalKey<FormState>();

  final newPasswordController = TextEditingController();
  final oldPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return WidgetUtils.wrapRoute(
      (context, type) => StreamBuilder<Admin?>(
          stream: authMan.userSubject,
          initialData: authMan.userSubject.valueOrNull,
          builder: (context, snapshot) {
            var user = snapshot.data;
            if (user == null) {
              return const SizedBox.shrink();
            }
            return Scaffold(
              appBar: AppBar(
                iconTheme: const IconThemeData(color: Colors.black),
                elevation: 0.0,
                backgroundColor: Colors.transparent,
                actions: [],
              ),
              body: Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "${user.firstName} ${user.lastName}",
                                style: const TextStyle(
                                    fontSize: 23, fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                          const SizedBox(height: 20),
                          wrap(Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    const Icon(FontAwesomeIcons.globe),
                                    const SizedBox(width: 10),
                                    Text(lang.changeLanguage),
                                  ],
                                ),
                                const SizedBox(height: 32),
                                Row(
                                  textDirection: TextDirection.ltr,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children:
                                      settingsController.supportedLocales.map(
                                    (e) {
                                      if (settingsController.locale == e) {
                                        return ElevatedButton(
                                            onPressed: () {
                                              settingsController
                                                  .updateLocale(e);
                                            },
                                            child: Text(lang
                                                .getLangName(e.languageCode)));
                                      }
                                      return OutlinedButton(
                                          onPressed: () {
                                            settingsController.updateLocale(e);
                                          },
                                          child: Text(lang
                                              .getLangName(e.languageCode)));
                                    },
                                  ).toList(),
                                )
                              ],
                            ),
                          )),
                          const SizedBox(height: 20),
                          wrap(InkWell(
                            onTap: () async {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return Form(
                                      key: passwordKey,
                                      child: AlertDialog(
                                        title: Text(lang.changePassword),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            PasswordInput(
                                              controller: oldPasswordController,
                                              label: Text(lang.oldPassword),
                                              validator: (text) {
                                                return ValidationUtils
                                                    .requiredField(
                                                        text, context);
                                              },
                                            ),
                                            SizedBox(
                                              height: 16,
                                            ),
                                            PasswordInput(
                                              controller: newPasswordController,
                                              label: Text(lang.newPassword),
                                              validator: (text) {
                                                return ValidationUtils
                                                    .requiredField(
                                                        text, context);
                                              },
                                            ),
                                            const SizedBox(height: 16),
                                          ],
                                        ),
                                        actions: <Widget>[
                                          getButtons(
                                              onSave: resetPassword,
                                              saveLabel: lang.changePassword),
                                        ],
                                      ),
                                    );
                                  });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.lock),
                                  const SizedBox(width: 10),
                                  Text(lang.changePassword),
                                ],
                              ),
                            ),
                          )),
                          const SizedBox(height: 20),
                          wrap(InkWell(
                            onTap: () async {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  title: Text(lang.confirm),
                                  content: Text(lang.confirmLogout),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text(lang.no.toUpperCase()),
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                    ),
                                    TextButton(
                                      child: Text(lang.yes.toUpperCase()),
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                    )
                                  ],
                                ),
                              )
                                  .asStream()
                                  .where((event) => event)
                                  .asyncMap((event) {
                                final userManager =
                                    Injector.provideAuthManager();
                                return userManager.remove();
                              }).asyncMap((event) {
                                var service =
                                    GetIt.instance.get<TokenDbService>();
                                return service.remove();
                              }).listen((event) {
                                //print("logged out");
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.logout),
                                  const SizedBox(width: 10),
                                  Text(lang.logout),
                                ],
                              ),
                            ),
                          ))
                        ],
                      ),
                      const SizedBox(height: 20),
                      wrap(
                        InkWell(
                          onTap: () {},
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                const Icon(Icons.file_copy_rounded),
                                Text(lang.termsAndConditions)
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }

  resetPassword() async {
    if (passwordKey.currentState?.validate() ?? false) {
      progressSubject.add(true);
      try {
        var passwords = PasswordChange(
            oldPasswordController.text, newPasswordController.text);
        await service.updateAdminPassword(password: passwords);
        Navigator.of(context).pop();
        await showSnackBar2(context, lang.savedSuccessfully);
      } catch (error) {
        showServerError(context, error: error);
      } finally {
        newPasswordController.clear();
        oldPasswordController.clear();
        progressSubject.add(false);
      }
    }
  }

  Future<ImageSource?> imageSource2(BuildContext context) =>
      showModalBottomSheet<ImageSource>(
        context: context,
        builder: (context) => ListView(
          children: [
            ListTile(
              title: Text(lang.camera.toUpperCase()),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            ListTile(
              title: Text(lang.gallery.toUpperCase()),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
          ],
        ),
      );

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [uploadProgress];
}
