package __BASE_PACKAGE__.core.data.di

import __BASE_PACKAGE__.core.data.Default__NAME__Repository
import __BASE_PACKAGE__.core.data.__NAME__Repository
import dagger.Binds
import dagger.Module
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent

/** App 可注入的 Repository 清單：每個 interface 由哪個實作提供。 */
@Module
@InstallIn(SingletonComponent::class)
interface DataModule {

    /** 示範，替換為第一個實際的 Repository 並改寫此說明。 */
    @Binds
    fun bind__NAME__Repository(repository: Default__NAME__Repository): __NAME__Repository
}
