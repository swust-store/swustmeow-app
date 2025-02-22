package store.swust.swustmeow.widgets.single_course

import android.content.Context
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.GlanceAppWidgetReceiver
import androidx.glance.appwidget.GlanceAppWidgetManager
import androidx.glance.appwidget.state.updateAppWidgetState
import androidx.glance.appwidget.updateAll
import com.google.gson.Gson
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

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

            println("------------------------------")
            println("所有 SharedPreferences 键值对：")
            println(prefs.all)

            val success = prefs.getBoolean("flutter.singleCourseSuccess", false)
            val currentCourseJson = prefs.getString("flutter.singleCourseCurrent", null)
            val nextCourseJson = prefs.getString("flutter.singleCourseNext", null)

            println("读取结果：")
            println("success: $success")
            println("currentCourseJson: $currentCourseJson")
            println("nextCourseJson: $nextCourseJson")
            println("------------------------------")

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

            appWidgetIds.forEach { appWidgetId ->
                val glanceId = glanceAppWidgetManager.getGlanceIdBy(appWidgetId)
                updateAppWidgetState(
                    context,
                    glanceAppWidget.stateDefinition,
                    glanceId
                ) {
                    SingleCourseWidgetState(
                        success = success,
                        lastUpdateTimestamp = System.currentTimeMillis(),
                        currentCourse = currentCourse,
                        nextCourse = nextCourse
                    )
                }
            }

            glanceAppWidget.updateAll(context)
        }
    }

    override fun onDeleted(context: Context, appWidgetIds: IntArray) {
        super.onDeleted(context, appWidgetIds)
    }
}