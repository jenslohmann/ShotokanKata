package dk.jlo.shotokankata.data.source

import android.content.Context
import dk.jlo.shotokankata.R
import dk.jlo.shotokankata.data.model.Kata
import dk.jlo.shotokankata.data.model.KataConfiguration
import dk.jlo.shotokankata.data.model.VocabularyResponse
import dk.jlo.shotokankata.data.model.VocabularyTerm
import kotlinx.serialization.json.Json
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class JsonDataSource @Inject constructor(
    private val context: Context
) {
    private val json = Json {
        ignoreUnknownKeys = true
        isLenient = true
    }

    fun loadKataConfiguration(): KataConfiguration {
        val jsonString = context.resources.openRawResource(R.raw.kata)
            .bufferedReader()
            .use { it.readText() }
        return json.decodeFromString(jsonString)
    }

    fun loadKata(resourceId: Int): Kata {
        val jsonString = context.resources.openRawResource(resourceId)
            .bufferedReader()
            .use { it.readText() }
        return json.decodeFromString(jsonString)
    }

    fun loadVocabulary(): List<VocabularyTerm> {
        val jsonString = context.resources.openRawResource(R.raw.vocabulary)
            .bufferedReader()
            .use { it.readText() }
        val response: VocabularyResponse = json.decodeFromString(jsonString)
        return response.vocabularyTerms
    }

    fun getKataResourceId(fileName: String): Int {
        val resourceName = fileName.removeSuffix(".json").replace("/", "_")
        return context.resources.getIdentifier(resourceName, "raw", context.packageName)
    }
}
