package store.swust.swustmeow.widgets.single_course.mini

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
import store.swust.swustmeow.components.single_course.CourseLoadErrorBox
import store.swust.swustmeow.components.single_course.CourseLocationRow
import store.swust.swustmeow.components.single_course.CourseStatusRow
import store.swust.swustmeow.components.single_course.CourseTimeRow
import store.swust.swustmeow.components.single_course.NoCourseBox
import store.swust.swustmeow.data.Values
import store.swust.swustmeow.providers.SingleCourseDataProvider
import store.swust.swustmeow.utils.TimeUtils
import store.swust.swustmeow.widgets.single_course.SingleCourseWidgetState
import store.swust.swustmeow.widgets.single_course.SingleCourseWidgetStateDefinition

class SingleCourseMiniWidget : GlanceAppWidget() {
    override val stateDefinition = SingleCourseWidgetStateDefinition()

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent {
            SingleCourseMiniWidgetContent(context, currentState())
        }
    }

    @Suppress("UNUSED_PARAMETER")
    @Composable
    private fun SingleCourseMiniWidgetContent(
        context: Context,
        currentState: SingleCourseWidgetState
    ) {
        val success = currentState.success
        val currentCourse = currentState.currentCourse
        val nextCourse = currentState.nextCourse
        val weekNum = currentState.weekNum

        val date = TimeUtils.getCurrentMD()
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
                .padding(horizontal = 16.dp, vertical = 16.dp).background(Color.White)
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
                        CourseStatusRow(provider = provider, showLeftTime = false)
                        Spacer(modifier = GlanceModifier.height(Values.smallSpacer))
                        CourseNameRow(provider = provider)
                        Spacer(modifier = GlanceModifier.height(Values.smallSpacer))
                        BottomInformationColumn(provider = provider)
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
                text = provider.date,
                modifier = GlanceModifier.defaultWeight(),
                style = TextStyle(
                    color = ColorProvider(Color.Black),
                    fontSize = 18.sp,
                    fontWeight = FontWeight.Bold
                ),
                maxLines = 1
            )
            Text(
                text = "第${provider.weekNum}周",
                style = TextStyle(
                    color = ColorProvider(Color.Black),
                    fontSize = 12.sp,
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
                    fontSize = 20.sp,
                ),
                maxLines = 1
            )
        }
    }

    @Composable
    private fun BottomInformationColumn(provider: SingleCourseDataProvider) {
        Column(
            modifier = GlanceModifier.fillMaxWidth(),
            horizontalAlignment = Alignment.Horizontal.Start
        ) {
            CourseLocationRow(provider = provider, modifier = GlanceModifier)
            Spacer(modifier = GlanceModifier.width(Values.smallSpacer))
            CourseTimeRow(provider = provider)
        }
    }
}