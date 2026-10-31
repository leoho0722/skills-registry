package __BASE_PACKAGE__.core.common.di

import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import javax.inject.Qualifier
import javax.inject.Singleton
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob

/** 標示讀寫檔案、資料庫、網路用的 dispatcher。 */
@Qualifier
@Retention(AnnotationRetention.BINARY)
annotation class IoDispatcher

/** 標示大量計算用的 dispatcher。 */
@Qualifier
@Retention(AnnotationRetention.BINARY)
annotation class DefaultDispatcher

/** 標示與 App 同壽的 coroutine scope，給畫面離開後仍要完成的短暫工作用。 */
@Qualifier
@Retention(AnnotationRetention.BINARY)
annotation class ApplicationScope

/** 提供 dispatcher 與 App 層級的 coroutine scope，測試時以 `@TestInstallIn` 換成測試用的 dispatcher。 */
@Module
@InstallIn(SingletonComponent::class)
object DispatchersModule {

    /** 讀寫檔案、資料庫、網路時切換到這裡，不卡住畫面。 */
    @Provides
    @IoDispatcher
    fun provideIoDispatcher(): CoroutineDispatcher = Dispatchers.IO

    /** 大量計算時切換到這裡，不卡住畫面。 */
    @Provides
    @DefaultDispatcher
    fun provideDefaultDispatcher(): CoroutineDispatcher = Dispatchers.Default

    /** 與 App 同壽的 scope，工作在 [dispatcher] 上執行，其中一個失敗不會取消其他工作。 */
    @Provides
    @Singleton
    @ApplicationScope
    fun provideApplicationScope(
        @DefaultDispatcher dispatcher: CoroutineDispatcher,
    ): CoroutineScope = CoroutineScope(SupervisorJob() + dispatcher)
}
