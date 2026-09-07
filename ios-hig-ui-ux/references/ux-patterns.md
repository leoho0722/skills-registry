# App 級 UX 模式（Launch、Onboarding、Feedback、Settings、Notifications）

依據 Apple HIG 官方內容整理（Liquid Glass 世代，涵蓋 iOS 26/27；widgets 與 Live Activities 頁面為 2025-12 大幅改版後內容）。聚焦 iOS／iPadOS。

## 目錄

- [啟動體驗（Launching）](#啟動體驗launching)
- [Onboarding](#onboarding)
- [載入（Loading）](#載入loading)
- [回饋（Feedback）](#回饋feedback)
- [提供協助（Offering Help）](#提供協助offering-help)
- [設定（Settings）](#設定settings)
- [通知（Notifications）](#通知notifications)
- [評分與評論（Ratings & Reviews）](#評分與評論ratings--reviews)
- [帳號管理（Managing Accounts）](#帳號管理managing-accounts)
- [隱私與權限請求（Privacy）](#隱私與權限請求privacy)
- [Home Screen Quick Actions](#home-screen-quick-actions)
- [Widgets 與 Live Activities](#widgets-與-live-activities)
- [常見錯誤檢查清單](#常見錯誤檢查清單)

## 啟動體驗（Launching）

- 立即可用：使用者不想等超過幾秒。啟動流程從開啟 App 起、含首次下載、到第一個畫面就緒為止；onboarding 是啟動完成「之後」的事，不屬於啟動。
- Launch screen 是過場，不是廣告：唯一功能是讓 App「感覺」快。設計成與第一個畫面幾乎相同（相同背景色、相同 bar 骨架），否則切換時會閃爍。
- Launch screen 上避免任何文字（不會被本地化）、避免 logo 與品牌元素——除非它們本來就是第一個畫面的固定部分。不要做成 splash screen 或 About 頁。
- 若需要 splash screen（品牌畫面），放在 onboarding 流程開頭短暫顯示，一眼看完即可，不要拖慢體驗。
- 恢復先前狀態：重啟後讓使用者接續上次進度——捲動位置、瀏覽層級、視窗狀態都盡量還原，不要逼人重走一遍。SwiftUI：`@SceneStorage`；UIKit：state restoration API。
- 以裝置當前方向啟動；只支援單一方向時直接以該方向啟動，並確保左右旋轉進入 landscape 都正確。
- 大型資產用 Background Assets framework 在安裝後／更新時背景下載，縮短安裝與首啟時間。

## Onboarding

- 能不教就不教：最理想的 App 是「用了就懂」。onboarding 要快速、有趣、且可跳過（optional）。
- 用互動教學取代說明頁：讓人實際安全地操作一次，比看圖文輪播記得牢。
- 優先用 context-specific tips（TipKit）取代單一大型 onboarding 流程：在功能出現的當下就地提示，一次聚焦一件事。
- 若必須有前置 onboarding，做短、做輕鬆，不要求記憶大量資訊；教太多反而記不住。
- 教學（tutorial）若獨立提供，首次可跳過，之後不要再自動彈出，但要放在 help／設定區可隨時找到。
- 內容聚焦你的 App 本身，不要教系統或裝置怎麼用。
- 延遲非必要的設定與客製化步驟：提供合理預設值，讓多數人零設定即可開始。
- 不要讓大型下載卡住 onboarding；套件內先附足夠內容。
- 授權請求可整合進 onboarding——僅限「App 沒有此權限就無法運作」的情況；否則等到使用者初次觸及該功能時再請求。
- 避免在 onboarding 裡塞授權條款（讓 App Store 展示）；避免在此時要求評分或購買——先讓人用出感情。

## 載入（Loading）

- 最好的載入體驗是在使用者察覺前就完成。永遠不要顯示空白畫面：先顯示 placeholder 文字、圖形或 skeleton，內容就緒後替換。SwiftUI：`.redacted(reason: .placeholder)`。
- 載入超過一兩秒才需要 progress indicator：知道時長用 determinate，不知道用 indeterminate。SwiftUI：`ProgressView(value:)` / `ProgressView()`。
- 背景載入，讓人同時能做其他事（如遊戲載關卡時先看提示或選單）。
- 無法避免的長載入要給有趣的東西看（提示、新功能介紹），並盡量準確估計剩餘時間。
- 遊戲可用符合美術風格的自訂載入畫面，取代制式 spinner。
- watchOS：盡量不顯示 loading indicator；需要一兩秒時，顯示 indicator 仍勝過空白畫面。

## 回饋（Feedback）

- 回饋強度要匹配資訊重要性：狀態類資訊被動地整合進介面（如 Mail 在 toolbar 顯示未讀數與更新時間），不打斷人；可能造成資料遺失的警告才用打斷式。
- Alert 只留給關鍵、且最好可行動（actionable）的資訊；濫用會讓 alert 失去效力。
- 警告時機：對「非預期且不可逆」的資料遺失才警告；預期中的結果（如刪除檔案進垃圾桶）不要每次都警告。
- 成功回饋克制使用：人們預設操作會成功，通常只需要知道「失敗」。只對足夠重大的操作確認成功（如 Apple Pay 交易完成）。
- 指令無法執行時要說明原因，幫人理解如何修正（如 Maps 說明起訖點相同無法導航）。
- 回饋要無障礙：並用色彩、文字、聲音、haptics 多管道，靜音、沒看螢幕、使用 VoiceOver 的人都能收到。SwiftUI：`.sensoryFeedback(_:trigger:)`。

## 提供協助（Offering Help）

- Contextual help 優先：協助內容直接對應使用者「當下」的動作，且容易忽略或關閉。
- 不要解釋標準元件怎麼用；只描述該元件在你 App 裡執行什麼任務。
- Tips（TipKit）：適合教「三步內可完成」的簡單功能；一到兩句、行動導向、不含推銷內容。用 popover tip 指向特定 UI 元素、inline tip 保留周圍內容可見。
- 用 eligibility rules 控制誰看到 tip（用過該功能的人不要再看到），並設定顯示頻率（如每 24 小時最多一則）。API：`Tip`、`TipView`、`.popoverTip()`。
- Tip 可附 button 導向設定或更多資訊；圖示優先用 filled variant 的 SF Symbol。
- 措辭與圖像要符合當前平台與輸入裝置（iPhone 說 tap 不說 click）。
- 非標準操作用動畫或圖像快速示範，勝過長篇文字。

## 設定（Settings）

- 能推斷就不要問：偵測得到的資訊（Dark Mode、已連接的控制器、裝置效能）不要做成設定項。提供讓最多人直接可用的預設值。
- 設定越少越好：太多設定讓 App 顯得難以親近，也讓人找不到想要的那一項。
- 尊重系統層級設定（無障礙、捲動行為、認證方式），不要在 App 內做重複的自訂版本——那會讓人困惑系統設定是否對你的 App 生效。
- 三層分工：
  - 任務內選項（顯示/隱藏、排序、篩選）：放在受影響的畫面裡就地調整，不要塞進設定區。
  - App 內設定區：放「一般性、少改動」的選項（介面風格、帳號相關、存檔行為）。
  - 系統 Settings app：只放「最少改動」的項目；若有放，提供按鈕直接跳轉。API：`UIApplication.openSettingsURLString`。
- 外接鍵盤時支援 Command-Comma 開啟設定（遊戲慣用 Esc）。

## 通知（Notifications）

- 先取得授權才能發通知；請求時機選在使用者理解價值之後（不要一啟動就要）。API：`UNUserNotificationCenter.requestAuthorization`。
- 誠實標注 interruption level（noncommunication 通知四級：`passive`／`active`（預設）／`timeSensitive`／`critical`）。用高急迫等級包裝低價值資訊會摧毀信任——使用者隨時可以整個關掉你的通知。
- Time Sensitive 只用於「此刻或一小時內發生」的事（可突破 Focus 與排程遞送）；系統會讓使用者評估並可單獨關閉。Critical 需要 entitlement，極罕見。
- 尊重 Focus 與 delivery scheduling：使用者可延後非緊急通知到摘要時段；即使 alert 被延遲，通知本身抵達即可查看。設計時假設你的 active/passive 通知「不會」即時被看到。
- 行銷／促銷通知必須先取得「明確同意」（獨立的 opt-in 介面，說明內容類型、可 opt-out），且永遠不得使用 Time Sensitive。
- App 內必須提供通知管理畫面，讓人隨時改變選擇。
- 直接通訊（電話、訊息）用 communication notifications 並採用 SiriKit intents（使用者可透過 Siri 客製其行為），其餘用 noncommunication。

## 評分與評論（Ratings & Reviews）

- 只在使用者展現投入之後才請求（完成關卡、完成重要任務）；絕不在首次啟動或 onboarding 期間。
- 不打斷：選自然的停頓點，不要在任務或遊戲進行中彈出。
- 不糾纏：兩次請求至少間隔一至兩週。系統本身限制每 App 每 365 天最多顯示 3 次 prompt。
- 使用系統提供的 prompt，不要自製評分介面。API：SwiftUI `@Environment(\.requestReview)`（StoreKit `RequestReviewAction`）；舊 API 為 `SKStoreReviewController.requestReview`。
- 新版本重設 summary rating 前先權衡：評分會歸零變少，可能降低下載意願。

## 帳號管理（Managing Accounts）

- 能不註冊就不註冊：只有核心功能需要帳號才要求。需要時，在 sign-in 畫面簡短說明理由與好處。
- 延遲 sign-in 到最後一刻：先讓人瀏覽與體驗（如購物 App 到結帳才要求登入）；強迫先登入是棄用主因。
- 優先 Sign in with Apple；不用它就優先 passkey（免密碼）。仍用密碼者必須加上兩步驟驗證。API：`SignInWithAppleButton`、`ASAuthorizationPlatformPublicKeyCredentialProvider`。
- 按鈕明示認證方式（「Sign In with Face ID」而非泛稱「Sign In」），且只提當前裝置真正具備的方式。
- 不要提供 App 內的生物辨識 opt-in 設定（系統層已管理）；不要用「passcode」一詞指涉 App 帳號認證。
- App 內能建立帳號就必須能「刪除」帳號（不是停用）：入口要好找（不可埋在隱私政策裡）、App 內與網站流程一致、可排程刪除者須同時提供立即刪除、告知完成時間並在完成時通知。
- 用 Sign in with Apple 建立的帳號，刪除時要 revoke 相關 tokens。
- 有訂閱者要說明刪帳號後扣款如何處理（訂閱不隨帳號刪除而取消，需另行取消或退款）。

## 隱私與權限請求（Privacy）

- 最小資料收集：只要求功能實際需要的資料；能在裝置上處理就不要上傳。敏感資訊存 Keychain，絕不存明文。
- 權限請求時機＝使用者初次使用該功能時；避免啟動時請求，除非沒有它 App 無法運作（如導航 App 之於位置）。
- Purpose string 寫法：一句完整、主動、具體的句子，說明「如何使用、為何需要」（好：「The app records during the night to detect snoring sounds.」；壞：「Microphone access is needed for a better experience.」）。Info.plist `NS*UsageDescription` 系列。
- 系統 alert 之前的自訂說明畫面（pre-alert screen）規則：只能有一顆按鈕、標題用「Continue」/「Next」（不可用「Allow」）、不可提供關閉／取消、不可提供誘因、不可模仿或標注系統 alert——違者 App Store 直接退件。
- App tracking（ATT）：收集任何 tracking 資料前必須先顯示系統 alert；不得以任何獎勵、脅迫或誤導畫面影響選擇。API：`ATTrackingManager.requestTrackingAuthorization`。
- 位置類功能考慮用 location button 取代全域授權：一次性、隨用隨授。SwiftUI：`LocationButton`。
- 避免自創認證方案；用 passkeys、Sign in with Apple 等系統機制（OS 26 起有 account creation API 與 automatic passkey upgrades）。

## Home Screen Quick Actions

- 長按 App icon 出現的選單，只放高價值任務（至少 1 個、最多 4 個）；標題直述結果（「New Message」「Directions Home」），不含 App 名稱，注意本地化長度。
- 圖示優先用 SF Symbols，不可用 emoji（quick action 是單色並隨 Dark Mode 變化）。API：`UIApplicationShortcutItem`（支援 dynamic 更新，但變化要可預期）。

## Widgets 與 Live Activities

- Widget 核心：一眼可讀（glanceable）、內容隨時間變化、深連結到 App 對應位置；複製 App icon 的 widget 沒有存在價值。API：WidgetKit；互動用 App Intents。
- Widget 須支援外觀變化：light／dark／clear（系統套用 Liquid Glass 材質與去飽和）／tinted，對應 full-color、accented、vibrant 三種 rendering mode——設計時就要驗證 accented mode 下背景被移除、換成 Liquid Glass 背景或 tint 色後仍可讀。
- 尺寸取捨：做最能代表內容的尺寸，勝過硬撐所有尺寸；小尺寸放單一資訊，大尺寸加層次而非放大。平衡資訊密度：太疏顯得多餘，太密失去 glanceable。
- 品牌元素克制：不要在 widget 裡放整個 App icon 或大 logo；讓內容本身代表 App。
- Live Activity：用於「有明確起訖、不超過 8 小時」的任務追蹤（外送、賽事、運動）；必須支援 compact／minimal／expanded／Lock Screen 各 presentation（Dynamic Island 與 StandBy 由系統組合），並自動出現在 Mac 選單列、Apple Watch Smart Stack 與 CarPlay。API：ActivityKit。
- Live Activity 不得放廣告促銷；避免顯示敏感資訊（Lock Screen 上路人可見，必要時改顯示中性摘要或 redact）；文字用中粗以上字重確保一瞥可讀；Lock Screen 高度隨資訊量動態伸縮。

## 常見錯誤檢查清單

- Launch screen 放了 logo、標語或與首畫面不同的視覺 → 改成與首畫面幾乎相同的骨架。
- 首次啟動就連發權限請求＋評分請求＋強制註冊 → 全部延後到對應功能與投入時刻。
- 用多頁輪播圖教學取代可互動的 contextual tips → 換成 TipKit 就地提示，且可跳過。
- 載入時整頁空白或整頁 spinner → 先出 placeholder/skeleton，超過一兩秒才加 progress indicator。
- 每個成功操作都彈 alert 或 toast → 只確認重大操作，其餘靜默；alert 留給關鍵可行動資訊。
- 設定區塞了 Dark Mode 開關、系統無障礙重複項、任務內選項 → 依「任務內／App 設定區／系統 Settings」三層歸位。
- 行銷推播未經獨立 opt-in、或標成 Time Sensitive → 退件與信任雙輸。
- 有註冊卻沒有 App 內刪除帳號入口 → App Store 審查必要條件。
- Purpose string 寫「needed for a better experience」 → 改寫為具體用途的完整句子。
- Pre-alert 說明畫面放了「稍後再說」或「Allow」按鈕 → 只能有一顆「Continue」類按鈕，直接導向系統 alert。
- 自製評分星星介面或每版都彈評分 → 一律走系統 `requestReview`，由系統控制頻率。
- Quick action 標題含 App 名稱、圖示用 emoji → 標題直述動作結果，圖示用 SF Symbol。
- Widget 只在 full-color 模式測試 → 在 clear（Liquid Glass）與 tinted 外觀下驗證對比與可讀性。
