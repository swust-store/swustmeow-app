package store.swust.swustmeow.widgets

import android.content.Context
import androidx.datastore.core.DataStore
import androidx.datastore.core.DataStoreFactory
import androidx.datastore.core.Serializer
import androidx.datastore.dataStoreFile
import androidx.glance.state.GlanceStateDefinition
import com.google.gson.GsonBuilder
import com.google.gson.Strictness
import java.io.File
import java.io.InputStream
import java.io.OutputStream

class NextCourseWidgetStateDefinition : GlanceStateDefinition<NextCourseWidgetState> {
    private fun Context.nextCourseWidgetDataStoreFile(fileKey: String) =
        dataStoreFile("next_course_widget_$fileKey")

    override suspend fun getDataStore(
        context: Context,
        fileKey: String
    ): DataStore<NextCourseWidgetState> {
        return DataStoreFactory.create(serializer = NextCourseWidgetStateSerializer) {
            context.nextCourseWidgetDataStoreFile(fileKey)
        }
    }

    override fun getLocation(context: Context, fileKey: String): File {
        return context.nextCourseWidgetDataStoreFile(fileKey);
    }

    object NextCourseWidgetStateSerializer : Serializer<NextCourseWidgetState> {
        private val gson by lazy {
            GsonBuilder().setStrictness(Strictness.LENIENT).create()
        }

        override val defaultValue = NextCourseWidgetState(loading = true)

        override suspend fun readFrom(input: InputStream): NextCourseWidgetState = try {
            val jsonString = input.readBytes().decodeToString();
            gson.fromJson(jsonString, NextCourseWidgetState::class.java)
        } catch (e: Exception) {
            defaultValue
        }

        override suspend fun writeTo(t: NextCourseWidgetState, output: OutputStream) {
            output.use {
                it.write(gson.toJson(t).encodeToByteArray())
            }
        }
    }
}