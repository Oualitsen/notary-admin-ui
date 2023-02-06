
/*
import 'package:flutter/material.dart';
import 'package:notary_admin/src/utils/widget_utils.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/phone_with_verification.dart';
import 'package:rapidoc_utils/widgets/image_utils.dart';
import 'package:rxdart/rxdart.dart';

class EditPhonePage extends StatefulWidget {
  final bool pop;
  const EditPhonePage({Key? key, this.pop = true}) : super(key: key);

  @override
  _EditPhonePageState createState() => _EditPhonePageState();
}

class _EditPhonePageState extends BasicState<EditPhonePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ImageUtils.fromAsset("assets/images/logo-no-bg.png", height: 45)
          ],
        ),
        actions: [if (!widget.pop) logoutButton(context)],
      ),
      body: PhoneWithVerificationWidget(pop: widget.pop),
    );
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
}
*/
