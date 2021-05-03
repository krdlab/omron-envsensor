import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterBackgroundService.initialize(onStart);

  runApp(MyApp());
}

void onStart() {
  WidgetsFlutterBinding.ensureInitialized();
  final service = FlutterBackgroundService();
  service.onDataReceived.listen((event) {
    if (event != null && event["action"] == "stop") {
      service.stopBackgroundService();
    }
  });

  service.setForegroundMode(false);
  Timer.periodic(Duration(seconds: 1), (timer) async {
    if (!(await service.isServiceRunning())) {
      timer.cancel();
    }
    service.sendData(
      {"current_date": DateTime.now().toIso8601String()},
    );
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EnvSensor Watcher',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(title: 'Home'),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _buttonText = "Stop";

  Future<bool> _switchService() async {
    var isRunning = await FlutterBackgroundService().isServiceRunning();
    if (isRunning) {
      FlutterBackgroundService().sendData(
        {"action": "stop"},
      );
    } else {
      FlutterBackgroundService.initialize(onStart);
    }
    return !isRunning;
  }

  String _getServiceDataAsString(Map<String, dynamic> data) {
    DateTime? date = DateTime.tryParse(data["current_date"]);
    return date.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title!),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            StreamBuilder<Map<String, dynamic>?>(
              stream: FlutterBackgroundService().onDataReceived,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return Text(_getServiceDataAsString(snapshot.data!));
              },
            ),
            ElevatedButton(
              child: Text(_buttonText),
              onPressed: () async {
                var isRunning = await _switchService();
                if (isRunning) {
                  _buttonText = 'Stop';
                } else {
                  _buttonText = 'Start';
                }
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }
}
