package store.swust.swustmeow.widgets.today_courses.mini

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
import store.swust.swustmeow.widgets.today_courses.TodayCoursesWidgetState

class TodayCoursesMiniWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget = TodayCoursesMiniWidget()

    @Suppress("UNCHECKED_CAST")
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

            val success = prefs.getBoolean("todayCoursesSuccess", false)
            val lastUpdateTimestamp = prefs.getLong("todayCoursesLastUpdateTimestamp", 0)
            val todayCoursesList = prefs.getString("todayCoursesList", null)
            val weekNum = prefs.getInt("todayCoursesWeekNum", 0)

            val gson = Gson()

            val todayCoursesMaps = try {
                if (todayCoursesList != null) gson.fromJson(
                    todayCoursesList,
                    List::class.java
                ) else null
            } catch (e: Exception) {
                null
            } as List<Map<String, *>>?

            val todayCourses = try {
                todayCoursesMaps?.map {
                    SingleCourse(
                        name = it["name"] as String,
                        place = it["place"] as String,
                        time = it["time"] as String,
                        diff = it["diff"] as String?,
                        color = (it["color"] as String).toLong()
                    )
                }
            } catch (e: Exception) {
                e.printStackTrace()
                null
            }

            appWidgetIds.forEach { appWidgetId ->
                val glanceId = glanceAppWidgetManager.getGlanceIdBy(appWidgetId)
                updateAppWidgetState(
                    context,
                    glanceAppWidget.stateDefinition,
                    glanceId
                ) {
                    TodayCoursesWidgetState(
                        success = success,
                        lastUpdateTimestamp = lastUpdateTimestamp,
                        todayCourses = todayCourses,
                        weekNum = weekNum
                    )
                }
            }

            glanceAppWidget.updateAll(context)
        }
    }
}