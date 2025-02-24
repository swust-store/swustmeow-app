package store.swust.swustmeow.widgets.single_course

data class SingleCourseWidgetState(
    val success: Boolean = false,
    val lastUpdateTimestamp: Long = 0,
    val currentCourse: SingleCourse? = null,
    val nextCourse: SingleCourse? = null,
    val weekNum: Int = 0
)
