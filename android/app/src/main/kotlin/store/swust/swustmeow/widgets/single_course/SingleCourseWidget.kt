package store.swust.swustmeow.widgets.single_course

import android.content.Context
import android.provider.CalendarContract.Colors
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.color.ColorProviders
import androidx.glance.currentState
import androidx.glance.layout.Box
import androidx.glance.layout.Column
import androidx.glance.layout.padding
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import androidx.glance.unit.ColorProvider

class SingleCourseWidget : GlanceAppWidget() {
    override val stateDefinition = SingleCourseWidgetStateDefinition()

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent {
            SingleCourseWidgetContent(context, currentState())
        }
    }

    @Composable
    private fun SingleCourseWidgetContent(context: Context, currentState: SingleCourseWidgetState) {
        val currentCourse = currentState.currentCourse
        val nextCourse = currentState.nextCourse

        Box(modifier = GlanceModifier.background(Color.White).padding(16.dp)) {
            Column {
                when {
                    currentCourse != null -> {
                        Text(
                            text = currentCourse.name,
                            style = TextStyle(color = ColorProvider(Color.Black))
                        )
                        Text(
                            text = currentCourse.place,
                            style = TextStyle(color = ColorProvider(Color.Gray))
                        )
                        Text(
                            text = currentCourse.time,
                            style = TextStyle(color = ColorProvider(Color.Gray))
                        )
                    }

                    nextCourse != null -> {
                        Text(
                            text = "下节课: ${nextCourse.name}",
                            style = TextStyle(color = ColorProvider(color = Color.Black))
                        )
                        Text(
                            text = nextCourse.place,
                            style = TextStyle(color = ColorProvider(color = Color.Gray))
                        )
                        Text(
                            text = nextCourse.time,
                            style = TextStyle(color = ColorProvider(color = Color.Gray))
                        )
                    }

                    else -> {
                        Text(
                            text = "今天没课啦",
                            style = TextStyle(color = ColorProvider(color = Color.Black))
                        )
                    }
                }
            }
        }
    }
}