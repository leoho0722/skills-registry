package __BASE_PACKAGE__

import __BASE_PACKAGE__.core.data.__NAME__Repository
import __BASE_PACKAGE__.core.data.di.DataModule
import __BASE_PACKAGE__.core.testing.repository.Fake__NAME__Repository
import dagger.Module
import dagger.Provides
import dagger.hilt.components.SingletonComponent
import dagger.hilt.testing.TestInstallIn
import javax.inject.Singleton

/** UI 測試時把所有 Repository 換成 Fake，測試可以注入同一個 Fake 來設定結果。 */
@Module
@TestInstallIn(
    components = [SingletonComponent::class],
    replaces = [DataModule::class]
)
object TestDataModule {

    /** 整個測試共用同一個 Fake，測試與畫面拿到的是同一份。 */
    @Provides
    @Singleton
    fun provideFake__NAME__Repository(): Fake__NAME__Repository = Fake__NAME__Repository()

    /** 畫面要的 interface 由 [fake] 提供。 */
    @Provides
    fun provide__NAME__Repository(fake: Fake__NAME__Repository): __NAME__Repository = fake
}
