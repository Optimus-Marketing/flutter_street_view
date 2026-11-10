package zyz.flutter.plugin.flutter_google_street_view

import android.content.Context
import android.view.View
import android.view.ViewGroup
import androidx.lifecycle.DefaultLifecycleObserver
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleOwner
import com.google.android.gms.maps.StreetViewPanorama
import com.google.android.gms.maps.StreetViewPanoramaView
import com.google.android.gms.maps.model.LatLng
import com.google.android.gms.maps.model.StreetViewPanoramaCamera
import com.google.android.gms.maps.model.StreetViewPanoramaLocation
import com.google.android.gms.maps.model.StreetViewPanoramaOrientation
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView

internal class StreetViewPlatformView(
    context: Context,
    viewId: Int,
    private val creationParams: Map<*, *>,
    messenger: BinaryMessenger,
    private val pool: StreetViewPool,
    private val lifecycle: Lifecycle?,
) : PlatformView, DefaultLifecycleObserver, MethodChannel.MethodCallHandler {

    private val methodChannel = MethodChannel(messenger, "flutter_google_street_view_$viewId")
    private val streetView: StreetViewPanoramaView
    private val isReusedView: Boolean
    private var panorama: StreetViewPanorama? = null
    private var pendingReadyResult: MethodChannel.Result? = null
    private var isReady = false
    private var isDisposed = false
    private var isStreetViewDestroyed = false
    private var noPanoramaMessage = "No panorama found"
    private var sendsCameraChanges = false
    private var sendsPanoramaChanges = false
    private var sendsPanoramaClicks = false
    private var sendsPanoramaLongClicks = false

    init {
        val idleView = pool.reuse()
        isReusedView = idleView != null
        streetView = idleView ?: pool.create(context, creationParams.toPanoramaOptions())
        rememberRequestedLocation(creationParams)
        rememberListeners(creationParams)
        methodChannel.setMethodCallHandler(this)
        lifecycle?.addObserver(this)
        streetView.getStreetViewPanoramaAsync(::onPanoramaReady)
    }

    override fun getView(): View = streetView

    override fun dispose() {
        if (isDisposed) return
        isDisposed = true
        methodChannel.setMethodCallHandler(null)
        pendingReadyResult?.success(null)
        pendingReadyResult = null
        lifecycle?.removeObserver(this)
        if (!isStreetViewDestroyed) recycleStreetView()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val panorama = panorama
        if (call.method == "streetView#waitForStreetView") {
            if (isReady && panorama != null) result.success(readyState(panorama)) else pendingReadyResult = result
            return
        }
        if (panorama == null) {
            result.error("not_ready", "${call.method} was called before the street view was ready", null)
            return
        }
        val arguments = call.arguments as? Map<*, *> ?: emptyMap<String, Any>()
        when (call.method) {
            "streetView#updateOptions" -> {
                applyOptions(panorama, arguments)
                result.success(null)
            }
            "streetView#animateTo" -> {
                panorama.animateTo(panorama.cameraWith(arguments), arguments.long("duration") ?: 0L)
                result.success(null)
            }
            "streetView#getLocation" -> result.success(panorama.location?.toMap())
            "streetView#getPanoramaCamera" -> result.success(panorama.panoramaCamera.toMap())
            "streetView#orientationToPoint" ->
                result.success(panorama.orientationToPoint(arguments.toOrientation())?.toMap())
            "streetView#pointToOrientation" ->
                result.success(panorama.pointToOrientation(arguments.toPoint())?.toMap())
            else -> result.notImplemented()
        }
    }

    override fun onCreate(owner: LifecycleOwner) {
        if (!isReusedView) streetView.onCreate(null)
    }

    override fun onStart(owner: LifecycleOwner) = streetView.onStart()

    override fun onResume(owner: LifecycleOwner) = streetView.onResume()

    override fun onPause(owner: LifecycleOwner) = streetView.onPause()

    override fun onStop(owner: LifecycleOwner) = streetView.onStop()

    override fun onDestroy(owner: LifecycleOwner) {
        owner.lifecycle.removeObserver(this)
        isStreetViewDestroyed = true
        pool.destroy(streetView)
    }

    private fun onCameraChange(camera: StreetViewPanoramaCamera) {
        if (sendsCameraChanges) methodChannel.invokeMethod("camera#onChange", camera.toMap())
    }

    private fun onPanoramaChange(location: StreetViewPanoramaLocation?) {
        panorama?.let(::markReady)
        if (!sendsPanoramaChanges) return
        val arguments = if (location?.panoId == null) mapOf("error" to noPanoramaMessage) else location.toMap()
        methodChannel.invokeMethod("pano#onChange", arguments)
    }

    private fun onPanoramaClick(orientation: StreetViewPanoramaOrientation) {
        if (sendsPanoramaClicks) methodChannel.invokeMethod("pano#onClick", clickArguments(orientation))
    }

    private fun onPanoramaLongClick(orientation: StreetViewPanoramaOrientation) {
        if (sendsPanoramaLongClicks) methodChannel.invokeMethod("pano#onLongClick", clickArguments(orientation))
    }

    private fun onPanoramaReady(panorama: StreetViewPanorama) {
        if (isDisposed) return
        this.panorama = panorama
        listenTo(panorama)
        if (isReusedView) applyOptions(panorama, creationParams)
        if (isReusedView || !creationParams.hasLocation()) markReady(panorama)
    }

    private fun markReady(panorama: StreetViewPanorama) {
        if (isReady) return
        isReady = true
        pendingReadyResult?.success(readyState(panorama))
        pendingReadyResult = null
    }

    private fun readyState(panorama: StreetViewPanorama) = mapOf(
        "panningGesturesEnabled" to panorama.isPanningGesturesEnabled,
        "streetNamesEnabled" to panorama.isStreetNamesEnabled,
        "userNavigationEnabled" to panorama.isUserNavigationEnabled,
        "zoomGesturesEnabled" to panorama.isZoomGesturesEnabled,
        "streetViewCount" to pool.viewCount,
    )

    private fun applyOptions(panorama: StreetViewPanorama, options: Map<*, *>) {
        rememberListeners(options)
        options.boolean("panningGesturesEnabled")?.let { panorama.isPanningGesturesEnabled = it }
        options.boolean("streetNamesEnabled")?.let { panorama.isStreetNamesEnabled = it }
        options.boolean("userNavigationEnabled")?.let { panorama.isUserNavigationEnabled = it }
        options.boolean("zoomGesturesEnabled")?.let { panorama.isZoomGesturesEnabled = it }
        moveTo(panorama, options)
        if (options.hasCamera()) panorama.animateTo(panorama.cameraWith(options), INSTANT_ANIMATION_MS)
    }

    private fun moveTo(panorama: StreetViewPanorama, options: Map<*, *>) {
        rememberRequestedLocation(options)
        val panoId = options.string("panoId")
        val position = options.latLng("position")
        val radius = options.int("radius")
        when {
            panoId != null -> panorama.setPosition(panoId)
            position != null && radius != null -> panorama.setPosition(position, radius, options.streetViewSource())
            position != null -> panorama.setPosition(position, options.streetViewSource())
        }
    }

    private fun rememberRequestedLocation(options: Map<*, *>) {
        val panoId = options.string("panoId")
        val position = options.latLng("position")
        noPanoramaMessage = when {
            panoId != null -> "No panorama found with id $panoId"
            position != null -> "No panorama found near ${position.latitude}, ${position.longitude}"
            else -> return
        }
    }

    private fun rememberListeners(options: Map<*, *>) {
        options.boolean("hasCameraChangeListener")?.let { sendsCameraChanges = it }
        options.boolean("hasPanoramaChangeListener")?.let { sendsPanoramaChanges = it }
        options.boolean("hasPanoramaClickListener")?.let { sendsPanoramaClicks = it }
        options.boolean("hasPanoramaLongClickListener")?.let { sendsPanoramaLongClicks = it }
    }

    private fun clickArguments(orientation: StreetViewPanoramaOrientation): Map<String, Any> {
        val point = panorama?.orientationToPoint(orientation)?.toMap().orEmpty()
        return orientation.toMap() + point
    }

    private fun recycleStreetView() {
        panorama?.let(::resetForReuse)
        streetView.onPause()
        streetView.onStop()
        (streetView.parent as? ViewGroup)?.removeView(streetView)
        pool.recycle(streetView)
    }

    private fun resetForReuse(panorama: StreetViewPanorama) {
        stopListeningTo(panorama)
        panorama.isPanningGesturesEnabled = true
        panorama.isStreetNamesEnabled = true
        panorama.isUserNavigationEnabled = true
        panorama.isZoomGesturesEnabled = true
        panorama.animateTo(StreetViewPanoramaCamera(0f, 0f, 0f), INSTANT_ANIMATION_MS)
        panorama.setPosition(LOCATION_WITHOUT_PANORAMA)
    }

    private fun listenTo(panorama: StreetViewPanorama) {
        panorama.setOnStreetViewPanoramaCameraChangeListener { onCameraChange(it) }
        panorama.setOnStreetViewPanoramaChangeListener { location: StreetViewPanoramaLocation? -> onPanoramaChange(location) }
        panorama.setOnStreetViewPanoramaClickListener { onPanoramaClick(it) }
        panorama.setOnStreetViewPanoramaLongClickListener { onPanoramaLongClick(it) }
    }

    private fun stopListeningTo(panorama: StreetViewPanorama) {
        panorama.setOnStreetViewPanoramaCameraChangeListener(null)
        panorama.setOnStreetViewPanoramaChangeListener(null)
        panorama.setOnStreetViewPanoramaClickListener(null)
        panorama.setOnStreetViewPanoramaLongClickListener(null)
    }

    private companion object {
        const val INSTANT_ANIMATION_MS = 1L
        val LOCATION_WITHOUT_PANORAMA = LatLng(-45.125783, 151.276417)
    }
}
