import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:permission_handler/permission_handler.dart';
import 'advertising.dart' as advertising;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterBackgroundService.initialize(onStart, autoStart: false); // TODO: autoStart = false が効かない？

  runApp(MyApp());
}

void onStart() {
  WidgetsFlutterBinding.ensureInitialized();
  final service = FlutterBackgroundService();
  service.onDataReceived.listen((event) {
    if (event != null && event["action"] == "stop") {
      service.stopBackgroundService();
      print('Stop the background service');
    }
  });

  service.setForegroundMode(false);
  Timer.periodic(Duration(seconds: 40), (timer) async {
    if (!(await service.isServiceRunning())) {
      timer.cancel();
      print('Stop the timer');
    }

    FlutterBlue blue = FlutterBlue.instance;
    blue.startScan(timeout: Duration(seconds: 10));
    print('Start BLE device scanning');
    blue.scanResults.listen((results) {
      var found = false;
      for (ScanResult result in results) {
        final ad = advertising.parse(result);
        if (ad != null) {
          print('[BG] found: ${ad.data}');
          service.sendData(
            {"device": ad.data.toString()},
          );
          found = true;
        }
      }
      if (!found) {
        service.sendData(
          {"device": "not found"},
        );
      }
    });
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
  final _service = FlutterBackgroundService();
  String _buttonText = "Start";

  Future<bool> _switchService() async {
    final isRunning = await _service.isServiceRunning();
    if (isRunning) {
      _service.sendData(
        {"action": "stop"},
      );
    } else {
      FlutterBackgroundService.initialize(onStart);
    }
    return !isRunning;
  }

  String _getServiceDataAsString(Map<String, dynamic> data) {
    String? device = data["device"];
    return device.toString();
  }

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  _checkPermission() async {
    final status = await Permission.location.status;
    if (status.isDenied || status.isRestricted) {
      await Permission.location.request();
    }
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
              stream: _service.onDataReceived,
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
                final isRunning = await _switchService();
                setState(() {
                  if (isRunning) {
                    _buttonText = 'Stop';
                  } else {
                    _buttonText = 'Start';
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
