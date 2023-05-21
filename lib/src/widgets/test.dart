import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mon application',
      home: MonWidget(callback: () {
        print('Callback appelé depuis MonWidget');
      }),
    );
  }
}

class MonWidget extends StatelessWidget {
  final void Function() callback;

  MonWidget({required this.callback});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mon Widget'),
      ),
      body: Center(
        child: ElevatedButton(
          child: Text('Appeler le callback'),
          onPressed: callback,
        ),
      ),
    );
  }
}
