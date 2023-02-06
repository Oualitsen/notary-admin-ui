import 'package:flutter/material.dart';
import 'package:notary_admin/src/widgets/mixins/lang.dart';

class NotFoundPage extends StatelessWidget with StatelessLangMixin {
  const NotFoundPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var lang = getLang(context);
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Text(
              "404",
              style: Theme.of(context).textTheme.headline1,
            ),
            const SizedBox(height: 36),
            Text(lang.notFound),
          ],
        ),
      ),
    );
  }
}
