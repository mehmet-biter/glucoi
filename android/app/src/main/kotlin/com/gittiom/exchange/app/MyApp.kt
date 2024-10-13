package io.maido.intercomexample

import android.app.Application
import io.maido.intercom.IntercomFlutterPlugin

class MyApp : Application() {
  override fun onCreate() {
    super.onCreate()

    // Initialize the Intercom SDK here also as Android requires to initialize it in the onCreate of the application.
    IntercomFlutterPlugin.initSdk(this, appId = "h39cjt7z", androidApiKey = "android_sdk-1e64080f501a26725d99df85bef650c7ef22a8da")
  }
}
