package zyz.flutter.plugin.flutter_google_street_view

import android.content.Context
import androidx.lifecycle.Lifecycle
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

internal class StreetViewFactory(
    private val messenger: BinaryMessenger,
    private val pool: StreetViewPool,
    private val lifecycleProvider: () -> Lifecycle?,
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView =
        StreetViewPlatformView(
            context = context,
            viewId = viewId,
            creationParams = args as? Map<*, *> ?: emptyMap<String, Any>(),
            messenger = messenger,
            pool = pool,
            lifecycle = lifecycleProvider(),
        )
}
