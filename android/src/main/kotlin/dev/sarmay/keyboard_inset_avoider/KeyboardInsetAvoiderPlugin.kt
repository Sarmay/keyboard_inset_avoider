package dev.sarmay.keyboard_inset_avoider

import android.app.Activity
import android.graphics.Rect
import android.view.View
import android.view.ViewTreeObserver
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel

class KeyboardInsetAvoiderPlugin :
    FlutterPlugin,
    ActivityAware,
    EventChannel.StreamHandler {
    private lateinit var channel: EventChannel
    private var activity: Activity? = null
    private var observedRootView: View? = null
    private var keyboardLayoutListener: ViewTreeObserver.OnGlobalLayoutListener? = null
    private var eventSink: EventChannel.EventSink? = null
    private var lastInsetDp: Double? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = EventChannel(
            binding.binaryMessenger,
            "keyboard_inset_avoider/keyboard_insets",
        )
        channel.setStreamHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        stopKeyboardInsetListener()
        channel.setStreamHandler(null)
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        eventSink = events
        startKeyboardInsetListener()
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
        stopKeyboardInsetListener()
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        startKeyboardInsetListener()
    }

    override fun onDetachedFromActivityForConfigChanges() {
        detachFromActivity()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivity() {
        detachFromActivity()
    }

    private fun detachFromActivity() {
        stopKeyboardInsetListener()
        activity = null
    }

    private fun startKeyboardInsetListener() {
        if (keyboardLayoutListener != null || eventSink == null) {
            return
        }

        val rootView = activity?.window?.decorView?.rootView ?: return
        observedRootView = rootView
        val keyboardThresholdPx = (80 * rootView.resources.displayMetrics.density).toInt()

        keyboardLayoutListener = ViewTreeObserver.OnGlobalLayoutListener {
            val visibleFrame = Rect()
            rootView.getWindowVisibleDisplayFrame(visibleFrame)

            val keyboardHeightPx = (rootView.height - visibleFrame.bottom).coerceAtLeast(0)
            val insetDp = if (keyboardHeightPx > keyboardThresholdPx) {
                keyboardHeightPx / rootView.resources.displayMetrics.density.toDouble()
            } else {
                0.0
            }

            if (lastInsetDp != insetDp) {
                lastInsetDp = insetDp
                eventSink?.success(insetDp)
            }
        }

        rootView.viewTreeObserver.addOnGlobalLayoutListener(keyboardLayoutListener)
        rootView.post { keyboardLayoutListener?.onGlobalLayout() }
    }

    private fun stopKeyboardInsetListener() {
        val rootView = observedRootView
        val listener = keyboardLayoutListener
        if (rootView != null && listener != null && rootView.viewTreeObserver.isAlive) {
            rootView.viewTreeObserver.removeOnGlobalLayoutListener(listener)
        }

        observedRootView = null
        keyboardLayoutListener = null
        lastInsetDp = null
    }
}
