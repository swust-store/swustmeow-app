package store.swust.swustmeow.widgets.single_course

import android.content.Context
import androidx.glance.appwidget.GlanceAppWidgetReceiver
import androidx.glance.appwidget.GlanceAppWidgetManager
import androidx.glance.appwidget.state.updateAppWidgetState
import androidx.glance.appwidget.updateAll
import com.google.gson.Gson
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import store.swust.swustmeow.entities.SingleCourse

class SingleCourseWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget = SingleCourseWidget()

    override fun onUpdate(
        context: Context,
        appWidgetManager: android.appwidget.AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        super.onUpdate(context, appWidgetManager, appWidgetIds)

        CoroutineScope(Dispatchers.Default).launch {
            val glanceAppWidgetManager = GlanceAppWidgetManager(context)
            val prefs =
                context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)

            val success = prefs.getBoolean("singleCourseSuccess", false)
            val lastUpdateTimestamp = prefs.getLong("singleCourseLastUpdateTimestamp", 0)
            val currentCourseJson = prefs.getString("singleCourseCurrent", null)
            val nextCourseJson = prefs.getString("singleCourseNext", null)
            val weekNum = prefs.getInt("singleCourseWeekNum", 0)

            val gson = Gson()

            val currentCourse = try {
                if (currentCourseJson != null) gson.fromJson(
                    currentCourseJson,
                    SingleCourse::class.java
                ) else null
            } catch (e: Exception) {
                null
            }

            val nextCourse = try {
                if (nextCourseJson != null) gson.fromJson(
                    nextCourseJson,
                    SingleCourse::class.java
                ) else null
            } catch (e: Exception) {
                null
            }

            if (success && (currentCourseJson == null || nextCourseJson == null)) return@launch

            appWidgetIds.forEach { appWidgetId ->
                val glanceId = glanceAppWidgetManager.getGlanceIdBy(appWidgetId)
                updateAppWidgetState(
                    context,
                    glanceAppWidget.stateDefinition,
                    glanceId
                ) {
                    SingleCourseWidgetState(
                        success = success,
                        lastUpdateTimestamp = lastUpdateTimestamp,
                        currentCourse = currentCourse,
                        nextCourse = nextCourse,
                        weekNum = weekNum
                    )
                }
            }

            glanceAppWidget.updateAll(context)
        }
    }
}