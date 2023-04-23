import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:notary_admin/src/init.dart';
import 'package:notary_admin/src/services/files/pdf_service.dart';
import 'package:notary_admin/src/widgets/mixins/lang.dart';
import 'dart:math' as math;

class ImageWidget extends StatelessWidget {
  final String imageId;
  final String token;
  final Function(String imageId) onAngleChanged;
  const ImageWidget(
      {super.key,
      required this.imageId,
      required this.token,
      required this.onAngleChanged});

  @override
  Widget build(BuildContext context) {
    var lang = getLang(context);
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
              Container(
                height: 800,
                child: Image.network(
                  getImageUrl(imageId),
                  headers: {"Authorization": "Bearer ${token}"},
                ),
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

  void rotate(bool rotateForward) async {
    var angle = rotateForward ? (math.pi / 2) : (-math.pi / 2);

    try {
      final pdfService = GetIt.instance.get<PdfService>();

      await pdfService.rotateImage(imageId, angle);
      onAngleChanged(imageId);
    } catch (error, stacktrace) {
      print(stacktrace);
      throw error;
    }
  }
}
