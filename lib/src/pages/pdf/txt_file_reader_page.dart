import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http_error_handler/error_handler.dart';
import 'package:notary_admin/src/db_services/token_db_service.dart';
import 'package:notary_admin/src/utils/widget_mixin_new.dart';
import 'package:notary_admin/src/utils/widget_utils.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:rxdart/src/subjects/subject.dart';

class MyByteFileReader extends StatefulWidget {
  final Uint8List bytes;
  final String title;
  const MyByteFileReader({Key? key, required this.bytes, required this.title})
      : super(key: key);

  @override
  _MyByteFileReaderState createState() => _MyByteFileReaderState();
}

class _MyByteFileReaderState extends BasicState<MyByteFileReader> {
  late List<String> lines;
  final tokenService = GetIt.instance.get<TokenDbService>();

  @override
  void initState() {
    super.initState();
    final decodedContent = utf8.decode(widget.bytes);
    lines = LineSplitter().convert(decodedContent);
  }

  @override
  Widget build(BuildContext context) {
    return WidgetUtils.wrapRoute(
      (context, type) => Scaffold(
        appBar: AppBar(
          title: Text("${widget.title}"),
          actions: [
            ElevatedButton.icon(
              onPressed: download,
              label: Text(lang.download),
              icon: Icon(Icons.download),
            ),
          ],
        ),
        body: ListView.builder(
          itemCount: lines.length,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Center(child: Text(lines[index])),
            );
          },
        ),
      ),
    );
  }

  Future download() async {
    try {
      String? authToken = await tokenService.getToken();
      WidgetMixin.download(context, "", widget.title, widget.bytes, authToken);
    } catch (error, stacktrace) {
      print(stacktrace);
      showServerError(context, error: error);
      throw error;
    }
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
}
