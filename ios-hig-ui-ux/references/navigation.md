# 導航、搜尋與模態呈現（HIG 最佳實踐）

依據 Apple Human Interface Guidelines 官方內容整理（含 iOS 26 Liquid Glass 與 2026-06 系列更新）。聚焦 iOS / iPadOS。

## 目錄

- [導航架構設計](#導航架構設計)
- [Tab Bars](#tab-bars)
- [Sidebars 與 iPad 適配](#sidebars-與-ipad-適配)
- [搜尋體驗](#搜尋體驗)
- [Modality 原則](#modality-原則)
- [Sheets](#sheets)
- [Popovers](#popovers)
- [Alerts](#alerts)
- [Action Sheets](#action-sheets)
- [Page Controls](#page-controls)
- [常見錯誤速查](#常見錯誤速查)

## 導航架構設計

- 先決定資訊架構是 flat（少數平行頂層區塊）還是 hierarchical（多層深入）：flat 用 tab bar；hierarchical 用 navigation stack 逐層推進；內容集合型（資料夾、播放清單）在 iPad 用 sidebar + split view。
- 以「使用頻率」權衡層級複雜度：人越常切換的區塊放頂層；越少 tab 越好導航。
- 結構複雜的 App 不必二選一：使用可在 tab bar 與 sidebar 之間轉換的 adaptable 樣式（見下文 iPad 段落）。
- 層級深的 App 可在單一 tab 內放 sidebar 做次級導航，但 sidebar 的選取不可切換當前 tab。
- SwiftUI：`TabView`、`NavigationStack`、`NavigationSplitView`。

## Tab Bars

- 用 tab bar 做「導航」，不要放 actions；作用於當前畫面元素的控制項改放 toolbar。
- 保持 tab bar 永遠可見；唯一例外是 modal view 暫時覆蓋。隱藏 tab bar 會讓人忘記自己在 App 的哪個區域。
- 控制 tab 數量，避免溢出成 More tab（iOS/iPadOS 空間不足時尾端會變 More，藏起來的 tab 難以觸及）。若區塊太多，改用 sidebar 或 adaptable tab bar。
- 不要 disable 或隱藏任何 tab，即使內容暫不可用——改在該區塊內說明為何是空的。不穩定的 tab bar 讓 App 顯得不可預測。
- 每個 tab 都給 label，盡量單一詞彙；icon 優先用 SF Symbols 的 filled 樣式，會自動適配 compact/regular 佈局。
- Badge（紅色橢圓數字/驚嘆號）只保留給關鍵資訊，濫用會稀釋意義。
- iOS 26+：tab bar 浮動（floating）於畫面底部內容之上，項目坐落在 Liquid Glass 背景上、底下內容可透出。若 tab label 顏色與內容層背景色相近，改用 monochromatic 外觀或選對比足夠的 accent color。
- iOS 26+ 最小化行為：tab bar 附掛 accessory（如 Music 的 MiniPlayer）時，可設定捲動向下時 tab bar 最小化、accessory 併入同列；點 tab 或捲回頂部即還原。
- iOS 26+ search tab：tab bar 尾端可放專用的 search tab（詳見「搜尋體驗」）。
- SwiftUI：`TabView`、`Tab`、`.tabBarMinimizeBehavior(_:)`、`.tabViewBottomAccessory`。

## Sidebars 與 iPad 適配

- iPadOS 的 tab bar 顯示在畫面頂部附近，可設為固定，或附一顆按鈕讓使用者把它轉成 sidebar（adaptable 樣式）。兩種型態都保留切換按鈕，並自動因應旋轉與視窗縮放。
- 優先考慮 tab bar：它留給內容更多空間，足以應付多數 App 的主要區塊；需要曝露更多次要區塊時，才靠可轉換的 sidebar 承接。
- 只想要 sidebar、不要轉換行為時，用 `NavigationSplitView` 而非 tab view。
- Liquid Glass：sidebar 浮在內容之上；用內容水平捲動穿過底下，或用 background extension effect（鏡射相鄰內容 + 模糊）強化層次。SwiftUI：`.backgroundExtensionEffect()`。
- Sidebar 層級最多兩層；更深的資料層級改用三欄 split view（sidebar → content list → detail）。
- 內容多時用 disclosure controls 分組收合；群組標題要簡短、具描述性。
- 允許使用者自訂 sidebar 內容與排序（tab bar 亦同；若可自訂，預設項目以五個以內為佳，維持 compact/regular 連續性）。
- 允許以平台慣用手勢隱藏 sidebar（iPadOS 為 edge swipe），但不要預設隱藏，以免不可發現。
- Sidebar icon 預設吃 App 的 accent color；固定色只保留給有明確語意的少數項目（如 Mail 的 VIP 黃色）。
- SwiftUI：`TabView` + `.tabViewStyle(.sidebarAdaptable)`、`NavigationSplitView`。

## 搜尋體驗

- 搜尋重要就給它一級位置：Notes 把 search field 放底部 toolbar；Photos、TV 用專屬 search tab。
- 盡量提供單一搜尋入口搜遍全 App 內容；區塊分明的 App 可另設區域性搜尋（如 Music 資料庫內的 filter）。
- 明確顯示當前搜尋範圍：用 placeholder 文字、scope bar 或標題提示正在搜什麼（如 Mail 永遠標示搜尋中的信箱）。
- 盡可能邊打字邊出結果（live search）；顯示最近搜尋與預測性 suggestions 減少打字。展示搜尋歷史前考慮隱私，並提供清除方式。
- 結果依相關性排序、必要時分類；提供 scope bar 讓人事後過濾結果。scope 預設用較廣範圍，讓人再收窄。
- Token：把常用搜尋條件變成可選取、可編輯的視覺單元（如 Mail 依聯絡人過濾）；搭配 suggestions 幫助使用者發現可用的 token。
- iOS 搜尋入口三選一：
  - **Search tab（tab bar 內）**：standard 樣式點擊後進入搜尋 landing page，適合想促進探索、展示分類與推薦內容的 App（如 Apple TV）；button appearance 樣式點擊立即聚焦 search field 並升起鍵盤，屬暫態體驗、退出後回到前一個 tab，適合要快速找到東西的場景。
  - **Toolbar**：優先放底部（易觸及，如 Settings、Mail、Notes）；當底部內容不可遮擋（如 Wallet 的票卡堆疊）或沒有底部 toolbar 時放頂部 navigation bar。
  - **Inline field**：與被搜尋內容相鄰擺放，表達「只過濾這個 view」的區域性搜尋；置於清單上方，捲動時考慮 pin 在頂部 toolbar。
- iPadOS/macOS 保持一致：一般情況把 search field 放 toolbar trailing 端（適合跨欄搜尋的 split view App）；過濾 sidebar 導航內容時放 sidebar 頂部（如 Settings）；探索型搜尋給專屬區域（tab/sidebar item）。
- 專屬搜尋區域可在進入時自動 focus search field；例外：iPad 只有虛擬鍵盤時保持未聚焦，避免鍵盤突然蓋住畫面。
- SwiftUI：`.searchable(text:)`、`.searchScopes(_:scopes:)`、`.searchSuggestions {}`、`Tab(role: .search)`。

## Modality 原則

- 對 modal 保持克制：只有在幫助聚焦、確認關鍵決定、或執行一段獨立小任務時才用。Modal 會打斷情境、且需要明確動作才能離開。
- Modal 任務要簡單、簡短、流線化；避免做成「App 中的 App」。若 modal 內必須有子畫面，只給單一路徑走完，避免出現會被誤認為 dismiss 的按鈕。
- 深度內容或多步驟複雜任務（看影片、相機、文件標註、照片編輯）用 full-screen modal 樣式減少干擾；否則用 sheet。
- 永遠給明顯的 dismiss 途徑：iOS/iPadOS 慣例是頂部 toolbar 按鈕或下滑手勢。
- 關閉可能造成使用者內容遺失時，先確認：用 action sheet 提供儲存/放棄/繼續編輯等選項，而不是直接關閉。
- 給 modal view 明確的標題描述其任務，幫助使用者記住自己在哪。
- 一次只呈現一個 modal view；要開新的先關舊的。Alert 可以蓋在一切之上，但同時永遠只顯示一個 alert。
- SwiftUI：`.sheet(isPresented:)`、`.fullScreenCover(isPresented:)`。

## Sheets

- Sheet 用於與當前情境緊密相關的 scoped task（補資訊、選位置、附加檔案）；複雜或長流程改用 full-screen modal（或 iPad 另開視窗的情境）。
- iOS/iPadOS 的 sheet 可為 modal 或 nonmodal：nonmodal sheet 讓人不關閉 sheet 就能繼續操作父畫面（如 Notes 的文字格式面板）——適合「邊調整邊看主畫面效果」的輔助工具。
- 按鈕語意與擺位（2026-03 更新的官方規範）：
  - **Cancel/Close**（不存變更關閉）放頂部 toolbar leading 端；**Done**（完成/儲存後關閉）放 trailing 端。
  - 多步驟流程：第一步 leading 放 Cancel、trailing 放 inactive 的 Done；後續步驟以 **Back** 取代 Cancel；最終確認步驟 Done 轉為 active。
  - 有 Done 就必須搭配 Cancel 或 Back，別讓「完成任務」成為唯一出口；避免 Cancel、Done、Back 三顆同時出現。
- Detents（iPhone）：系統定義 `large`（全高）與 `medium`(約半高)，可自訂高度。內容適合漸進揭露就支援 medium（如 share sheet）；需要完整空間創作的（Messages/Mail 撰寫）只用全高。
- 可調高度的 sheet 要顯示 grabber：提示可拖曳、可點擊循環切換 detents，並支援 VoiceOver。
- 支援下滑手勢 dismiss；若有未儲存變更，下滑時用 action sheet 確認。
- 同一時間只顯示一張 sheet；sheet 內的操作要開新 sheet，先關第一張。
- iPadOS 優先用 page 或 form sheet 樣式：內容置中於變暗的背景之上，體驗一致。
- SwiftUI：`.sheet(isPresented:)`、`.presentationDetents([.medium, .large])`、`.presentationDragIndicator(.visible)`。

## Popovers

- Popover 是暫態視圖，用於曝露少量資訊或功能（如行事曆事件的快速編輯）；互動完即消失。
- iOS（compact 尺寸）避免用 popover——compact view 改用 sheet 等全寬 modal；popover 保留給 iPad 的 regular 寬度與 macOS。依 size class 動態切換佈局。
- 箭頭盡可能直指觸發它的元件，且不要遮住觸發元件或使用時需要看到的內容。
- 一般點擊 popover 外部即關閉；只有在需要「存或不存」這類明確結果時才放 Close/Cancel/Done。支援多選時保持開啟直到明確關閉。
- Nonmodal popover 被點外部關閉時一律自動儲存工作；只有明確按 Cancel 才丟棄。
- 一次只顯示一個 popover；絕不讓 popover 疊出另一個 popover，也不要在 popover 上蓋其他 view（alert 除外）。
- 不要用 popover 顯示警告——會被錯過或誤關，警告用 alert。
- 大小剛好容納內容即可；condensed/expanded 兩態切換時用動畫過渡。
- SwiftUI：`.popover(isPresented:attachmentAnchor:)`（compact 環境會自動退化為 sheet）。

## Alerts

- Alert 傳達「需要立即知道的關鍵資訊」，要省著用；純資訊、不需行動的內容改在情境內呈現（如 Mail 的連線狀態指示器）。
- 常見且可 undo 的破壞性動作（刪一封信、刪一個檔）不要跳 alert；只有「不常見 + 不可復原」的破壞性動作才需要確認。
- 避免 App 啟動時跳 alert；啟動時偵測到問題（如無網路）用快取內容 + 非侵入式標示代替。
- 結構：標題（必要）+ 說明文字（選用）+ 最多三顆按鈕。標題明確描述發生什麼事，不要寫「Error」或錯誤碼；說明文字只在有增量價值時加，保持簡短完整句。
- 按鈕文字用一到兩個動詞（View All、Reply、Delete），title-style capitalization、無句尾標點。避免用「OK」當確認鈕（語意模糊），只有純資訊性 alert 可用 OK；取消一律叫「Cancel」。不用 Yes/No。
- 兩顆按鈕原則：預設（最可能選的）按鈕放 trailing 或堆疊頂部；Cancel 放 leading 或堆疊底部。有破壞性動作就必須有 Cancel 給人安全出口，且 Cancel 不可是 default button。
- Destructive style 用於「使用者並非蓄意選擇」的破壞性按鈕；使用者主動發起的動作（如自己按了清空垃圾桶）在確認 alert 中不必再標 destructive。
- 不要在文案中解釋按鈕功能；按鈕標題本身要自明。
- 標題保持一到兩行內，避免 alert 需要捲動。
- SwiftUI：`.alert(_:isPresented:actions:message:)`、`Button(role: .destructive)`、`Button(role: .cancel)`。

## Action Sheets

- 用 action sheet（SwiftUI 稱 confirmation dialog）回應「使用者主動發起」的動作並提供相關選擇；alert 則是非預期的問題通知。例：Mail 取消草稿時給「刪除草稿 / 儲存草稿」。
- 同樣要省著用——它也會打斷任務。
- 標題一行內；訊息非必要不加，情境 + 標題通常已足夠。
- 可能毀壞資料時提供 Cancel 按鈕，放在最底部；destructive 按鈕用 destructive style 並放在最頂部（最顯眼）。
- 含 Cancel 最多四顆按鈕（即最多三個實際選項）；避免讓 action sheet 需要捲動。
- 「回應動作的選擇」用 action sheet，不用 menu——menu 是使用者主動展開的，action sheet 是動作觸發的。
- SwiftUI：`.confirmationDialog(_:isPresented:titleVisibility:actions:)`；UIKit：`UIAlertController`（`.actionSheet`）。

## Page Controls

- Page control（一排指示點）只用於「有序、扁平、對等」的頁面清單；不表達層級或非線性關係——那種情境改用 sidebar 或 split view。
- 水平置中、固定在 view 底部；用於全螢幕頁面集合，頁面間不要塞其他控制項干擾焦點。
- 點數控制在約 10 個以內；更多對等頁面改用 grid 等可任意瀏覽的排列。
- 支援 tap（前後翻頁）與 scrub（按住左右拖曳快速跳頁）；scrub 過程不要播放翻頁動畫，只有 tap 用動畫。
- 自訂 indicator 圖示保持簡單（SF Symbols 佳）、最多兩種（如 Weather 的目前位置圖示）；不要自訂顏色，交給系統確保對比。
- 背景樣式：automatic（互動時才顯示）、prominent（永遠顯示，僅當它是畫面主要導航時）、minimal（永不顯示；使用 minimal 就不要支援 scrub，因為沒有視覺回饋）。
- SwiftUI：`TabView` + `.tabViewStyle(.page)`；UIKit：`UIPageControl`。

## 常見錯誤速查

| 錯誤 | 修正 |
|---|---|
| 把 action（新增、分享、設定）做成 tab | Action 放 toolbar；tab 只做導航 |
| 進入子頁面時隱藏 tab bar | 保持 tab bar 可見（modal 覆蓋除外） |
| 內容不可用時 disable/隱藏某個 tab | Tab 保持可見，區塊內說明為何為空 |
| 刪除單封信件/檔案時跳 alert 確認 | 可 undo 的常見動作直接執行，不確認 |
| 用 alert 顯示純資訊公告或啟動訊息 | 改為情境內指示器或可發現的內容 |
| Alert 按鈕用 OK/Yes/No | 用具體動詞（Delete、Save、Erase）+ Cancel |
| Sheet 只給 Done 一個出口 | 搭配 Cancel 或 Back；三顆不同時出現 |
| 一個 modal 疊另一個 modal/popover 疊 popover | 先關第一個再開下一個 |
| iPhone（compact）上用 popover | 改用 sheet；依 size class 切換 |
| 用 popover 或 sheet 顯示警告 | 警告一律用 alert |
| 搜尋入口藏在多層選單內 | 依重要性放 search tab、bottom toolbar 或 inline |
| Page control 超過 10 點或表達層級 | 改 grid / sidebar / split view |
