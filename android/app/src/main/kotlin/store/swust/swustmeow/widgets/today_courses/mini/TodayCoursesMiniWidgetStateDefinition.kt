package store.swust.swustmeow.widgets.today_courses.mini

import android.content.Context
import androidx.datastore.core.DataStore
import androidx.datastore.core.DataStoreFactory
import androidx.datastore.core.Serializer
import androidx.datastore.dataStoreFile
import androidx.glance.state.GlanceStateDefinition
import com.google.gson.GsonBuilder
import com.google.gson.reflect.TypeToken
import java.io.File
import java.io.InputStream
import java.io.OutputStream

class TodayCoursesMiniWidgetStateDefinition : GlanceStateDefinition<TodayCoursesMiniWidgetState> {
    private fun Context.todayCoursesMiniWidgetDataStoreFile(fileKey: String) =
        dataStoreFile("today_courses_mini_widget_$fileKey")

    override suspend fun getDataStore(
        context: Context,
        fileKey: String
    ): DataStore<TodayCoursesMiniWidgetState> {
        return DataStoreFactory.create(serializer = TodayCoursesMiniWidgetStateSerializer) {
            context.todayCoursesMiniWidgetDataStoreFile(fileKey)
        }
    }

    override fun getLocation(context: Context, fileKey: String): File {
        return context.todayCoursesMiniWidgetDataStoreFile(fileKey)
    }

    object TodayCoursesMiniWidgetStateSerializer : Serializer<TodayCoursesMiniWidgetState> {
        private val gson by lazy {
            GsonBuilder().create()
        }

        override val defaultValue = TodayCoursesMiniWidgetState()

        override suspend fun readFrom(input: InputStream): TodayCoursesMiniWidgetState = try {
            val jsonString = input.readBytes().decodeToString()
            val state = gson.fromJson<TodayCoursesMiniWidgetState>(
                jsonString,
                object : TypeToken<TodayCoursesMiniWidgetState>() {}.type
            )
            state
        } catch (e: Exception) {
            defaultValue
        }

        override suspend fun writeTo(t: TodayCoursesMiniWidgetState, output: OutputStream) {
            output.use {
                it.write(gson.toJson(t).encodeToByteArray())
            }
        }
    }
}