package store.swust.swustmeow.widgets.course_table

import android.content.Context
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.Image
import androidx.glance.ImageProvider
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.cornerRadius
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.currentState
import androidx.glance.layout.Alignment
import androidx.glance.layout.Box
import androidx.glance.layout.ContentScale
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.padding
import store.swust.swustmeow.components.CourseLoadErrorBox

class CourseTableWidget : GlanceAppWidget() {
    override val stateDefinition = CourseTableWidgetStateDefinition()

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent {
            CourseTableWidgetContent(context, currentState())
        }
    }

    @Suppress("UNUSED_PARAMETER")
    @Composable
    private fun CourseTableWidgetContent(context: Context, currentState: CourseTableWidgetState) {
        val success = currentState.success
        val bitmap = currentState.bitmap

        Box(
            modifier = GlanceModifier.cornerRadius(16.dp).background(Color.White)
                .fillMaxSize().padding(top = 4.dp),
            contentAlignment = Alignment.Center
        ) {
            if (success && bitmap != null) {
                Image(
                    provider = ImageProvider(bitmap),
                    contentDescription = "本周课表",
                    modifier = GlanceModifier.fillMaxSize(),
                    contentScale = ContentScale.FillBounds
                )
            } else {
                CourseLoadErrorBox()
            }
        }
    }
}
