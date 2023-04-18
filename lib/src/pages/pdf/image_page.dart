import 'package:flutter/material.dart';
import 'package:flutter/src/animation/animation_controller.dart';
import 'package:flutter/src/foundation/change_notifier.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/ticker_provider.dart';
import 'package:notary_admin/src/pages/pdf/image_widget.dart';
import 'package:notary_admin/src/utils/widget_utils.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:rxdart/src/subjects/subject.dart';

class ImagePage extends StatefulWidget {
  final String title;
  final String token;
  final String imageId;
  const ImagePage({
    super.key,
    required this.token,
    required this.imageId,
    required this.title,
  });

  @override
  State<ImagePage> createState() => _ImagePageState();
}

class _ImagePageState extends BasicState<ImagePage> {
  @override
  Widget build(BuildContext context) {
    return WidgetUtils.wrapRoute(
      (context, type) => Scaffold(
        appBar: AppBar(
          title: Text("${widget.title}"),
        ),
        body: SingleChildScrollView(
          child: ImageWidget(
            imageId: widget.imageId,
            token: widget.token,
            onAngleChanged: (_) => null,
          ),
        ),
      ),
    );
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
}
