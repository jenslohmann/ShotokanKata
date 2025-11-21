package dk.jlo.shotokankata.di

import android.content.Context
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import dk.jlo.shotokankata.data.source.JsonDataSource
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object AppModule {

    @Provides
    @Singleton
    fun provideJsonDataSource(
        @ApplicationContext context: Context
    ): JsonDataSource {
        return JsonDataSource(context)
    }
}
