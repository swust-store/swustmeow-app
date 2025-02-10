package store.swust.swustmeow.widgets

import android.content.Context
import androidx.glance.appwidget.GlanceAppWidgetReceiver

class NextCourseWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget = NextCourseWidget()

    override fun onDeleted(context: Context, appWidgetIds: IntArray) {
        super.onDeleted(context, appWidgetIds)
    }
}