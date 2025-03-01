package store.swust.swustmeow.components.today_courses

import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceModifier
import androidx.glance.appwidget.cornerRadius
import androidx.glance.background
import androidx.glance.layout.Box
import androidx.glance.layout.Column
import androidx.glance.layout.Row
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.height
import androidx.glance.layout.width
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextAlign
import androidx.glance.text.TextStyle
import androidx.glance.unit.ColorProvider
import store.swust.swustmeow.components.MonospacedText
import store.swust.swustmeow.data.Values
import store.swust.swustmeow.entities.SingleCourse

@Composable
fun CourseRow(course: SingleCourse) {
    val times = course.time.split("-")
    val startTime = times.first().split(":")
    val endTime = times.last().split(":")
    val timeStyle = TextStyle(
        fontSize = 12.sp,
        textAlign = TextAlign.Center,
    )

    Row(modifier = GlanceModifier.fillMaxWidth()) {
        Column {
            Row {
                MonospacedText(
                    startTime.first(),
                    width = 8.dp,
                    style = timeStyle.copy(color = ColorProvider(Color.Black)),
                )
                Text(":", style = timeStyle)
                MonospacedText(
                    startTime.last(),
                    width = 8.dp,
                    style = timeStyle.copy(color = ColorProvider(Color.Black)),
                )
            }
            Spacer(modifier = GlanceModifier.height(Values.miniSpacer))
            Row {
                MonospacedText(
                    endTime.first(),
                    width = 8.dp,
                    style = timeStyle.copy(color = ColorProvider(Color.Gray)),
                )
                Text(":", style = timeStyle)
                MonospacedText(
                    endTime.last(),
                    width = 8.dp,
                    style = timeStyle.copy(color = ColorProvider(Color.Gray)),
                )
            }
        }
        Spacer(modifier = GlanceModifier.width(Values.mediumSpacer))
        Box(
            modifier = GlanceModifier.background(Color(course.color)).cornerRadius(8.dp).width(4.dp)
                .height((2 * 16 + Values.miniSpacer.value).dp)
        ) {}
        Spacer(modifier = GlanceModifier.width(Values.mediumSpacer))
        Column(modifier = GlanceModifier.defaultWeight()) {
            Text(
                course.name,
                style = TextStyle(
                    color = ColorProvider(Color.Black),
                    fontSize = 14.sp,
                    fontWeight = FontWeight.Bold
                ),
                maxLines = 1
            )
            Spacer(modifier = GlanceModifier.height(Values.miniSpacer))
            Text(
                course.place,
                style = TextStyle(
                    color = ColorProvider(Color.Gray),
                    fontSize = 12.sp
                ),
                maxLines = 1
            )
        }
    }
}