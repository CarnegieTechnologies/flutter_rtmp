package holo.mark.flutter_rtmp


// 状态回调
var DEF_CAMERA_STATUE_CALLBACK = "holo#livingStatueCallback"

/// 视图id
var DEF_CAMERA_RTMP_VIEW = "holo#cameraRtmpView"

/// 配置方法
var DEF_CAMERA_SETTING_CONFIG = "holo#cameraSettingConfig"
var DEF_ERROR_EVENTS = "error_events"


var PKG_NAME = "hv.rtmp"

var STREAM_GENERIC_ERROR_CDDE = "900"
var WEAK_NETWORK_ERROR_CODE = "901"
var WEAK_NETWORK_RESOLVED_CODE = "902"
var STREAM_STOPPED_CODE = "903"
var RTMP_CONNECTING_CODE = "904"
var RTMP_CONNECTED_CODE = "905"
var RTMP_DISCONNECTED_CODE = "906"
var RTMP_STARTED_CODE = "907"
var RTMP_STOPEED_CODE = "908"
var RTMP_PAUSED_CODE = "909"
var RTMP_RESUMED_CODE = "910"
var RTMP_FINISHED_CODE = "911"
var STREAM_ERROR_HAPPENED_CODE = "913"

// --------------  连接状态 --------------
/// 准备中
var RTMP_STATUE_Preparing = 0
/// 准备结束
var RTMP_STATUE_Ready = -1
/// 连接中
var RTMP_STATUE_Pending = 1
/// 已连接
var RTMP_STATUE_Pushing = 2
/// 已断开
var RTMP_STATUE_Stop = 3
/// 连接出错
var RTMP_STATUE_Error = 4
///  正在刷新
var RTMP_STATUE_Refresh = 5