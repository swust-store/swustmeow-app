package store.swust.swustmeow.widgets

import android.content.Context
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.currentState
import androidx.glance.layout.Box
import androidx.glance.layout.Column
import androidx.glance.layout.padding
import androidx.glance.text.Text

class NextCourseWidget : GlanceAppWidget() {
    override val stateDefinition = NextCourseWidgetStateDefinition()

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent {
            NextCourseWidgetContent(context, currentState())
        }
    }

    @Composable
    private fun NextCourseWidgetContent(context: Context, currentState: NextCourseWidgetState) {
        val loading = currentState.loading
        Box(modifier = GlanceModifier.background(Color.White).padding(16.dp)) {
            Column {
                Text(loading.toString())
            }
        }
    }
}