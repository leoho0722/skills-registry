# 無障礙與包容性設計（Accessibility & Inclusion）

依據 Apple Human Interface Guidelines（Accessibility、VoiceOver、Inclusion、Right to Left、Motion、Typography、Materials 頁面，2025–2026 版）整理的 iOS/iPadOS 操作指南。

## 目錄

- [核心原則](#核心原則)
- [VoiceOver 支援](#voiceover-支援)
- [Dynamic Type 與文字](#dynamic-type-與文字)
- [色彩與對比](#色彩與對比)
- [顯示與動態設定的因應](#顯示與動態設定的因應)
- [觸控目標與手勢](#觸控目標與手勢)
- [Switch Control、Full Keyboard Access 與其他輔助技術](#switch-controlfull-keyboard-access-與其他輔助技術)
- [聽覺與認知](#聽覺與認知)
- [動態效果與暈眩考量](#動態效果與暈眩考量)
- [包容性設計](#包容性設計)
- [RTL 語言支援](#rtl-語言支援)
- [測試檢核](#測試檢核)

## 核心原則

- 讓介面同時滿足三要件：**Intuitive**（熟悉一致的互動）、**Perceivable**（不依賴單一感官傳達資訊）、**Adaptable**（回應系統無障礙設定與個人化）。
- 優先使用系統標準元件：自動獲得 VoiceOver、Dynamic Type、Increase Contrast、RTL 鏡像等支援；自訂元件必須自行補齊這些行為。
- 開發過程用 Xcode 的 Accessibility Inspector 稽核；上架時在 App Store Connect 填寫 Accessibility Nutrition Labels（2025 年新增），如實標示支援的無障礙功能（VoiceOver、Larger Text、Captions 等）。
- 記住：障礙是光譜，且人人都會遇到暫時性（手受傷）與情境性（嘈雜車廂、烈日下）障礙——無障礙設計讓所有人受益。

## VoiceOver 支援

- 為所有關鍵介面元素提供描述性的 accessibility label。系統元件有預設 label，但要換成能表達「此元素在你的 App 中做什麼」的描述；自訂元件一律要加。介面改版時同步更新。
  - SwiftUI：`.accessibilityLabel()`、`.accessibilityValue()`、`.accessibilityHint()`、`.accessibilityAddTraits(.isButton)`。
- 描述有意義的圖片與圖表：只描述圖片本身傳達的資訊，不重複周邊 caption 已說的內容。圖表提供簡明摘要；若圖表可互動取得更多資訊，這些互動也要開放給 VoiceOver（Audio Graphs / `AXCustomContent`）。
- 排除純裝飾性圖片，避免浪費使用者時間、增加認知負擔。SwiftUI：`.accessibilityHidden(true)` 或 `Image(decorative:)`。
- 用唯一的頁面標題與正確的 section heading 建立資訊階層——標題是輔助技術進入頁面後唸出的第一個資訊。SwiftUI：`.accessibilityAddTraits(.isHeader)`。
- 群組相關元素、控制遍歷順序：VoiceOver 依語言閱讀順序（如英文為由上到下、由左到右）逐一朗讀。圖片與其 caption 若未群組，會先唸完所有圖片才唸 caption，破壞語意。
  - SwiftUI：`.accessibilityElement(children: .combine)` 群組、`.accessibilitySortPriority()` 調整順序。
- 對僅以視覺呈現的手勢操作（如 swipe to delete）提供自訂 actions，讓 VoiceOver 使用者不必模擬手勢。SwiftUI：`.accessibilityAction(named:)`。
- 畫面內容或版面變動時通知 VoiceOver，讓使用者更新心智模型。SwiftUI：`AccessibilityNotification.LayoutChanged().post()` / `.ScreenChanged`。
- 支援 VoiceOver rotor：標示 headings、links 等內容型別，讓使用者用 rotor 快速跳轉。SwiftUI：`.accessibilityRotor()`。
- 常見錯誤：只有 icon 的按鈕沒有 label；label 裡重複寫「按鈕」（trait 已表達）；把整個複雜畫面 combine 成單一元素導致無法操作。

## Dynamic Type 與文字

- 支援全部 Dynamic Type 尺寸：iOS/iPadOS 有 7 個標準尺寸（xSmall–xxxLarge，預設 Large）加 5 個 accessibility sizes（AX1–AX5）。目標是讓文字可放大至少 200%。
  - SwiftUI：使用 `Font` text styles（`.body`、`.headline`⋯）自動縮放；自訂數值用 `@ScaledMetric`；custom font 用 `Font.custom(_:size:relativeTo:)`。
- 遵守建議字級：iOS/iPadOS 預設 17 pt、最小 11 pt。細字重（thin）要用更大字級補償易讀性。
- 版面必須適應所有字級：在「設定 > 輔助使用 > 顯示與文字大小 > 放大文字」開啟 Larger Accessibility Text Sizes 實測。
- 盡量避免截斷：在最大 accessibility 尺寸下顯示的有用文字量，要與最大標準尺寸相當。label 設定為可多行顯示，不要固定行數。SwiftUI：避免 `.lineLimit(1)` 搭配長文字；避免用 `.minimumScaleFactor` 縮字充當支援。
- 大字級時調整版面：水平空間不足時，把「icon＋文字＋時間戳」的 inline 排列改為堆疊（文字在上、次要項目在下）；減少多欄排版的欄數。SwiftUI：`@Environment(\.dynamicTypeSize)` 搭配 `dynamicTypeSize.isAccessibilitySize` 切換 `HStack`/`VStack`（或用 `ViewThatFits`）。
- 有意義的 interface icon 要隨字級放大；SF Symbols 搭配 text style 會自動縮放。
- 字級再大也要維持一致的資訊階層：主要元素保持在畫面上方，別讓使用者迷失。
- 對不隨 Dynamic Type 放大的 bar button 等小控制項，支援 Large Content Viewer。SwiftUI：`.accessibilityShowsLargeContentViewer()`。
- 自訂字型要實作與系統字型相同的行為：支援 Dynamic Type、回應 Bold Text 設定。
- 常見錯誤：寫死 `Font.system(size: 14)` 不縮放；只測到 xxxLarge 就停，沒測 AX1–AX5；用 `.dynamicTypeSize(...DynamicTypeSize.large)` 之類的上限封頂來「修」版面問題——應改版面而非限制使用者字級。

## 色彩與對比

- 達到 WCAG Level AA 最低對比（Accessibility Inspector 以此判定）：

  | 文字尺寸 | 字重 | 最低對比 |
  |---|---|---|
  | ≤ 17 pt | 全部 | 4.5:1 |
  | ≥ 18 pt | 全部 | 3:1 |
  | 全部 | Bold | 3:1 |

- 用標準對比計算器驗證（WCAG contrast ratio 或 APCA）；Accessibility Inspector 依上表 WCAG Level AA 判定。
- 若預設配色達不到，至少在 Increase Contrast 開啟時提供高對比配色。Light / Dark 兩種外觀都要驗證對比。
- 優先使用系統定義顏色（如 `Color.accentColor`、semantic colors）：內建 accessible 變體，會隨 Increase Contrast 與 Light/Dark 自動調整。
- 不要只靠顏色傳達資訊：紅綠、藍橘等配對對色盲者難以區分。狀態與功能差異要另附形狀、icon 或文字指示。SwiftUI：`@Environment(\.accessibilityDifferentiateWithoutColor)`。
- 考慮讓使用者自訂色彩配置（圖表顏色、遊戲角色），依自身舒適度個人化。
- 色彩有強烈文化意涵（如白色在不同地區分別聯想到純潔或喪葬），在地化時確認顏色在各 locale 傳達相同訊息。

## 顯示與動態設定的因應

- **Reduce Motion**：開啟時減少自動與重複性動畫（zoom、scale、周邊動態）。具體做法：收緊 spring 減少彈跳、動畫直接跟隨手勢、避免 z 軸深度變化動畫、將 x/y/z 軸位移轉場改為 fade、避免進出 blur 的動畫。
  - SwiftUI：`@Environment(\.accessibilityReduceMotion)`，為 true 時以 fade 或無動畫替代。
- **Reduce Transparency / Increase Contrast 與 Liquid Glass**（iOS 26 引入的系統材質）：Liquid Glass 的外觀會回應這些設定自動調整——前提是使用系統元件或系統材質 API，不要自製半透明效果。
  - Liquid Glass 只用於控制與導覽層（tab bar、sidebar 等浮在內容上的功能層），不要用在內容層；內容層用 standard materials。
  - 自訂元件套用 Liquid Glass 效果要節制，只留給最重要的功能元素。SwiftUI：`.glassEffect()`。
  - `regular` 變體會模糊並調整背景亮度以維持文字易讀，用於文字量大的元件（alert、sidebar、popover）；`clear` 變體高度透明，只用於覆蓋在照片、影片等視覺豐富背景上的元件，且背景偏亮時要加一層約 35% 不透明度的黑色 dimming layer 確保對比。
  - 在 material 上一律使用系統 vibrant colors 確保各種背景下的易讀性；不要依 material 呈現出的顏色挑選材質（系統設定會改變其外觀），要依語意用途選擇。
  - SwiftUI：`@Environment(\.accessibilityReduceTransparency)`、`@Environment(\.colorSchemeContrast)`。
- **Bold Text**：自訂字型與自訂繪製文字也要回應。
- **Dim Flashing Lights**：影片播放要回應此設定，減緩亮光頻閃。
- **Animated Images 關閉時**：暫停 App 內動圖（GIF 等）的自動播放。SwiftUI：`@Environment(\.accessibilityPlayAnimatedImages)`。

## 觸控目標與手勢

- 觸控目標預設 **44x44 pt**，最小不低於 28x28 pt（iOS/iPadOS）。視覺可以更小，但可點擊範圍要補足。SwiftUI：以 padding 加 `.contentShape(Rectangle())` 擴大 hit area，不必放大視覺。
- 間距與尺寸同等重要：有 bezel 的元素周圍留約 12 pt padding；無 bezel 的元素可見邊緣周圍留約 24 pt，降低誤觸。
- 常用互動使用最簡單的手勢；避免自訂多指、多手手勢。
- 手勢一律提供替代路徑：core functionality 必須有一種以上的實體互動方式。例如 swipe 刪除之外，同時提供 Edit 模式下可點按的刪除按鈕。
- 避免覆寫系統手勢與系統鍵盤快捷鍵。

## Switch Control、Full Keyboard Access 與其他輔助技術

- **Switch Control**：讓使用者透過外接開關、遊戲控制器或聲音（彈舌聲等）操作裝置。確保所有可互動元素都能被聚焦與觸發——正確標記 accessibility elements 即可獲得大部分支援。
- **Full Keyboard Access**：確保只用實體鍵盤就能完整導覽與操作 App。逐一驗證焦點可到達每個互動元素、焦點順序合理、無鍵盤陷阱。SwiftUI：`.focusable()`、`@FocusState`。
- **Voice Control**：使用者以語音點按、輸入。元素 label 要與可見文字一致，語音才叫得到。
- 整合 Siri 與 App Intents（Shortcuts），讓重複性任務可純語音完成。
- 也要相容 AssistiveTouch、Pointer Control、Dwell Control；實機開啟這些功能逐一測試。

## 聽覺與認知

- 音訊資訊一律有文字替代：captions（與媒體同步的聽覺資訊文字）、subtitles（對白翻譯）、audio descriptions、transcripts，並允許自訂文字外觀。
- 音效提示（成功音、錯誤音）配上對應 haptics 與視覺指示，照顧聽不到或關閉音訊的使用者。SwiftUI：`.sensoryFeedback()`。
- iOS/iPadOS 支援 Music Haptics 與 Audio Graphs，讓人以振動與觸感體驗音樂與資訊圖表；重要內容發生在畫面外（遊戲、空間音訊）時，音訊引導要搭配指向目標的視覺指示。
- 避免自動播放音訊／影片；提供明顯的播放控制與全域關閉自動播放的選項。
- 減少限時自動消失的 UI（auto-dismiss toast、倒數視窗）：改用明確動作關閉，照顧需要較長閱讀時間與使用輔助技術的使用者。
- 支援 Assistive Access（iOS/iPadOS 認知輔助模式）：保留核心功能、移除非必要流程、每畫面聚焦單一互動、難以復原的動作（如刪除檔案）要求二次確認。
- 遊戲考慮提供難度調節：降低過關條件、調整反應時間、開啟操作輔助。

## 動態效果與暈眩考量

- 動畫要有目的，不為動而動；過度動畫使人分心、不適，甚至引發癲癇。
- 動態不可是傳達重要資訊的唯一管道：搭配 haptics 與 audio 作為替代回饋。
- 快速移動、閃爍、高頻重複的動畫要極度節制；使用者開啟 Reduce Motion 時必須降級（見上節具體做法）。
- 回饋動畫求短促精準：簡短、貼合動作的動畫比誇張動畫更有效也更不干擾。
- 高頻率互動的自訂元件避免附加動畫——系統已為標準元件提供恰當的細微動畫。
- 讓使用者能取消或跳過動畫，不要強迫等動畫播完才能操作，尤其是會重複遇到的動畫。
- SF Symbols 5+ 可使用符號動畫，但同樣受 Reduce Motion 約束。SwiftUI：`.symbolEffect()`。

## 包容性設計

- 用語直接、平實、respectful：直接以「you / 你」稱呼使用者，避免「the user」；「we / 我們」保留給公司或產品自稱。
- 避免俚語、雙關、文化限定的比喻與幽默——難翻譯、可能有排他甚至冒犯的源頭；專業術語必先定義。
- 性別中立：改寫句子避免不必要的 he/she（用複數或第二人稱）；泛指人物的 avatar、glyph 用非性別化圖像（SF Symbols 的 `person.crop.circle`、`figure.wave` 等）；必須蒐集性別時提供 nonbinary、self-identify、decline to state 選項，並考慮讓使用者指定 pronouns。
- 影像呈現多元的人群：不同族裔、體型、年齡、身體能力，包含身心障礙者；避免職業與角色的刻板印象（如只有男醫師、女護理師）、避免預設特定家庭組成或富裕場景。
- 撰寫身心障礙相關文字採 people-first：先講人與其目標，再提及障礙；避免用障礙表達負面意涵。
- 安全問題、範例情境避免文化與能力預設（如「你的第一輛車」），改用普遍的人類經驗。
- 及早 internationalization：平實語言、性別中立、避免文化限定內容，本身就是對在地化最好的準備。

## RTL 語言支援

- 使用系統 UI framework 與標準版面，介面在 RTL context（阿拉伯文、希伯來文）自動鏡像；用 leading/trailing 而非 left/right 思考。SwiftUI：`HStack`、alignment 的 `.leading/.trailing` 天然支援；用 `@Environment(\.layoutDirection)` 做精修。
- 文字對齊隨介面方向翻轉；但**三行以上的段落依其語言對齊**（LTR 文字的段落即使在 RTL context 也維持靠左），一、兩行的短文字依 context 對齊；清單內所有項目用一致的對齊。
- 數字不鏡像：具體數值（541、電話、卡號）的位數順序永遠不變。表達進度或計數方向的數列要反轉排列順序，但數字本身絕不翻轉。
- 控制項：進度條、slider、rating 等表達進度的控制要鏡像，兩端的圖示位置也要對調；back 按鈕在 RTL 指向右；但指涉實際方向或畫面區域的控制（「向右移」）永遠不鏡像。
- 圖片：照片、插圖、一般 artwork 不要翻轉（可能改變語意、侵犯版權）；但多張圖片若順序有意義（時間序、排名），要反轉排列位置。
- SF Symbols 內建 RTL 變體與阿拉伯文／希伯來文在地化符號，優先使用；自訂 symbol 可指定 directionality。SwiftUI：`Image` 搭配 SF Symbols 自動處理；自製圖不需鏡像時用固定方向資產。
- 該翻的 icon：表示文字對齊方向的（左對齊線條圖）、表示前進／後退動態的（喇叭聲波方向）。不該翻的：logo、勾選記號等 universal 符號、時鐘等真實物件、右手工具的傾斜角度。
- 阿拉伯文／希伯來文與全大寫拉丁字並排時視覺偏小，可將 RTL 文字字級調大約 2 pt 取得平衡。
- 常見錯誤：用 `.offset` 或絕對座標排版讓元素不隨 RTL 鏡像；為了「看起來一樣」強制整個介面維持 LTR。

## 測試檢核

- Accessibility Inspector 稽核每個畫面（含 contrast 檢查）。
- 實機開啟逐項測試：VoiceOver、Larger Accessibility Text Sizes（到 AX5）、Reduce Motion、Reduce Transparency、Increase Contrast、Bold Text、Switch Control、Full Keyboard Access、Voice Control。
- Light / Dark、LTR / RTL、標準與 accessibility 字級的組合都要驗證版面不截斷、不重疊。
- App Store Connect 的 Accessibility Nutrition Labels 與實際支援一致。
- 從設計階段就納入無障礙考量，不要當成上架前的補救工作。
