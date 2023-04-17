import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http_error_handler/error_handler.dart';
import 'package:notary_admin/src/init.dart';
import 'package:notary_admin/src/services/files/pdf_service.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:rxdart/subjects.dart';
import 'dart:math' as math;

class ImageWidget extends StatefulWidget {
  final String imageId;
  final String token;
  final Function(double angle) onAngleChanged;
  const ImageWidget(
      {super.key,
      required this.imageId,
      required this.token,
      required this.onAngleChanged});

  @override
  State<ImageWidget> createState() => _ImageWidgetState();
}

class _ImageWidgetState extends BasicState<ImageWidget> with WidgetUtilsMixin {
  final rotationAngleStream = BehaviorSubject<double>.seeded(0.0);
  final pdfService = GetIt.instance.get<PdfService>();
  late String url;
  @override
  void initState() {
    super.initState();
    url = getImageUrl(widget.imageId);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          child: Column(
            children: [
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      rotate(false);
                    },
                    child: Text(lang.rotateLeft.toUpperCase()),
                  ),
                  TextButton(
                    onPressed: () {
                      rotate(true);
                    },
                    child: Text(lang.rotateRight.toUpperCase()),
                  ),
                ],
              ),
              StreamBuilder<double>(
                stream: rotationAngleStream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return SizedBox.shrink();
                  }

                  return Transform.rotate(
                    angle: snapshot.data!,
                    child: Image.network(
                      url,
                      headers: {"Authorization": "Bearer ${widget.token}"},
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  String getImageUrl(String imageId, [bool disableCache = true]) {
    return "${getUrlBase()}/admin/pdf/image/${imageId}${disableCache ? ('?date=' + DateTime.now().millisecondsSinceEpoch.toString()) : ''}";
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];

  void rotate(bool rotateForward) async {
    var value = rotateForward ? (math.pi / 2) : (-math.pi / 2);
    var angle = rotationAngleStream.value;
    angle += value;
    rotationAngleStream.add(angle);
    widget.onAngleChanged(angle);
    try {
      await pdfService.rotateImage(widget.imageId, rotationAngleStream.value);
    } catch (error, stacktrace) {
      print(stacktrace);
      showServerError(context, error: error);
      throw error;
    }
  }
}
