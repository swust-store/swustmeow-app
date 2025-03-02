package store.swust.swustmeow.widgets.course_table

import android.graphics.Bitmap

data class CourseTableWidgetState(
    val success: Boolean = false,
    val lastUpdateTimestamp: Long = 0,
//    val weekNum: Int? = null,
//    val entryPaths: Map<Int, Map<Int, String>?>? = null,
    val bitmap: Bitmap? = null
)