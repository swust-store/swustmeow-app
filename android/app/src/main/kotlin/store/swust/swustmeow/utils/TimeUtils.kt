package store.swust.swustmeow.utils

import java.time.LocalDate
import java.time.format.DateTimeFormatter

object TimeUtils {
    fun getCurrentDate(): String {
        val currentDate = LocalDate.now()
        val formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd")
        return currentDate.format(formatter)
    }

    fun getWeekday(): Int {
        val weekday = LocalDate.now().dayOfWeek
        return weekday.value
    }
}