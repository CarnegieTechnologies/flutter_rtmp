import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_rtmp/flutter_rtmp.dart';

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

class _MyAppState extends State<MyApp> {
  RtmpManager _manager;
  int count = 0;
  Timer _timer;
  String rtmpUrl = "rtmp://54.76.63.113:1935/livestream/16b7a176-83c8-11ea-8767-4f4b8e85dd39";

  @override
  void initState() {
    _manager = RtmpManager(onCreated: () {
      print("--- view did created ---");
    });
    super.initState();
  }

  @override
  Future<void> dispose() async {
    _manager.dispose();
    _manager = null;
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
                manager: _manager,
              ),
              Container(
                padding: EdgeInsets.only(top: 20),
                alignment: Alignment.topLeft,
                child: Row(
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.play_arrow),
                      onPressed: () {
                        _manager.living(
                            url: rtmpUrl);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.pause),
                      onPressed: () {
                        _manager.pauseLive();
                        if (_timer != null) {
                          _timer.cancel();
                          _timer = null;
                        }
                        ;
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.stop),
                      onPressed: () {
                        _manager.stopLive();
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.switch_camera),
                      onPressed: () {
                        _manager.switchCamera();
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
