import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_rtmp/flutter_rtmp.dart';
import 'package:wakelock/wakelock.dart';

void main() => runApp(FirstScreen());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class FirstScreen extends StatefulWidget {
  @override
  _FState createState() => _FState();
}

class _FState extends State<FirstScreen> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      body: FirstWidget(),
    ));
  }
}

class FirstWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: RaisedButton(
        child: Text('Open stream'),
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (c) => MyApp()));
        },
      ),
    );
  }
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late RtmpManager rtmpManager;
  int count = 0;
  late Timer _timer;
  String rtmpUrl =
      "rtmp://54.77.16.223:1935/livestream/5728c460-aed4-11ea-a626-c30a3c734a38";

  @override
  void initState() {
    rtmpManager = RtmpManager(onCreated: () {
      print("--- view did created ---");
    });
    super.initState();
    Wakelock.enable();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (AppLifecycleState.inactive == state) {
      rtmpManager.stopLiveStream();
    }
    if (AppLifecycleState.paused == state) {
      Wakelock.disable();
      rtmpManager.stopLiveStream();
    }
    if (AppLifecycleState.resumed == state) {
      Wakelock.enable();

      rtmpManager.startCamera();
    }
  }

  @override
  Future<void> dispose() async {
    Wakelock.disable();

    WidgetsBinding.instance!.removeObserver(this);
    rtmpManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              RtmpView(
                manager: rtmpManager,
                errorWidgetBuilder: (BuildContext context) {
                  return Text('Error happened');
                },
              ),
              Container(
                padding: EdgeInsets.only(top: 20),
                alignment: Alignment.topLeft,
                child: Row(
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.play_arrow),
                      onPressed: () {
                        rtmpManager
                            .startLiveStream(
                                url: rtmpUrl,
                                listener: (msg) {
                                  StreamResponseEvent response =
                                      StreamResponseEvent.fromData(msg);
                                  print("DJURO");
                                  print(response.code);
                                  print(response.message);
                                })
                            .then((RtmpResponse value) {})
                            .catchError((dynamic error) {
//                          rtmpManager.stopLiveStream();
                          print('ERROR DURING STREAM $error');
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.pause),
                      onPressed: () {
                        rtmpManager.stopLiveStream();
                        _timer.cancel();
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.stop),
                      onPressed: () {
                        rtmpManager.stopLiveStream();
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.switch_camera),
                      onPressed: () {
                        rtmpManager.switchCamera();
                      },
                    ),
                    Container(
                      child: Text(
                        "${count ~/ 60}:${count % 60}",
                        style: TextStyle(fontSize: 17, color: Colors.blue),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void log(String logString) {
    print('LOG $logString');
  }
}
