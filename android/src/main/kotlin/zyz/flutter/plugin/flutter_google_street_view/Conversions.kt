package zyz.flutter.plugin.flutter_google_street_view

import android.graphics.Point
import com.google.android.gms.maps.StreetViewPanorama
import com.google.android.gms.maps.StreetViewPanoramaOptions
import com.google.android.gms.maps.model.LatLng
import com.google.android.gms.maps.model.StreetViewPanoramaCamera
import com.google.android.gms.maps.model.StreetViewPanoramaLocation
import com.google.android.gms.maps.model.StreetViewPanoramaOrientation
import com.google.android.gms.maps.model.StreetViewSource

internal fun Map<*, *>.boolean(key: String) = this[key] as? Boolean

internal fun Map<*, *>.string(key: String) = this[key] as? String

internal fun Map<*, *>.int(key: String) = (this[key] as? Number)?.toInt()

internal fun Map<*, *>.long(key: String) = (this[key] as? Number)?.toLong()

internal fun Map<*, *>.float(key: String) = (this[key] as? Number)?.toFloat()

internal fun Map<*, *>.latLng(key: String): LatLng? {
    val (latitude, longitude) = this[key] as? List<*> ?: return null
    return LatLng((latitude as Number).toDouble(), (longitude as Number).toDouble())
}

internal fun Map<*, *>.streetViewSource(): StreetViewSource =
    if (string("source") == "outdoor") StreetViewSource.OUTDOOR else StreetViewSource.DEFAULT

internal fun Map<*, *>.hasLocation() = containsKey("panoId") || containsKey("position")

internal fun Map<*, *>.hasCamera() =
    containsKey("bearing") || containsKey("tilt") || containsKey("zoom")

internal fun Map<*, *>.toOrientation() =
    StreetViewPanoramaOrientation(float("tilt") ?: 0f, float("bearing") ?: 0f)

internal fun Map<*, *>.toPoint() = Point(int("x") ?: 0, int("y") ?: 0)

internal fun Map<*, *>.toPanoramaOptions() = StreetViewPanoramaOptions().apply {
    string("panoId")?.let { panoramaId(it) }
    latLng("position")?.let { position ->
        val radius = int("radius")
        if (radius != null) position(position, radius, streetViewSource())
        else position(position, streetViewSource())
    }
    boolean("panningGesturesEnabled")?.let { panningGesturesEnabled(it) }
    boolean("streetNamesEnabled")?.let { streetNamesEnabled(it) }
    boolean("userNavigationEnabled")?.let { userNavigationEnabled(it) }
    boolean("zoomGesturesEnabled")?.let { zoomGesturesEnabled(it) }
    panoramaCamera(StreetViewPanoramaCamera(float("zoom") ?: 0f, float("tilt") ?: 0f, float("bearing") ?: 0f))
}

internal fun StreetViewPanorama.cameraWith(options: Map<*, *>): StreetViewPanoramaCamera =
    StreetViewPanoramaCamera.builder(panoramaCamera).apply {
        options.float("bearing")?.let { bearing(it) }
        options.float("tilt")?.let { tilt(it) }
        options.float("zoom")?.let { zoom(it) }
    }.build()

internal fun StreetViewPanoramaCamera.toMap() = mapOf("bearing" to bearing, "tilt" to tilt, "zoom" to zoom)

internal fun StreetViewPanoramaOrientation.toMap() = mapOf("bearing" to bearing, "tilt" to tilt)

internal fun Point.toMap() = mapOf("x" to x, "y" to y)

internal fun StreetViewPanoramaLocation.toMap() = mapOf(
    "panoId" to panoId,
    "position" to listOf(position.latitude, position.longitude),
    "links" to links.map { listOf(it.panoId, it.bearing) },
)
