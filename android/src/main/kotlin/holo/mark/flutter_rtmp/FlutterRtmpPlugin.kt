package holo.mark.flutter_rtmp

import io.flutter.plugin.common.PluginRegistry.Registrar

class FlutterRtmpPlugin  {


    companion object {
        lateinit var registrar: Registrar

        @JvmStatic
        fun registerWith(registrar: Registrar) {

            FlutterRtmpPlugin.registrar = registrar

            registrar.platformViewRegistry().registerViewFactory(DEF_CAMERA_RTMP_VIEW, RtmpFactory())


        }
    }

}
