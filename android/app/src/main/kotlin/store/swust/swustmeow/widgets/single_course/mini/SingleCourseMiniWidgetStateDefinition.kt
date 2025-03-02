package store.swust.swustmeow.widgets.single_course.mini

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

class SingleCourseMiniWidgetStateDefinition : GlanceStateDefinition<SingleCourseMiniWidgetState> {
    private fun Context.singleCourseMiniWidgetDataStoreFile(fileKey: String) =
        dataStoreFile("single_course_mini_widget_$fileKey")

    override suspend fun getDataStore(
        context: Context,
        fileKey: String
    ): DataStore<SingleCourseMiniWidgetState> {
        return DataStoreFactory.create(serializer = SingleCourseMiniWidgetStateSerializer) {
            context.singleCourseMiniWidgetDataStoreFile(fileKey)
        }
    }

    override fun getLocation(context: Context, fileKey: String): File {
        return context.singleCourseMiniWidgetDataStoreFile(fileKey)
    }

    object SingleCourseMiniWidgetStateSerializer : Serializer<SingleCourseMiniWidgetState> {
        private val gson by lazy {
            GsonBuilder().create()
        }

        override val defaultValue = SingleCourseMiniWidgetState()

        override suspend fun readFrom(input: InputStream): SingleCourseMiniWidgetState = try {
            val jsonString = input.readBytes().decodeToString()
            val state = gson.fromJson<SingleCourseMiniWidgetState>(
                jsonString,
                object : TypeToken<SingleCourseMiniWidgetState>() {}.type
            )
            state
        } catch (e: Exception) {
            defaultValue
        }

        override suspend fun writeTo(t: SingleCourseMiniWidgetState, output: OutputStream) {
            output.use {
                it.write(gson.toJson(t).encodeToByteArray())
            }
        }
    }
}