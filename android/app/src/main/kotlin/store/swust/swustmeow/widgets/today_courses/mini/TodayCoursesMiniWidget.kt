package store.swust.swustmeow.widgets.today_courses.mini

import android.content.Context
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.cornerRadius
import androidx.glance.appwidget.lazy.LazyColumn
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
import store.swust.swustmeow.components.today_courses.CourseRow
import store.swust.swustmeow.components.today_courses.NoCourseBox
import store.swust.swustmeow.data.Values
import store.swust.swustmeow.providers.TodayCoursesDataProvider
import store.swust.swustmeow.utils.TimeUtils
import store.swust.swustmeow.widgets.today_courses.TodayCoursesWidgetState
import store.swust.swustmeow.widgets.today_courses.TodayCoursesWidgetStateDefinition

class TodayCoursesMiniWidget : GlanceAppWidget() {
    override val stateDefinition = TodayCoursesWidgetStateDefinition()

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent {
            TodayCoursesMiniWidgetContent(context, currentState())
        }
    }

    @Suppress("UNUSED_PARAMETER")
    @Composable
    private fun TodayCoursesMiniWidgetContent(context: Context, currentState: TodayCoursesWidgetState) {
        val success = currentState.success
        val todayCourses = currentState.todayCourses
        val weekNum = currentState.weekNum
        val date = TimeUtils.getCurrentMD()
        val weekday = TimeUtils.getWeekdayDisplayString()

        val provider = TodayCoursesDataProvider(
            date = date,
            weekday = weekday,
            weekNum = weekNum,
        )

        Box(
            modifier = GlanceModifier.cornerRadius(16.dp)
                .padding(horizontal = 16.dp, vertical = 16.dp).background(Color.White),
            contentAlignment = Alignment.Center
        ) {
            Column {
                HeaderRow(provider = provider)
                Spacer(modifier = GlanceModifier.height(Values.mediumSpacer))
                Column(
                    verticalAlignment = Alignment.Vertical.CenterVertically,
                    horizontalAlignment = Alignment.Horizontal.CenterHorizontally
                ) {
                    if (!success || todayCourses == null) {
                        CourseLoadErrorBox()
                    } else if (todayCourses.isEmpty()) {
                        NoCourseBox()
                    } else {
                        LazyColumn(modifier = GlanceModifier.fillMaxSize()) {
                            items(todayCourses.size) { index ->
                                Column {
                                    CourseRow(course = todayCourses[index], mini = true)
                                    if (index < todayCourses.size - 1) {
                                        Spacer(modifier = GlanceModifier.height(Values.smallSpacer))
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    @Composable
    private fun HeaderRow(provider: TodayCoursesDataProvider) {
        Row(
            modifier = GlanceModifier.fillMaxWidth(),
            verticalAlignment = Alignment.Vertical.CenterVertically
        ) {
            Text(
                text = "今日课表",
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
}