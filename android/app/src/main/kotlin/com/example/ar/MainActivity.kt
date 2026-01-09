package com.example.ar

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import com.example.ar.vuforia.VuforiaPlugin

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Register Vuforia plugin
        flutterEngine.plugins.add(VuforiaPlugin())
    }
}
