package dk.jlo.shotokankata.di

import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import dk.jlo.shotokankata.data.repository.KataRepository
import dk.jlo.shotokankata.data.repository.QuizRepository
import dk.jlo.shotokankata.data.repository.VocabularyRepository
import dk.jlo.shotokankata.data.source.JsonDataSource
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object RepositoryModule {

    @Provides
    @Singleton
    fun provideKataRepository(
        jsonDataSource: JsonDataSource
    ): KataRepository {
        return KataRepository(jsonDataSource)
    }

    @Provides
    @Singleton
    fun provideVocabularyRepository(
        jsonDataSource: JsonDataSource
    ): VocabularyRepository {
        return VocabularyRepository(jsonDataSource)
    }

    @Provides
    @Singleton
    fun provideQuizRepository(
        kataRepository: KataRepository,
        vocabularyRepository: VocabularyRepository
    ): QuizRepository {
        return QuizRepository(kataRepository, vocabularyRepository)
    }
}
