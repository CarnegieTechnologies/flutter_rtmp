/*
* Copyright 2019 mark , All right reserved
* author : mark
* date : 2019-11-05
* ide : VSCode
*/

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rtmp/src/def.dart';
import 'package:permission_handler/permission_handler.dart';

import 'models/models.dart';

typedef void RTMPListener(dynamic msg);

/// 直播控制器
class RtmpManager {
  RtmpManager({this.onCreated});

  /// 视图加载回调,
  final VoidCallback onCreated;

  /// 配置
  MethodChannel _configChannel = MethodChannel(DEF_CAMERA_SETTING_CONFIG);
  EventChannel _channel = EventChannel('error_events');

  /// premission state
  bool _permissionEnable;

  bool get permissionEnable => _permissionEnable ?? false;

  /// permission check
  Future<bool> permissionCheck() async {
    List<Permission> requestPermission = [];

    /// 摄像机
    if (await Permission.camera.request().isGranted) {
      requestPermission.add(Permission.camera);
    }

    /// 文件读写
    if (await Permission.storage.request().isGranted) {
      if (defaultTargetPlatform == TargetPlatform.android)
        requestPermission.add(Permission.storage);
    }

    /// 麦克风
    if (await Permission.microphone.request().isGranted) {
      requestPermission.add(Permission.microphone);
    }

    if (requestPermission.length > 0) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.location,
        Permission.storage,
      ].request();

      bool enable = true;
      statuses.forEach((var p, PermissionStatus status) {
        if (status != PermissionStatus.granted) {
          enable = false;
          return;
        }
      });
      _permissionEnable = enable;
      return _permissionEnable;
    } else {
      _permissionEnable = true;
      return _permissionEnable;
    }
  }

  /// 配置
  final RtmpConfig config = RtmpConfig();

  /// 直播状态
  RtmpStatue _statue = RtmpStatue.preparing;

  Future<RtmpResponse> _didCreated() async {
    if (_statue != RtmpStatue.preparing) return RtmpResponse.faile();
    Map res;
    try {
      res = await _configChannel.invokeMethod("initConfig", config.toMap());
    } catch (e) {}

    if (onCreated != null) onCreated();
    return RtmpResponse.fromData(res ?? {});
  }

  /// 开始直播
  Future<RtmpResponse> startLiveStream(
      {@required String url, @required RTMPListener listener}) async {
    if (_statue == RtmpStatue.living) return RtmpResponse.succeed();
    RtmpResponse res = RtmpResponse.fromData(
        await _configChannel.invokeMethod("startLive", {"url": url}));
    if (res.isOk) {
      _statue = RtmpStatue.living;
    }
    _channel.receiveBroadcastStream().listen(listener, cancelOnError: true);
    return res;
  }

  /// 停止直播
  Future<RtmpResponse> stopLiveStream() async {
    if (_statue == RtmpStatue.pause || _statue == RtmpStatue.stop)
      return RtmpResponse.succeed();
    RtmpResponse res = RtmpResponse.fromData(
        await _configChannel.invokeMethod("stopLive", {}));
    if (res.isOk) {
      _statue = RtmpStatue.stop;
    }
    return res;
  }

  /// destroy
  Future<RtmpResponse> dispose() async {
    _platformView = null;
    _globalKey = null;
    return RtmpResponse.fromData(
        await _configChannel.invokeMethod("dispose", {}));
  }

  ///切换摄像头
  Future<RtmpResponse> switchCamera() async {
    return RtmpResponse.fromData(
        await _configChannel.invokeMethod("switchCamera", {}));
  }

  Future<RtmpResponse> startCamera() async {
    return RtmpResponse.fromData(
        await _configChannel.invokeMethod("startCamera", {}));
  }

  /// 获取摄像头分辨率
  @deprecated
  Future<double> cameraRatio() async {
    try {
      RtmpResponse res = RtmpResponse.fromData(
          await _configChannel.invokeMethod("cameraRatio", {}));
      if (res.isOk) {
        String ratio = res.oridata['ratio'];
        double width = double.parse(ratio.split("*")[1]);
        double height = double.parse(ratio.split("*")[0]);
        return width / height;
      } else {
        return null;
      }
    } catch (Exception) {
      return null;
    }
  }

  GlobalKey _globalKey = GlobalKey();
  Widget _platformView;

  Widget view() {
    if (_platformView == null) {
      print("[RTMP] get platformview");
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        _platformView = UiKitView(
          key: _globalKey,
          viewType: DEF_CAMERA_RTMP_VIEW,
          onPlatformViewCreated: (_) {
            _didCreated();
          },
        );
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        _platformView = AndroidView(
          key: _globalKey,
          viewType: DEF_CAMERA_RTMP_VIEW,
          onPlatformViewCreated: (_) {
            _didCreated();
          },
        );
      } else {
        _platformView = Container();
      }
    }
    return Container(
        color: Colors.transparent,
        alignment: Alignment.center,
        child: AspectRatio(
          aspectRatio: 720.0 / 1280,
          child: _platformView,
        ));
  }
}
