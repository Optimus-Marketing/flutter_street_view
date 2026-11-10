package zyz.flutter.plugin.flutter_google_street_view

import android.content.Context
import com.google.android.gms.maps.StreetViewPanoramaOptions
import com.google.android.gms.maps.StreetViewPanoramaView

internal class StreetViewPool {
    private val idleViews = ArrayDeque<StreetViewPanoramaView>()

    var viewCount = 0
        private set

    fun reuse(): StreetViewPanoramaView? = idleViews.removeFirstOrNull()

    fun create(context: Context, options: StreetViewPanoramaOptions): StreetViewPanoramaView {
        viewCount++
        return StreetViewPanoramaView(context, options)
    }

    fun recycle(view: StreetViewPanoramaView) {
        idleViews.addLast(view)
    }

    fun destroy(view: StreetViewPanoramaView) {
        view.onDestroy()
        viewCount--
    }

    fun clear() {
        while (idleViews.isNotEmpty()) destroy(idleViews.removeFirst())
    }
}
