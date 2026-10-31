package __PACKAGE__

import androidx.navigation3.runtime.NavKey
import __BASE_PACKAGE__.core.navigation.Navigator
import kotlinx.serialization.Serializable

/** 前往 __NAME__ 畫面的導航目的地。 */
@Serializable
data object __NAME__NavKey : NavKey

/** 前往 __NAME__ 畫面。 */
fun Navigator.navigateTo__NAME__() {
    navigate(__NAME__NavKey)
}
