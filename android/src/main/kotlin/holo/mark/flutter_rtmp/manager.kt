@file:Suppress("DEPRECATION")

package holo.mark.flutter_rtmp

import android.content.Context
import android.hardware.Camera
import android.util.Log
import android.view.View
import com.github.faucamp.simplertmp.RtmpHandler
import holo.mark.flutter_rtmp.FlutterRtmpPlugin.Companion.registrar
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import net.ossrs.yasea.SrsCameraView
import net.ossrs.yasea.SrsCameraView.CameraCallbacksHandler
import net.ossrs.yasea.SrsEncodeHandler
import net.ossrs.yasea.SrsPublisher
import net.ossrs.yasea.SrsRecordHandler
import java.io.IOException
import java.net.SocketException

class RtmpFactory : PlatformViewFactory(StandardMessageCodec()) {
    override fun create(context: Context?, viewId: Int, args: Any?): PlatformView {
        return RtmpView(context)
    }
}

class RtmpView(private var context: Context?) : PlatformView {
    private var manager: RtmpManager? = null

    override fun dispose() {
        if (manager != null) {
            manager?.dispose()
            manager = null
        }
    }

    override fun getView(): View {
        if (manager == null) {
            manager = RtmpManager(context)
        }
        return manager?.getView() ?: View(context)
    }
}

class RtmpManager(context: Context?) : MethodChannel.MethodCallHandler,
        SrsEncodeHandler.SrsEncodeListener, RtmpHandler.RtmpListener,
        SrsRecordHandler.SrsRecordListener, EventChannel.StreamHandler {

    private lateinit var channelResult: MethodChannel.Result
    private var cameraView: SrsCameraView?
    private lateinit var publisher: SrsPublisher
    private var context: Context? = null
    private var logger: RtmpLoger = RtmpLoger()
    private var hasConfig: Boolean = false
    private var eventsStream: EventChannel.EventSink? = null
    private val listeners: Map<Object, Runnable> = HashMap()

    init {
        this.context = context
        cameraView = SrsCameraView(context)
        cameraView?.cameraId = 1
        initPublisher()
        MethodChannel(registrar.messenger(), DEF_CAMERA_SETTING_CONFIG)
                .setMethodCallHandler(this)
        EventChannel(registrar.messenger(), DEF_ERROR_EVENTS).setStreamHandler(this)
    }

    private fun initPublisher() {
        publisher = SrsPublisher(cameraView)
        publisher.setEncodeHandler(SrsEncodeHandler(this))
        publisher.setRtmpHandler(RtmpHandler(this))
        publisher.setRecordHandler(SrsRecordHandler(this))
        publisher.setPreviewResolution(1280, 720)
        publisher.setOutputResolution(360, 640)
        publisher.setVideoHDMode()
        publisher.startCamera()

        cameraView?.setCameraCallbacksHandler(object : CameraCallbacksHandler() {
            @Suppress("DEPRECATION")
            override fun onCameraParameters(params: Camera.Parameters) {
                //params.setFocusMode("custom-focus");                
                //params.setWhiteBalance("custom-balance");
                //etc...
            }
        })

    }

    fun getView(): View {
        if (cameraView == null) {
            initPublisher()
        }
        stopAction()
        hasConfig = false
        logger.state = RTMP_STATUE_Refresh
        publisher.startCamera()
        return cameraView!!
    }

    fun dispose() {
        stopAction()
        cameraView = null
    }

    private fun stopAction(): Boolean {
        try {
            publisher.stopRecord()
            publisher.stopPublish()
            publisher.startCamera()

        } catch (e: Exception) {
            Log.e(TAG, "[ RTMP ] stop error : $e")
            return false
        }
        return true
    }

    private fun previewAction(): Boolean {
        return try {
            cameraView?.invalidate()
            publisher.startCamera()
            true
        } catch (e: Exception) {
            false
        }
    }

    private fun publishAction(): Boolean {
        try {
            if (!previewAction()) {
                return false
            }
            publisher.startPublish(logger.rtmpUrl)
        } catch (e: Exception) {
            return false
        }
        return true
    }

    private fun switchCameraAction(): Boolean {
        try {
            var cameraId = publisher.cameraId
            cameraId = if (cameraId == 0) {
                1
            } else {
                0
            }
            publisher.switchCameraFace(cameraId)

        } catch (e: Exception) {
            return false
        }
        return true
    }

    private fun startLive(param: Map<String, String>) {
        val url: String? = param["url"]
        if (url == null) {
            channelResult.success(Response().failure("address is unavailable"))
        }
        logger.rtmpUrl = url ?: ""
        try {
            if (publishAction()) {
                channelResult.success(Response().succeessful())
            } else {
                channelResult.success(Response().failure("Live streaming start error"))
            }

        } catch (e: Exception) {
            channelResult.success(Response().failure(e.toString()))
        }
    }

    private fun stopLive() {
        if (stopAction()) {
            channelResult.success(Response().succeessful())
        } else {
            channelResult.success(Response().failure(""))
        }
    }

    private fun getCameraRatio() {
        val res: MutableMap<String, Any> = Response().succeessful()
        channelResult.success(res)
    }

    private fun switchCamera() {
        if (switchCameraAction()) {
            channelResult.success(Response().succeessful())
        } else {
            channelResult.success(Response().failure(""))
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        channelResult = result
        @Suppress("UNCHECKED_CAST")
        val param: Map<String, Any> = call.arguments as Map<String, Any>
        when (call.method) {
            "startLive" -> {
                @Suppress("UNCHECKED_CAST")
                startLive(param as Map<String, String>)
            }
            "initConfig" -> {
                channelResult.success(Response().failure("not implemented on android"))
            }
            "startCamera" -> {
                startCamera()
            }
            "stopLive" -> {
                stopLive()
            }
            "rotateCamera" -> {
            }
            "dispose" -> {
                dispose()
                channelResult.success(Response().succeessful())
            }
            "cameraRatio" -> {
                getCameraRatio()
            }
            "switchCamera" -> {
                switchCamera()
            }
            else -> {
                channelResult.notImplemented()
            }
        }
    }

    private fun startCamera() {
        if (previewAction()) {
            channelResult.success(Response().succeessful())
        } else {
            channelResult.success(Response().failure("Couldn't start camera"))
        }
    }

    override fun onEncodeIllegalArgumentException(e: IllegalArgumentException?) {
        handleException(e)
    }

    override fun onNetworkWeak() {
        logMessage(WEAK_NETWORK_ERROR_CODE, "Poor Network Connection")
    }

    override fun onNetworkResume() {
        logMessage(STREAM_GENERIC_ERROR_CDDE, "Network established")
    }

    private fun handleException(exception: Exception?) {
        try {
            publisher.stopRecord()
            publisher.stopPublish()
            eventsStream?.success(ErrorResponse().builder(STREAM_ERROR_HAPPENED_CODE, exception?.message))
        } catch (error: Exception) {
//            eventsStream?.success(ErrorResponse().builder(STREAM_ERROR_HAPPENED_CODE, error.message))
        }
    }

    override fun onRtmpConnected(message: String?) {
        logMessage(RTMP_CONNECTED_CODE, message)
    }

    override fun onRtmpIllegalStateException(e: IllegalStateException?) {
        handleException(e)
    }

    override fun onRtmpStopped() {
        logMessage(STREAM_STOPPED_CODE, "STREAM STOPPED")
    }

    override fun onRtmpIOException(e: IOException?) {
        handleException(e)
    }

    override fun onRtmpAudioStreaming() {
    }

    override fun onRtmpSocketException(e: SocketException?) {
        handleException(e)
    }

    override fun onRtmpDisconnected() {
        logMessage(RTMP_DISCONNECTED_CODE, "Disconnected")
    }

    override fun onRtmpVideoFpsChanged(fps: Double) {
    }

    override fun onRtmpConnecting(message: String?) {
        message?.let { logMessage(RTMP_CONNECTING_CODE, it) }
    }

    override fun onRtmpVideoStreaming() {
    }

    override fun onRtmpAudioBitrateChanged(bitrate: Double) {

    }

    override fun onRtmpVideoBitrateChanged(bitrate: Double) {

    }

    override fun onRtmpIllegalArgumentException(e: IllegalArgumentException?) {
        handleException(e)
    }

    private fun logMessage(code: String, message: String?) {
        eventsStream?.success(ErrorResponse().builder(code, message))
    }

    companion object {
        const val TAG = "RtmpManager"
    }

    override fun onRecordIOException(e: IOException?) {
        handleException(e)
    }

    override fun onRecordIllegalArgumentException(e: IllegalArgumentException?) {
        handleException(e)
    }

    override fun onRecordFinished(p0: String?) {
        logMessage(RTMP_FINISHED_CODE, "Recording finished")
    }

    override fun onRecordPause() {
        logMessage(RTMP_PAUSED_CODE, "Recording paused")
    }

    override fun onRecordResume() {
        logMessage(RTMP_RESUMED_CODE, "Recording resumed")
    }

    override fun onRecordStarted(message: String?) {
        logMessage(RTMP_STARTED_CODE, "Recording started")
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventsStream = events
    }

    override fun onCancel(arguments: Any?) {
    }

}

