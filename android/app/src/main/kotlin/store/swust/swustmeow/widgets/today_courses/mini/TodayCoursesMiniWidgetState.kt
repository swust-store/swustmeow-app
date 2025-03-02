package store.swust.swustmeow.widgets.today_courses.mini

import store.swust.swustmeow.entities.SingleCourse

data class TodayCoursesMiniWidgetState(
    val success: Boolean = false,
    val lastUpdateTimestamp: Long = 0,
    val todayCourses: List<SingleCourse>? = null,
    val weekNum: Int = 0
)
