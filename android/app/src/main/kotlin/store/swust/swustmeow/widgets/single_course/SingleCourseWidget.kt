package store.swust.swustmeow.widgets.single_course

import android.content.Context
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.cornerRadius
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.currentState
import androidx.glance.layout.Alignment
import androidx.glance.layout.Box
import androidx.glance.layout.Column
import androidx.glance.layout.Row
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.height
import androidx.glance.layout.padding
import androidx.glance.layout.width
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextAlign
import androidx.glance.text.TextStyle
import androidx.glance.unit.ColorProvider
import store.swust.swustmeow.components.CourseLoadErrorBox
import store.swust.swustmeow.components.single_course.CourseLocationRow
import store.swust.swustmeow.components.single_course.CourseStatusRow
import store.swust.swustmeow.components.single_course.CourseTimeRow
import store.swust.swustmeow.components.single_course.NoCourseBox
import store.swust.swustmeow.data.Values
import store.swust.swustmeow.providers.SingleCourseDataProvider
import store.swust.swustmeow.utils.TimeUtils

class SingleCourseWidget : GlanceAppWidget() {
    override val stateDefinition = SingleCourseWidgetStateDefinition()

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent {
            SingleCourseWidgetContent(context, currentState())
        }
    }

    @Suppress("UNUSED_PARAMETER")
    @Composable
    private fun SingleCourseWidgetContent(context: Context, currentState: SingleCourseWidgetState) {
        val success = currentState.success
        val currentCourse = currentState.currentCourse
        val nextCourse = currentState.nextCourse
        val weekNum = currentState.weekNum

        val date = TimeUtils.getCurrentYMD()
        val weekday = TimeUtils.getWeekdayDisplayString()

        val provider = SingleCourseDataProvider(
            date = date,
            weekday = weekday,
            weekNum = weekNum,
            currentCourse = currentCourse,
            nextCourse = nextCourse,
        )

        Box(
            modifier = GlanceModifier.cornerRadius(16.dp)
                .padding(horizontal = 20.dp, vertical = 16.dp).background(Color.White)
                .fillMaxSize(),
            contentAlignment = Alignment.Center
        ) {
            Column {
                HeaderRow(provider = provider)
                Spacer(modifier = GlanceModifier.height(Values.mediumSpacer))
                Column(
                    verticalAlignment = Alignment.Vertical.CenterVertically,
                    horizontalAlignment = Alignment.Horizontal.CenterHorizontally
                ) {
                    if (!success) {
                        CourseLoadErrorBox()
                    } else if (currentCourse == null && nextCourse == null) {
                        NoCourseBox()
                    } else {
                        CourseStatusRow(provider = provider)
                        Spacer(modifier = GlanceModifier.height(Values.smallSpacer))
                        CourseNameRow(provider = provider)
                        Spacer(modifier = GlanceModifier.height(Values.mediumSpacer))
                        BottomInformationRow(provider = provider)
                    }
                }
            }
        }
    }

    @Composable
    private fun HeaderRow(provider: SingleCourseDataProvider) {
        Row(
            modifier = GlanceModifier.fillMaxWidth(),
            verticalAlignment = Alignment.Vertical.CenterVertically
        ) {
            Text(
                text = "${provider.date}    ${provider.weekday}",
                modifier = GlanceModifier.defaultWeight(),
                style = TextStyle(
                    color = ColorProvider(Color.Black),
                    fontSize = 14.sp,
                    fontWeight = FontWeight.Bold
                ),
                maxLines = 1
            )
            Spacer(modifier = GlanceModifier.width(Values.smallSpacer))
            Text(
                text = "第${provider.weekNum}周",
                style = TextStyle(
                    color = ColorProvider(Color.Black),
                    fontSize = 14.sp,
                    textAlign = TextAlign.End
                ),
                maxLines = 1
            )
        }
    }

    @Composable
    private fun CourseNameRow(provider: SingleCourseDataProvider) {
        Row(modifier = GlanceModifier.fillMaxWidth()) {
            Text(
                text = provider.currentCourse?.name ?: provider.nextCourse?.name ?: "",
                style = TextStyle(
                    color = ColorProvider(Color.Black),
                    fontWeight = FontWeight.Bold,
                    fontSize = 24.sp,
                ),
                maxLines = 1
            )
        }
    }

    @Composable
    private fun BottomInformationRow(provider: SingleCourseDataProvider) {
        Row(
            modifier = GlanceModifier.fillMaxWidth(),
            verticalAlignment = Alignment.Vertical.CenterVertically,
        ) {
            CourseLocationRow(provider = provider, modifier = GlanceModifier.defaultWeight())
            Spacer(modifier = GlanceModifier.width(Values.smallSpacer))
            CourseTimeRow(provider = provider)
        }
    }
}