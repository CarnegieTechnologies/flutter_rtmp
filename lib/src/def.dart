/*
* Copyright 2019 mark , All right reserved
* author : mark
* date : 2019-11-05
* ide : VSCode
*/

/// 状态回调
const String DEF_CAMERA_STATUE_CALLBACK = "holo#livingStatueCallback";

/// 视图id
const String DEF_CAMERA_RTMP_VIEW = "holo#cameraRtmpView";

/// 配置方法
const String DEF_CAMERA_SETTING_CONFIG = "holo#cameraSettingConfig";

const String STREAM_GENERIC_ERROR_CDDE = "900";
const String WEAK_NETWORK_ERROR_CODE = "901";
const String WEAK_NETWORK_RESOLVED_CODE = "902";
const String STREAM_STOPPED_CODE = "903";
const String RTMP_CONNECTING_CODE = "904";
const String RTMP_CONNECTED_CODE = "905";
const String RTMP_DISCONNECTED_CODE = "906";
const String RTMP_STARTED_CODE = "907";
const String RTMP_STOPEED_CODE = "908";
const String RTMP_PAUSED_CODE = "909";
const String RTMP_RESUMED_CODE = "910";
const String RTMP_FINISHED_CODE = "911";
const String STREAM_ERROR_HAPPENED_CODE = "913";

enum RtmpStatue {
  preparing,
  failed,
  living,
  pause,
  resume,
  stop,
}
