package holo.mark.flutter_rtmp


import android.app.Activity
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodChannel


class FlutterRtmpPlugin : FlutterPlugin, ActivityAware {

    private lateinit var channel: MethodChannel
    private var activity: Activity? = null


    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        binding
                .platformViewRegistry
                .registerViewFactory(DEF_CAMERA_RTMP_VIEW, RtmpFactory(binding))
    }


    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {


    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        this.activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        TODO("Not yet implemented")
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        TODO("Not yet implemented")
    }

    override fun onDetachedFromActivity() {
        TODO("Not yet implemented")
    }


}


