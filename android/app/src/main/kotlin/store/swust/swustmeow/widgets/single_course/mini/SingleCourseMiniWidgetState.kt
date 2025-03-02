package store.swust.swustmeow.widgets.single_course.mini

import store.swust.swustmeow.entities.SingleCourse

data class SingleCourseMiniWidgetState(
    val success: Boolean = false,
    val lastUpdateTimestamp: Long = 0,
    val currentCourse: SingleCourse? = null,
    val nextCourse: SingleCourse? = null,
    val weekNum: Int = 0
)
