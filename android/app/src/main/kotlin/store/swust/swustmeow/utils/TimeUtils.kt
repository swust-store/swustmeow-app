package store.swust.swustmeow.utils

import java.time.LocalDate
import java.time.format.DateTimeFormatter

object TimeUtils {
    fun getCurrentMD(): String {
        val currentDate = LocalDate.now()
        val formatter = DateTimeFormatter.ofPattern("MM/dd")
        return currentDate.format(formatter)
    }

    fun getCurrentYMD(): String {
        val currentDate = LocalDate.now()
        val formatter = DateTimeFormatter.ofPattern("yyyy/MM/dd")
        return currentDate.format(formatter)
    }

    private fun getWeekday(): Int {
        val weekday = LocalDate.now().dayOfWeek
        return weekday.value
    }

    fun getWeekdayDisplayString(): String {
        val w = arrayOf("周一", "周二", "周三", "周四", "周五", "周六", "周日")
        return w[getWeekday() - 1]
    }
}