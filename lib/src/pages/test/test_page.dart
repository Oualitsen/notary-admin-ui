import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/animation/animation_controller.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/ticker_provider.dart';
import 'package:jsaver/_web/jSaver_web.dart';
import 'package:jsaver/jSaver.dart';
import 'dart:io';

class TestArchving extends StatefulWidget {
  const TestArchving({super.key});

  @override
  State<TestArchving> createState() => _TestArchvingState();
}

class _TestArchvingState extends State<TestArchving>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        child: Text("archive"),
        onPressed: () async {
          List<int>? bytes;
          ZipEncoder encoder = ZipEncoder();
          Archive archive = Archive();

          OutputStream outputStream = OutputStream(
            byteOrder: LITTLE_ENDIAN,
          );

          var res = "test" as InputStream;
          ArchiveFile archiveFiles = ArchiveFile.stream("name.txt", 4, res);

          bytes = encoder.encode(
            archive,
            level: Deflate.BEST_COMPRESSION,
            modified: DateTime.now(),
            output: outputStream,
          );

          final _jSaverPlugin = JSaverWeb();

          Future<String> saveFromData(
              Uint8List data, String fileName, JSaverFileType type) async {
            //Note: File Name Must Contain extension
            final value =
                await _jSaverPlugin.saveFromData(data: data, name: fileName);
            return value;
          }

          saveFromData(
              Uint8List.fromList(bytes!), 'test.zip', JSaverFileType.ZIP);
        },
      ),
    );
  }
}
