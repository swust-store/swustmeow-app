package store.swust.swustmeow.widgets.single_course

import android.content.Context
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.ColorFilter
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
import store.swust.swustmeow.R
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

        val date = TimeUtils.getCurrentDate()
        val weekdays = arrayOf("周一", "周二", "周三", "周四", "周五", "周六", "周日")
        val weekday = weekdays[TimeUtils.getWeekday() - 1]
        val primaryColor = Color(27, 122, 222)
        val secondaryColor = Color.Black.copy(alpha = 0.6F)
        val backgroundColor = Color(247, 251, 255)
        val headerColor = Color(235, 245, 255)

        val basePadding = 10.dp
        val smallSpacer = basePadding * 0.7f
        val mediumSpacer = basePadding * 0.9f

        val provider = ComposableDataProvider(
            date = date,
            weekday = weekday,
            weekNum = weekNum,
            currentCourse = currentCourse,
            nextCourse = nextCourse,
            primaryColor = primaryColor,
            secondaryColor = secondaryColor,
            smallSpacer = smallSpacer,
            mediumSpacer = mediumSpacer
        )

        Box(modifier = GlanceModifier.cornerRadius(16.dp)) {
            Column {
                Box(
                    modifier = GlanceModifier.background(headerColor)
                        .padding(horizontal = basePadding * 1.4f, vertical = basePadding)
                ) {
                    HeaderRow(provider = provider)
                }
                Box(
                    GlanceModifier.background(backgroundColor.copy(alpha = 0.8F))
                        .padding(horizontal = basePadding * 1.4f, vertical = basePadding)
                ) {
                    Column(
                        modifier = GlanceModifier.padding(basePadding).fillMaxSize(),
                        verticalAlignment = Alignment.Vertical.CenterVertically,
                        horizontalAlignment = Alignment.Horizontal.CenterHorizontally
                    ) {
                        if (!success) {
                            LoadErrorBox()
                        } else {
                            CourseStatusRow(provider = provider)
                            Spacer(modifier = GlanceModifier.height(mediumSpacer))
                            CourseNameRow(provider = provider)
                            Spacer(modifier = GlanceModifier.height(mediumSpacer))
                            BottomInformationRow(provider = provider)
                        }
                    }
                }
            }
        }

//        Box(
//            modifier = GlanceModifier.background(backgroundColor.copy(alpha = 0.8F))
//                .padding(horizontal = basePadding * 1.4f, vertical = basePadding)
//                .cornerRadius(16.dp)
//        ) {
//            Column(
//                modifier = GlanceModifier.padding(basePadding).fillMaxSize(),
//                verticalAlignment = Alignment.Vertical.CenterVertically,
//                horizontalAlignment = Alignment.Horizontal.CenterHorizontally
//            ) {
//                if (!success) {
//                    LoadErrorBox()
//                } else {
//                    HeaderRow(provider = provider)
//                    Spacer(modifier = GlanceModifier.height(mediumSpacer))
//                    CourseStatusRow(provider = provider)
//                    Spacer(modifier = GlanceModifier.height(mediumSpacer))
//                    CourseNameRow(provider = provider)
//                    Spacer(modifier = GlanceModifier.height(mediumSpacer))
//                    BottomInformationRow(provider = provider)
//                }
//            }
//        }
    }

    data class ComposableDataProvider(
        val date: String,
        val weekday: String,
        val weekNum: Int,
        val currentCourse: SingleCourse?,
        val nextCourse: SingleCourse?,
        val primaryColor: Color,
        val secondaryColor: Color,
        val smallSpacer: Dp,
        val mediumSpacer: Dp
    )

    @Composable
    private fun LoadErrorBox() {
        Box(
            modifier = GlanceModifier.fillMaxSize(), contentAlignment = Alignment.Center
        ) {
            Text(text = "课程表获取失败")
        }
    }

    @Composable
    private fun HeaderRow(provider: ComposableDataProvider) {
        Row(modifier = GlanceModifier.fillMaxWidth()) {
            Text(
                text = provider.date,
                modifier = GlanceModifier.defaultWeight(),
                style = TextStyle(
                    color = ColorProvider(Color.Black),
                    fontSize = 18.sp
                ),
                maxLines = 1
            )
            Spacer(modifier = GlanceModifier.width(provider.smallSpacer))
            Text(
                text = provider.weekday,
                style = TextStyle(
                    color = ColorProvider(provider.secondaryColor),
                    fontSize = 14.sp,
                    textAlign = TextAlign.End
                ),
                maxLines = 1
            )
            Spacer(modifier = GlanceModifier.width(provider.smallSpacer))
            Text(
                text = "第${provider.weekNum}周",
                style = TextStyle(
                    color = ColorProvider(provider.secondaryColor),
                    fontSize = 14.sp,
                    textAlign = TextAlign.End
                ),
                maxLines = 1
            )
        }
    }

    @Composable
    private fun CourseStatusRow(provider: ComposableDataProvider) {
        Row(
            modifier = GlanceModifier.fillMaxWidth(),
            verticalAlignment = Alignment.Vertical.CenterVertically
        ) {
            Box(
                modifier = GlanceModifier.background(
                    if (provider.currentCourse != null) Color(
                        34,
                        197,
                        94
                    ) else Color(197, 175, 34)
                )
                    .cornerRadius(8.dp).width(4.dp).height(14.dp)
            ) {}
            Spacer(modifier = GlanceModifier.width(provider.smallSpacer))
            Text(
                text = if (provider.currentCourse != null) "正在上课" else "下节课",
                modifier = GlanceModifier.fillMaxWidth(),
                style = TextStyle(
                    color = ColorProvider(provider.secondaryColor),
                    fontSize = 16.sp,
                    fontWeight = FontWeight.Bold
                ),
                maxLines = 1
            )
        }
    }

    @Composable
    private fun CourseNameRow(provider: ComposableDataProvider) {
        Row(modifier = GlanceModifier.fillMaxWidth()) {
            Text(
                text = provider.currentCourse?.name ?: provider.nextCourse?.name ?: "",
                style = TextStyle(
                    color = ColorProvider(Color.Black),
                    fontWeight = FontWeight.Bold,
                    fontSize = 22.sp,
                ),
                maxLines = 1
            )
            if (provider.currentCourse == null) Text(
                text = "${provider.nextCourse?.diff}后上课",
                modifier = GlanceModifier.fillMaxWidth(),
                style = TextStyle(
                    color = ColorProvider(provider.primaryColor),
                    fontSize = 14.sp,
                    textAlign = TextAlign.End
                ),
                maxLines = 1
            )
        }
    }

    @Composable
    private fun BottomInformationRow(provider: ComposableDataProvider) {
        Row(
            modifier = GlanceModifier.fillMaxWidth(),
            verticalAlignment = Alignment.Vertical.CenterVertically,
        ) {
            Row(
                modifier = GlanceModifier.defaultWeight(),
                verticalAlignment = Alignment.Vertical.CenterVertically
            ) {
                Image(
                    provider = ImageProvider(R.drawable.location),
                    contentDescription = "location_icon",
                    modifier = GlanceModifier.width(14.dp).height(14.dp),
                    colorFilter = ColorFilter.tint(ColorProvider(provider.secondaryColor))
                )
                Spacer(modifier = GlanceModifier.width(provider.smallSpacer))
                Text(
                    text = provider.currentCourse?.place ?: provider.nextCourse?.place ?: "",
                    style = TextStyle(
                        color = ColorProvider(provider.secondaryColor),
                        fontSize = 14.sp
                    ),
                    maxLines = 1
                )
            }
            Spacer(modifier = GlanceModifier.width(provider.mediumSpacer))
            Image(
                provider = ImageProvider(R.drawable.clock),
                contentDescription = "clock_icon",
                modifier = GlanceModifier.width(12.dp).height(12.dp),
                colorFilter = ColorFilter.tint(ColorProvider(provider.primaryColor))
            )
            Spacer(modifier = GlanceModifier.width(provider.smallSpacer))
            Text(
                text = provider.currentCourse?.time ?: provider.nextCourse?.time ?: "",
                style = TextStyle(
                    color = ColorProvider(provider.primaryColor.copy(alpha = 0.8F)),
                    fontSize = 14.sp,
                    textAlign = TextAlign.End
                ),
                maxLines = 1
            )
        }
    }
}