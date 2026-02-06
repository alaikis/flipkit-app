package com.alaikis.flipkit

import android.os.Bundle
import androidx.multidex.MultiDex
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        GeneratedPluginRegistrant.registerWith(flutterEngine)
    }

    override fun attachBaseContext(base: android.content.Context) {
        super.attachBaseContext(base)
        try {
            MultiDex.install(this)
        } catch (e: Exception) {
            println("MultiDex install failed: ${e.message}")
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Thread.setDefaultUncaughtExceptionHandler { thread, throwable ->
            println("Uncaught exception in thread ${thread.name}: $throwable")
            throwable.printStackTrace()
        }
    }
}
