import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_rtmp/flutter_rtmp.dart';
import 'package:screen/screen.dart';

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
  RtmpManager rtmpManager;
  int count = 0;
  Timer _timer;
  String rtmpUrl =
      "rtmp://34.243.51.176:1935/livestream/5ee89f5e-8468-11ea-bb7e-1b7127419aaa";

  @override
  void initState() {
    rtmpManager = RtmpManager(onCreated: () {
      print("--- view did created ---");
    });
    super.initState();
    Screen.keepOn(true);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (AppLifecycleState.inactive == state) {
      rtmpManager.stopLiveStream();
    }
    if (AppLifecycleState.paused == state) {
      Screen.keepOn(false);
      rtmpManager.stopLiveStream();
    }
    if (AppLifecycleState.resumed == state) {
      Screen.keepOn(true);
      rtmpManager.startCamera();
    }
  }

  @override
  Future<void> dispose() async {
    Screen.keepOn(false);
    WidgetsBinding.instance.removeObserver(this);
    rtmpManager.dispose();
    rtmpManager = null;
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
              ),
              Container(
                padding: EdgeInsets.only(top: 20),
                alignment: Alignment.topLeft,
                child: Row(
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.play_arrow),
                      onPressed: () {
                        rtmpManager.startLiveStream(url: rtmpUrl);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.pause),
                      onPressed: () {
                        rtmpManager.stopLiveStream();
                        if (_timer != null) {
                          _timer.cancel();
                          _timer = null;
                        }
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
}
