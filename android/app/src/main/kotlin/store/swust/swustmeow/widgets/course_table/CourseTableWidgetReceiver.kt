package store.swust.swustmeow.widgets.course_table

import android.appwidget.AppWidgetManager
import android.content.Context
import android.graphics.BitmapFactory
import androidx.glance.appwidget.GlanceAppWidgetManager
import androidx.glance.appwidget.GlanceAppWidgetReceiver
import androidx.glance.appwidget.state.updateAppWidgetState
import androidx.glance.appwidget.updateAll
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class CourseTableWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget = CourseTableWidget()

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        super.onUpdate(context, appWidgetManager, appWidgetIds)

        CoroutineScope(Dispatchers.Default).launch {
            val glanceAppWidgetManager = GlanceAppWidgetManager(context)
            val prefs =
                context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)

            val success = prefs.getBoolean("courseTableSuccess", false)
            val lastUpdateTimestamp = prefs.getLong("courseTableLastUpdateTimestamp", 0)
            val imagePath = prefs.getString("courseTableImagePath", null)
            val bitmap = BitmapFactory.decodeFile(imagePath)

            if (success && (imagePath == null || bitmap == null)) return@launch

            appWidgetIds.forEach { appWidgetId ->
                val glanceId = glanceAppWidgetManager.getGlanceIdBy(appWidgetId)
                updateAppWidgetState(
                    context,
                    glanceAppWidget.stateDefinition,
                    glanceId
                ) {
                    CourseTableWidgetState(
                        success = success,
                        lastUpdateTimestamp = lastUpdateTimestamp,
                        bitmap = bitmap
                    )
                }
            }

            glanceAppWidget.updateAll(context)
        }
    }
}