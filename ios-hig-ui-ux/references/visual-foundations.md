# 視覺基礎：色彩、深色模式、字型排印、圖示與品牌

依據 Apple HIG（2026-07 現行版，含 iOS 26 Liquid Glass 與後續調整）。聚焦 iOS/iPadOS。

## 目錄

- [色彩（Color）](#色彩color)
- [Liquid Glass 上的色彩](#liquid-glass-上的色彩)
- [深色模式（Dark Mode）](#深色模式dark-mode)
- [字型排印（Typography）](#字型排印typography)
- [SF Symbols](#sf-symbols)
- [介面圖示（Interface Icons）](#介面圖示interface-icons)
- [圖片資源（Images）](#圖片資源images)
- [App Icon](#app-icon)
- [品牌（Branding）](#品牌branding)
- [UX Writing](#ux-writing)

## 色彩（Color）

### System colors 與 semantic colors

- 優先使用 system colors 與 dynamic system colors：自動適配 light/dark、Increase Contrast、vibrancy。SwiftUI：`Color.blue`、`Color(.systemBackground)`、`Color(.label)`。
- 背景色依層級選用：非 grouped 介面用 `systemBackground` / `secondarySystemBackground` / `tertiarySystemBackground`；grouped（inset）列表用 `systemGroupedBackground` 系列。primary 給整個 view、secondary 給群組、tertiary 給群組內的群組。
- 前景色用 semantic colors：`label` / `secondaryLabel` / `tertiaryLabel` / `quaternaryLabel`、`placeholderText`、`separator`（半透明）/ `opaqueSeparator`、`link`。
- 依語意使用，不要重新定義：不要拿背景色當文字色、文字色當背景色。
- 避免 hard-code 系統色的 RGB 值——實際值會隨版本浮動。一律走 API 取色。
- 同一顏色只表達一種語意：用品牌色標示可互動元素後，就不要再用相近色裝飾不可互動的文字。
- 不要只靠顏色傳達資訊（狀態、互動性）：搭配文字標籤或形狀，照顧色盲使用者。
- 考量文化差異：紅色在部分文化是危險、在部分文化是正面（如中文股市紅漲綠跌）。
- 讓使用者挑顏色時，優先用系統提供的 color picker（`ColorPicker`）。
- App accent color 統一以 `.tint(_:)`（或 asset catalog 的 AccentColor）設定，讓系統元件一致取用。

### 自訂色

- 自訂色一律在 asset catalog 建 Color Set，提供 light/dark 兩個 variant，並為兩者各提供 Increase Contrast 版本。即使 App 鎖定單一外觀，也要提供 light/dark 配對——Liquid Glass 的自動適配需要它。
- 對比下限：前景與背景對比至少 4.5:1；自訂色（尤其小字）以 7:1 為目標。
- 在不同光線與裝置（True Tone、sRGB/P3 顯示器）下實測色彩方案。
- Wide color：需要更飽和的色彩時用 Display P3（16 bits/channel、輸出 PNG）；P3 漸層在 sRGB 螢幕可能斷階，必要時在 asset catalog 提供 sRGB/P3 各自的版本。
- 圖片一律內嵌 color profile，確保跨顯示器色彩一致。

## Liquid Glass 上的色彩

- Liquid Glass 預設無固有色，從背後內容取色；小型元素（toolbar、tab bar）會依底層內容自動在明暗外觀間切換，其上的 symbol 與文字預設走 monochromatic（底層亮則變深、底層暗則變亮）。不要對抗這個機制。
- 極度節制地為 Liquid Glass 上色：只保留給真正需要強調的元素（primary action、狀態指示）。強調主要動作時，把色彩放在按鈕「背景」（如 prominent 的 Done 按鈕），而不是 symbol 或文字上。SwiftUI：`.buttonStyle(.glassProminent)`、`.tint(_:)`。
- 避免同一介面多顆控制項都上色背景——一個畫面通常只有一個著色的 primary action。
- 內容背景彩色或視覺豐富時，toolbar/tab bar 維持 monochromatic，或選對比足夠的 accent color；內容偏單色時，才適合以品牌色作為 app accent color。
- 注意 content layer 與控制項的色彩重疊：捲動內容的預設／靜止狀態（如頁面頂端）必須維持控制項清晰可讀。

## 深色模式（Dark Mode）

- 不要提供 App 內專屬的外觀切換設定：跟隨系統 light/dark/Auto。使用者會把不跟隨系統的 App 當成壞掉。（少數例外：沉浸式媒體 App 可鎖定 dark-only，如 Stocks。）
- 深色不是亮色的反轉：Dark Mode 用更暗的背景、更亮的前景。用 semantic colors 讓系統處理，避免手動反色。
- Dark Mode 有 base 與 elevated 兩組背景：前景介面（sheet、popover、多工並排）自動用較亮的 elevated 色以呈現層次。用系統背景色才能免費獲得這個行為；自訂背景色會破壞它。
- 文字用系統 label 色階、輸入框用系統元件（`TextField`、`Text`），自動處理 vibrancy 與對比。
- 圖片與圖示：full-color 圖在兩種外觀下都要檢查；不佳者在 asset catalog 內以同名 image set 提供 light/dark 兩個資產。含白底的內容圖在 Dark Mode 可稍微壓暗避免刺眼。必要時為淺色外觀的圖示加細邊、深色外觀去邊。
- 測試：開啟 Increase Contrast 與 Reduce Transparency（分開與同時）檢查深色下的可讀性。
- SwiftUI：semantic colors 自動適配；自訂色用 asset catalog Color Set 或 `Color(uiColor:)` 包 dynamic UIColor。

## 字型排印（Typography）

### SF Pro 與最小字級

- iOS/iPadOS 系統字型是 SF Pro（另有 serif 的 New York 可用）。用 API 取得系統字型，不要內嵌 SF 字型檔。SwiftUI：`.font(.body)`、`.fontDesign(.serif)`、`.fontDesign(.rounded)`。
- 內文預設 17pt；任何文字不得小於 11pt（iOS/iPadOS）。
- 避免 Ultralight、Thin、Light 字重：小字尤其難讀。UI 文字用 Regular／Medium／Semibold／Bold。
- 少用多種字體：typeface 過多會破壞層級、顯得雜亂。

### Text styles（必用）

- 一律用內建 text styles 建立層級，不要手填 point size：Large Title(34)、Title 1(28)、Title 2(22)、Title 3(20)、Headline(17 Semibold)、Body(17)、Callout(16)、Subhead(15)、Footnote(13)、Caption 1(12)、Caption 2(11)（Large 預設級距）。SwiftUI：`.font(.largeTitle)` … `.font(.caption2)`。
- 需要再多一層層級時，用 symbolic traits 修飾（如加粗、調 leading），不要另起爐灶。SwiftUI：`.bold()`、`.fontWeight(.semibold)`。
- 三行以上的文字避免 tight leading。

### Dynamic Type

- 使用 text styles + 系統字型即自動支援 Dynamic Type 與 accessibility sizes（AX1–AX5）。這是硬性要求，不是選配。
- 驗證版面在所有字級下可用：開啟「較大輔助使用字體」實測；大字級時考慮改用堆疊版面（文字在上、次要元素在下）、減少欄數。
- 盡量不截斷：最大輔助字級下顯示的有用文字量，應接近最大標準字級下的量；label 允許多行。
- 有意義的圖示要跟著字級縮放：SF Symbols 自動隨 Dynamic Type 縮放；自訂尺寸用 `@ScaledMetric`。
- 不要用 `.dynamicTypeSize(...)` 把字級鎖死來「修」版面問題——先修版面；限制範圍是最後手段。
- 分優先級縮放：使用者要放大的是主要內容，tab 標題、暫態數值不必等比放大；任何字級下維持相同的資訊層級與位置。

### 自訂字型

- 自訂字型必須支援 Dynamic Type 與 Bold Text 等輔助功能。SwiftUI：`Font.custom(_:size:relativeTo:)` 綁定 text style。
- 確保各字級可讀；細字重的自訂字型要用比建議值更大的尺寸。品牌字型建議只用於標題，內文與小字回落系統字型。

## SF Symbols

- 需要圖示先找 SF Symbols（SF Symbols app 瀏覽），與 SF 字型自動對齊、隨字級縮放。SwiftUI：`Image(systemName: "cloud.sun.rain")`。
- Weights 與 scales：九種字重對應 SF 字重——symbol 字重與相鄰文字一致；三種 scale（small/medium/large）在不動字重配對的前提下調整 symbol 相對於文字的份量。SwiftUI：`.fontWeight(.semibold)`、`.imageScale(.large)`。
- Rendering modes：monochrome（單色）、hierarchical（單色多不透明度、有層次感）、palette（每層一色）、multicolor（固有色）。用系統色上色可自動適配 Dark Mode 與 vibrancy。SwiftUI：`.symbolRenderingMode(.hierarchical)`、`.foregroundStyle(.blue, .gray)`。
- 逐一確認 rendering mode 在實際尺寸與背景下清晰；automatic 給的是偏好值，不保證最佳。
- SF Symbols 7（iOS 26 世代）新增：gradient rendering（單一來源色生成線性漸層，大尺寸較佳）、Draw On/Draw Off 動畫、Variable Draw、Magic Replace 強化。
- Variable color 只用來表達「會變的量」（音量、訊號、進度），不要拿來表達深度；深度用 hierarchical。
- Variants：outline 用於 toolbar、與文字並列處；fill 用於 tab bar、swipe action、選取狀態。多數系統容器會自動挑 variant（tab bar 自動用 fill），不必手動指定；用 `.symbolVariant(_:)` 覆寫。slash 表示不可用、enclosed（圓/方框）提升小尺寸可讀性。
- 動畫節制且有目的：bounce 回饋動作、pulse/breathe 表示進行中、replace 表示狀態切換、wiggle 提醒。SwiftUI：`.symbolEffect(.bounce)`。
- 自訂 symbol：從相近的官方 symbol 匯出 template 修改，維持一致的細節量、光學字重與透視；annotate 各層供 rendering mode 與動畫使用；有 badge 的 symbol 用 negative side margins 做光學對齊。不要重製既有 variant（fill、slash 系統會處理）、不要複製 Apple 產品圖形、不要把 symbol 用於 app icon 或 logo（授權禁止）。
- 為每個 symbol 提供 accessibility label（自訂 symbol 尤其必要）。

## 介面圖示（Interface Icons）

- 高度簡化、一眼可辨：用與動作直接相關的熟悉隱喻，避免細節過多。
- 全 App 圖示視覺一致：同樣的尺寸、細節量、線寬（stroke weight）、透視；圖示字重與相鄰文字字重一致。
- 不對稱圖示做光學置中：把偏移量做進資產的 padding，讓幾何置中即光學置中。
- 不必提供 selected 狀態版本：tab bar、toolbar 等系統元件自動處理選取外觀。
- 自訂圖示用向量格式（PDF/SVG）並在 asset catalog 勾 Preserve Vector Data，或做成自訂 SF Symbol。
- 圖示含文字時務必 localize；表示文句方向的圖示提供 RTL 翻轉版。避免 Apple 硬體外觀。
- 每個自訂圖示都要有 accessibility label。

## 圖片資源（Images）

- 所有點陣圖依裝置提供對應 scale factors：iOS 需 @2x 與 @3x；iPadOS @2x。放進 asset catalog，檔名綴 `@2x`/`@3x`。
- 格式選擇：點陣／raster 用去交錯 PNG；照片用 JPEG（適度壓縮）或 HEIC；扁平圖示與向量圖用 PDF/SVG。
- 以最低解析度設計再放大輸出高解析資產；向量控制點對齊整數格點，@2x/@3x 才不會糊邊。
- 每張圖內嵌 color profile；在真機上測試（設計稿上好看的圖，實機可能模糊或變形）。
- 需依外觀變化的圖，在同一個 image set 內提供 light/dark 資產（見深色模式一節）。

## App Icon

- 版式：iOS/iPadOS 提供 1024×1024 px 的方形「未遮罩」圖層——系統負責裁出與裝置邊框同心的圓角。不要自行預先遮罩或加圓角，會破壞 specular highlight 並產生鋸齒。
- iOS 26+ 採 layered icon：一個 background layer 加一個以上 foreground layers，系統套用 Liquid Glass 效果（specular highlights、refraction、translucency），並隨尺寸與系統版本動態調整。
- 用 Icon Composer（隨 Xcode 提供）組裝 iOS/iPadOS/macOS/watchOS icon：設定背景（建議直接用其內建純色或漸層，不必匯入背景圖）、調整前景層、標註 default/dark/mono 外觀、預覽並輸出。
- 六種外觀 variant：default、dark、clear light、clear dark、tinted light、tinted dark。可逐一自訂，未提供者由系統自動生成；各 variant 維持相同的核心視覺特徵，dark 版以 default 為基礎、選互補色、避免過亮影像。
- 圖層用向量（SVG/PDF），文字轉外框；mesh gradient 與 raster 素材用 PNG。前景層邊緣清晰、避免羽化；以不透明度變化增加層次。
- 讓系統上效果：不要自行烘焙高光、層間陰影、斜角、模糊、光暈——會與系統動態效果打架。
- 設計原則：極簡、一個核心概念、少量形狀；偏好插畫不用照片；不重製 UI 截圖；避免極細線與尖角；文字非必要不放（不支援輔助功能與在地化）；不用 Apple 硬體圖像；避免純黑背景（會與螢幕背景融在一起）。
- Alternate icons（App 內可選圖示）每一款都要提供自己的 dark/clear/tinted variants，且需通過 App Review。
- 色彩空間：sRGB 或 Display P3。

## 品牌（Branding）

- 品牌永遠讓位給內容：不要用純品牌展示元素佔據螢幕空間；以精緻、不干擾的方式融入。
- 表達品牌的正道：app accent color（單一、對比足夠）、品牌語氣的文案、標題用品牌字型（內文回落系統字型）。
- 不要在 App 內到處放 logo——使用者不需要被提醒在用哪個 App。
- 不要把 launch screen 當品牌版位：它消失得太快；要展示品牌改用歡迎／onboarding 畫面。
- 高度風格化的介面仍要維持標準行為：元件放在預期位置、常見動作用標準 symbol。
- 遵守 Apple 商標規範：App 名稱與圖像不得出現 Apple 商標。

## UX Writing

- 先定義 voice（面向誰、想讓人有什麼感受），依情境調整 tone（錯誤訊息直接嚴肅、達成目標輕快祝賀）。
- 建立詞彙表並全 App 一致：同一概念永遠用同一個詞；選定 title case 或 sentence case 後每類元件一致套用。
- 精簡：每個字都要有存在理由；能用更少的字就用更少的字。用平實語言，避免行話與性別化用語。
- 按鈕與連結用動詞、行動導向：「Send」勝過「Let's do it!」；連結文字要有描述性，避免「Click here」（對 screen reader 尤其重要）。
- 多步驟流程用一致的推進詞：「Get Started」開場、「Continue」/「Next」擇一貫穿、「Done」收尾。
- 少用所有格代名詞（「Favorites」優於「Your Favorites」）；避免用「we」——「Unable to load content」勝過「We're having trouble loading this content」。
- 錯誤訊息：貼近問題處顯示、不責怪、說明怎麼修——「Choose a password with at least 8 characters」勝過「That password is too short」；不用「Oops!」這類感嘆詞。欄位提供 hint/placeholder 示範格式，錯誤就地顯示並用正向指令（「Use only letters」勝過「Don't use numbers」）。
- Empty state 給下一步：說明能做什麼並附按鈕或連結；不要在 empty state 放會消失的關鍵資訊。
- 用詞符合裝置：觸控裝置說「tap」不說「click」。
