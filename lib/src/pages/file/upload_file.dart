import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http_error_handler/error_handler.dart';
import 'package:notary_admin/src/services/upload_service.dart';
import 'package:notary_admin/src/utils/widget_utils.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:rxdart/src/subjects/subject.dart';
import 'package:extended_image_library/extended_image_library.dart';
import 'package:rxdart/rxdart.dart';

class UploadFilePage extends StatefulWidget {
  const UploadFilePage({super.key});

  @override
  State<UploadFilePage> createState() => _UploadFilePageState();
}

class _UploadFilePageState extends BasicState<UploadFilePage>
    with WidgetUtilsMixin {
  final UploadService uploadService = new UploadService(GetIt.instance.get());
  final pathFiles = BehaviorSubject.seeded(<String>[]);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("upload a file"),
        actions: [
          IconButton(
            onPressed: loadFiles,
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: ListView(children: [
        ElevatedButton(
          onPressed: loadFiles,
          child: Text(lang.addFileTitle),
        ),
        StreamBuilder<List<String>>(
            stream: pathFiles,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var data = snapshot.data;
                return Column(
                  children: data!.map((e) {
                    var name = e.split('/').last;
                    return ListTile(
                        leading: CircleAvatar(child: Icon(Icons.file_copy)),
                        title: Text("${name}"),
                        trailing: IconButton(
                            icon: Icon(Icons.cancel),
                            onPressed: () {
                              var list = pathFiles.value;
                              list.remove(e);
                              pathFiles.add(list);
                            }));
                  }).toList(),
                );
              } else {
                return SizedBox.shrink();
              }
            }),
      ]),
      floatingActionButton: wrap(
        getButtons(onSave: save),
      ),
    );
  }

  Future loadFiles() async {
    List<String> extensions = ["docx"];
    try {
      var platformFiles = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowMultiple: false,
          allowedExtensions: extensions);
      if (platformFiles != null) {
        var path = platformFiles.files.first.path;
        if (path != null) {
          var list = pathFiles.value;
          list.add(path);
          pathFiles.add(list);
        }
      }
    } catch (e) {
      print("[ERROR]${e.toString}");
    }
  }

  void save() async {
    try {
      for (String path in pathFiles.value) {
        print(path);
        await uploadService.uploadFileDynamic("/admin/template/upload", path);
      }
      await showSnackBar2(context, lang.createdsuccssfully);
    } catch (error) {
      showServerError(context, error: error);
    }
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
}
