package store.swust.swustmeow.entities

import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp

data class SingleCourseDateProvider(
    val date: String,
    val weekday: String,
    val weekNum: Int,
    val currentCourse: SingleCourse?,
    val nextCourse: SingleCourse?,
    val primaryColor: Color = Color(27, 122, 222),
    val secondaryColor: Color = Color.Black.copy(alpha = 0.6F),
    val basePadding: Dp = 10.dp,
    val miniSpacer: Dp = basePadding * 0.3F,
    val smallSpacer: Dp = basePadding * 0.7F,
    val mediumSpacer: Dp = basePadding * 0.9F
)