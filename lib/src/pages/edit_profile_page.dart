/*import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:notary_admin/src/db_services/token_db_service.dart';
import 'package:notary_admin/src/init.dart';
import 'package:notary_admin/src/pages/change_password_page.dart';
import 'package:notary_admin/src/pages/edit_email_page.dart';
import 'package:notary_admin/src/pages/edit_info_page.dart';
import 'package:notary_admin/src/pages/edit_phone_page.dart';
import 'package:notary_admin/src/services/profile_service.dart';
import 'package:notary_admin/src/utils/injector.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_admin/src/widgets/mixins/lang.dart';
import 'package:notary_admin/src/widgets/mixins/media_mixin.dart';
import 'package:notary_model/model/image_data.dart';
import 'package:notary_model/model/users/users.dart';
import 'package:rapidoc_utils/widgets/image_utils.dart';
import 'package:rxdart/rxdart.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends BasicState<EditProfilePage>
    with MediaMixin, WidgetUtilsMixin {
  final authMan = Injector.provideAuthManager();
  final service = GetIt.instance.get<ProfileService>();
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Customer?>(
        stream: authMan.userSubject,
        initialData: authMan.userSubject.valueOrNull,
        builder: (context, snapshot) {
          var user = snapshot.data;
          if (user == null) {
            return const SizedBox.shrink();
          }
          var info = user.basicUserInfo;
          var email = user.email;
          var number = user.number;
          return Scaffold(
            appBar: AppBar(
              title: Text(lang.profile),
            ),
            body: ListView(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ImageUtils.fromNetworkRounded(
                              getImageUrl(user.imageUrl, 128),
                              width: 128,
                              height: 128,
                              placeHolder: "assets/images/profile.png"),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        StreamBuilder<double?>(
                            stream: uploadProgress,
                            initialData: uploadProgress.valueOrNull,
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return retryButton(context);
                              }

                              if (!snapshot.hasData) {
                                return TextButton(
                                    onPressed: () => editPicture(context),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.edit),
                                        const SizedBox(width: 16),
                                        Text(lang.edit.toUpperCase()),
                                      ],
                                    ));
                              }

                              final progress = snapshot.data!;
                              return Row(
                                children: [
                                  const Icon(Icons.upload),
                                  const SizedBox(width: 16),
                                  Text("${(progress).toInt()} %"),
                                ],
                              );
                            }),
                        const SizedBox(width: 16),
                      ],
                    ),
                  ],
                ),
                _Card(
                  title: lang.personalInfo,
                  onEdit: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const EditInfoPage(),
                    ),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(info?.firstName ?? "-"),
                        subtitle: Text(lang.firstName),
                      ),
                      ListTile(
                        title: Text(info?.lastName ?? "-"),
                        subtitle: Text(lang.lastName),
                      ),
                    ],
                  ),
                ),
                _Card(
                  title: lang.email,
                  child: ListTile(
                    title: Text(email?.email ?? "-"),
                    subtitle: Text(lang.email),
                    trailing: (email?.verified ?? false)
                        ? null
                        : Tooltip(
                            message: lang.tapToVerifyYourEmail,
                            child: const Icon(Icons.warning)),
                  ),
                  onEdit: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const EditEmailPage(),
                    ),
                  ),
                ),
                _Card(
                  title: lang.phoneNumber,
                  child: ListTile(
                    title: Text(number?.international ?? "-"),
                    subtitle: Text(lang.phoneNumber),
                  ),
                  onEdit: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const EditPhonePage(),
                    ),
                  ),
                ),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(lang.changePassword),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ChangePasswordPage(),
                          ),
                        ),
                      ),
                      const Divider(),
                      ListTile(
                        title: Text(lang.logout),
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
                            final userManager = Injector.provideAuthManager();
                            return userManager.remove();
                          }).asyncMap((event) {
                            var service = GetIt.instance.get<TokenDbService>();
                            return service.remove();
                          }).listen((event) {
                            //print("logged out");
                          });
                        },
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        });
  }

  void editPicture(BuildContext context) {
    uploadDynamic("/secured-image/upload", context)
        .map((event) => ImageData.fromJson(event))
        .flatMap((value) => runFuture(service.updateImageUrl(value.url)))
        .listen(authMan.userSubject.add);
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [uploadProgress];
}

class _Card extends StatelessWidget with StatelessLangMixin {
  final String title;
  final Function() onEdit;
  final Widget child;

  _Card({required this.title, required this.onEdit, required this.child});
  @override
  Widget build(BuildContext context) {
    var lang = getLang(context);
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          child,
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: onEdit,
                child: Row(
                  children: [
                    const Icon(Icons.edit),
                    const SizedBox(width: 10),
                    Text(lang.edit.toUpperCase())
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
*/
