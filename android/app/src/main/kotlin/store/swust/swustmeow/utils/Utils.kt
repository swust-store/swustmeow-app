package store.swust.swustmeow.utils

suspend fun <T> tryDoSuspend(retries: Int = 3, block: suspend () -> T): T? {
    var attempts = 0

    while (attempts < retries) {
        try {
            return block()
        } catch (e: Exception) {
            attempts++
            if (attempts == retries) {
                e.printStackTrace()
                return null
            }
        }
    }

    return null
}
