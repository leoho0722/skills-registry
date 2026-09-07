# 常用 UI 元件選用與使用規範（HIG）

依據 Apple Human Interface Guidelines（Liquid Glass 世代，涵蓋 iOS 26/27 更新）。核心原則：**先選對元件，再談樣式**——每個系統元件都自帶使用者已知的語意與行為，誤用元件比醜的樣式更傷害體驗。聚焦 iOS/iPadOS。

## 目錄

- [快速選型對照表](#快速選型對照表)
- [Buttons](#buttons)
- [Menus](#menus)
- [Context Menus 與 Edit Menus](#context-menus-與-edit-menus)
- [Toolbars](#toolbars)
- [Labels](#labels)
- [Lists/Tables vs Collections](#liststables-vs-collections)
- [Pickers 與 Date Pickers](#pickers-與-date-pickers)
- [Segmented Controls](#segmented-controls)
- [Sliders vs Steppers](#sliders-vs-steppers)
- [Toggles](#toggles)
- [Text Fields](#text-fields)
- [Progress Indicators](#progress-indicators)
- [Charts（圖表）](#charts圖表)

## 快速選型對照表

| 需求 | 用 | 不要用 |
|---|---|---|
| 觸發一個動作 | Button | Toggle、Segmented control 當按鈕用 |
| 二元開／關狀態 | Toggle | 兩顆互斥按鈕 |
| 短清單選一（<5 項） | Menu / pull-down button | Picker（視覺重量過大） |
| 中長清單選一 | Picker | 一長串按鈕 |
| 超大量選項 | List（可加 index） | Picker |
| 2–5 個互斥視圖／屬性切換 | Segmented control | Tab bar（那是 app 層級導航） |
| 連續範圍取值 | Slider | Stepper |
| 小幅增減整數值 | Stepper（旁邊顯示值） | Slider |
| 文字為主的資料列 | List / Table | Collection |
| 圖像為主、尺寸不一的內容 | Collection（grid/row） | List |
| 少量文字輸入 | Text field | Text view |
| 大量文字輸入 | Text view（`TextEditor`） | Text field |
| 已知時長的等待 | Determinate progress bar | Spinner |
| 未知時長的等待 | Indeterminate spinner | 假的進度條 |
| 呈現資料趨勢／比較 | Chart | 表格硬塞（反之：純資料查詢用 list，不硬畫圖） |

## Buttons

**選用**：觸發一個立即動作時使用。若是維持狀態（開／關）用 Toggle；互斥選項用 Segmented control；展開選項清單用 Menu / pop-up button。

- 保證至少 44x44 pt 的 hit region，並與周圍元件留足間距。
- 自訂按鈕必須有 press state，否則使用者會以為沒反應。
- **Prominence 層級**：一個畫面用 prominent 樣式標示「最可能的動作」，每個 view 最多 1–2 顆 prominent；用「樣式差異」而非「尺寸差異」區分主次——同組選項按鈕保持同尺寸。
- Liquid Glass 下：若內容層已有鮮豔色彩，按鈕 label 保持預設單色（monochromatic），避免按鈕 label 顏色與內容層背景撞色。
- **內容**：常見動作用標準 SF Symbols（如分享用 `square.and.arrow.up`）；文字 label 以動詞開頭、title-style capitalization（如「Add to Cart」）。
- **Role**：`normal` / `primary` / `cancel` / `destructive`。primary 用 accent color 並回應 Return 鍵；destructive 顯示紅色。
- 把 primary role 給使用者最可能選的按鈕；**絕不把 primary role 給 destructive 動作**——視覺突出會讓人未讀先按，導致誤刪資料。
- 動作無法立即完成時，讓按鈕內顯示 activity indicator 並可換 label（「Checkout」→「Checking out…」），不要另開 loading 畫面。

SwiftUI：`Button(role:)`、`.buttonStyle(.borderedProminent)` / `.bordered` / `.glass`（iOS 26+）、`.controlSize(_:)`。

## Menus

**選用**：把一組指令、選項或狀態收納在觸發點之後。相關變體：pop-up button（從清單選值）、pull-down button（與按鈕相關的附屬動作）。

- **項目排序**：重要／高頻項目放最前——使用者從頂部開始掃視。
- 邏輯相關指令用 separator 分組，且**同組指令留在同組**，即使使用頻率不同（Paste 與 Paste and Match Style 同組）。
- Label 用動詞或動詞片語、title-style capitalization、刪去冠詞（a/an/the）；需要進一步輸入才能完成的動作加上省略號（…）。
- 不可用的項目**變暗（dim）但保留**；即使全部項目不可用，menu 本身仍要可開啟供人了解有哪些指令。
- **Icons（2026 更新）**：少用且有目的地用——標示最常用動作、關鍵功能、檔案位置、使用者內容；常見動作用系統標準 icon 保持一致；**同一組項目要嘛全有 icon、要嘛全沒有**，不要混。
- Submenu 節制使用：最多一層、超過約 5 項就另立 menu；同一組有 2 個以上項目共用同一詞（Sort by…）才考慮收成 submenu；不要用縮排代替 submenu。
- **Toggled item**：優先用單一項目 + 可變 label（Show Map ↔ Hide Map）；語意不清時加動詞（Turn HDR On）；屬性型狀態用 checkmark 標示已生效項。
- iOS/iPadOS 版面：large（預設，全列表）／medium（頂部 3 個 icon+短 label）／small（頂部 4 個純 icon，僅限一望即知的成組動作，如 Bold/Italic）。API：`preferredElementSize`。

SwiftUI：`Menu`、`Divider()`、`Toggle` in menu、`Button(role: .destructive)`。

## Context Menus 與 Edit Menus

**選用**：context menu 提供「當前物件最常用的少數指令」的捷徑。它預設隱藏，所以——

- **絕不把功能只藏在 context menu**：所有項目必須同時存在於主介面（toolbar、menu bar 等）。
- 只放當前情境高相關、高頻的指令；項目數要少，太長難掃視。
- 全 app 一致支援：某些項目有、某些沒有，使用者會以為壞了。
- 與一般 menu 相反：**不可用的項目直接隱藏，不要變暗**——context menu 只列出當下適用的動作。
- 高頻項目放在最靠近手指／指標展開處的一端（menu 可能向上或向下展開，必要時反轉排序）。
- **Destructive 動作（Delete/Remove）放在最末端，並標記 destructive**（系統顯示紅字）。
- Submenu 最多一層；分組不超過約 3 組；不在 context menu 顯示鍵盤快捷鍵。
- iOS/iPadOS：同一元素**只能擇一**提供 context menu 或 edit menu，不可兩者都綁；可附 preview 讓人確認操作對象，preview 裁切路徑要與圓角吻合避免動畫跳動。
- Edit menu（文字選取選單）：用系統提供的，不要自製；自訂指令排在相關系統指令旁；沒有選取內容就不要顯示 Copy/Cut；讓不可編輯的內容文字也能選取複製（但控制元件的 label 不用）。

SwiftUI：`.contextMenu { }`；UIKit：`UIContextMenuInteraction`、`UIEditMenuInteraction`。

## Toolbars

**選用**：沿視圖頂部或底部水平放置「作用於當前內容的動作、導航與標題」。與 Tab bar 區分：tab bar 專責 app 區域間導航。iOS 26 起 toolbar 採 Liquid Glass 浮動外觀，舊的 navigation bar 指引已併入 toolbar。

- **不要自訂 toolbar 背景與 tint**：讓內容層透過 Liquid Glass 決定外觀，需要與內容區分時用 `ScrollEdgeEffectStyle`；內容層彩度高時 item 保持預設單色。
- 用標準元件——標準按鈕／text field 的圓角自動與 bar 圓角同心（concentric）；自訂元件也要做到同心圓角。
- 刻意精選 item 避免擁擠；**系統會在放不下時自動生成 overflow menu，不要手動加，也不要預設就 overflow 的版面**。次要動作收進 More menu（真的需要才加）。
- Item 用無邊框的系統 symbol（不要 circle 外框變體）；不易用 symbol 表達的動作（如 Edit）才用文字。
- **關鍵動作（Done/Submit）用 `.prominent` 樣式**：獨立分離並上色成為焦點；**一個 toolbar 只有一個 primary action，放 trailing 端**。
- **分組（iOS 26 item groupings）**：leading = 返回／sidebar 切換／標題／document menu（不可自訂）；center = 常用指令（iPadOS/macOS 可讓使用者自訂、縮窄時自動收進 overflow）；trailing = 必須常駐的重要動作、search、More menu、primary action。
- 按功能與使用頻率分組，**最多約 3 組**；文字 label 的按鈕之間插入 fixed space，避免多顆文字按鈕黏成一串。
- 標題精簡（15 字元內）、不要用 app 名稱當標題；用標準 Back / Close symbol，不要寫「Back」文字。
- iOS：空間有限，只放最必要 item；用 large title 幫助定位（捲動時自動縮為標準標題）。iPadOS：toolbar 可與 tab bar 共存於頂部同一水平空間。

SwiftUI：`.toolbar { ToolbarItem(placement: .confirmationAction) }`、`ToolbarItemGroup`、`ToolbarSpacer`（iOS 26+）、`.scrollEdgeEffectStyle(_:)`。

## Labels

**選用**：顯示不可編輯的少量文字。可編輯 → text field；大量文字 → text view。

- 優先用系統字型，保留 Dynamic Type 支援；自訂字型要確保可讀性。
- 用系統四級 label 色（label / secondaryLabel / tertiaryLabel / quaternaryLabel）表達資訊層級，不要自配灰階。
- 有用的資訊文字（錯誤訊息、位址、IP）讓使用者可選取複製。

SwiftUI：`Label("Title", systemImage:)`、`Text`、`.foregroundStyle(.secondary)`。

## Lists/Tables vs Collections

**選擇**：文字為主、逐列掃讀 → list/table；圖像為主、大量圖片或項目尺寸差異大 → collection。文字內容硬用 collection 會降低可讀性；反之圖片牆硬用 list 浪費空間。

List/Table：

- 列文字精簡以減少截斷；必要時用**中間省略**（保留頭尾）維持可辨識性。
- 允許合理的編輯：重排序即使不能增刪也受歡迎；iOS 需先進入 edit mode 才能選取。
- 選取回饋分兩種：導航型（持續 highlight 選中列指出路徑）vs 選項型（短暫 highlight 後顯示 checkmark）。
- Info button（detail disclosure）**只用於顯示列的更多資訊，不用於導航**；要下鑽階層用 disclosure indicator。
- 列尾已有 trailing 控制元件（如 disclosure indicator）就不要再加字母 index，兩者都在 trailing 側會互相誤觸。
- 依平台選 list style（iOS grouped 等），別自製分組視覺。

Collection：

- 用標準 row／grid 版面，避免自訂版面搶走內容焦點。
- 圖片周圍留足 padding，維持 focus/hover 效果清晰、內容不重疊。
- 避免在使用者瀏覽互動途中動態改變版面，除非是回應其明確操作。

SwiftUI：`List`、`.listStyle(.insetGrouped)`、`Table`（iPadOS/macOS）、`LazyVGrid` / `UICollectionView`。

## Pickers 與 Date Pickers

**選用**：中～長清單選值。**短清單（少量選項）改用 pull-down button／menu**（picker 對短清單視覺重量過大）；**超大量項目改用 list**（可調高度、可加 index 快速跳段）。

- 選項用可預期的邏輯排序（如國家按字母序）——多數值被遮住，可預測才能快速捲到目標。
- 就地顯示（欄位下方、popover 或視圖底部），**避免為了 picker 切換到另一個畫面**。
- Date picker styles（iOS/iPadOS）：`compact`（按鈕展開 modal 日曆＋時間編輯，**空間有限時首選**）／`inline`（行內日曆或滾輪）／`wheels`（滾輪，支援鍵盤輸入）／`automatic`。
- Modes：date / time / date and time / countdown timer（countdown 不支援 inline 與 compact）。
- 分鐘粒度不必到 1 分鐘：用能整除 60 的間隔（如 15 分鐘）減少捲動。

SwiftUI：`Picker` + `.pickerStyle(.menu / .wheel / .navigationLink)`、`DatePicker` + `.datePickerStyle(.compact / .graphical / .wheel)`。

## Segmented Controls

**選用**：一組**互斥**、密切相關的選項或子視圖切換（iOS 為單選）。

- 適合「切換同一內容的相近子視圖」（如 Calendar 新增事件 sheet 切 Event/Reminder）；**切換 app 完整區域必須用 Tab bar**，不要用 segmented control 冒充導航。
- **不要當按鈕組用**：同一控制內不可混合「顯示選取狀態的 segment」與「執行動作的 segment」。
- 數量限制：**iPhone 最多約 5 個**；寬版面（iPad）最多約 5–7 個。
- 內容規範：單一控制內**只用文字或只用圖示，不混用**；各 segment 內容尺寸相近、等寬呈現；label 用名詞／名詞片語、title-style capitalization，不需引導文字。

SwiftUI：`Picker` + `.pickerStyle(.segmented)`；UIKit：`UISegmentedControl`。

## Sliders vs Steppers

**選擇**：連續範圍內即時調整（音量以外的強度、大小、程度）→ slider；小幅、離散、可數的增減 → stepper。範圍大又需精確值 → slider ＋ text field ＋ stepper 併用。

Slider：

- 方向遵循慣例：水平 slider 最小值在 leading、最大值在 trailing；垂直則下小上大。
- 可用左右 icon 說明兩端語意（小圖示→大圖示）。
- **iOS 不要用 slider 做音量控制**：用系統 volume view（含音量 slider 與輸出裝置切換）。

Stepper：

- Stepper 本身不顯示數值，**旁邊必須有顯示當前值的欄位**，讓人知道在改什麼。
- 預期會大幅變動時搭配 text field 直接輸入（如列印份數）。

SwiftUI：`Slider(value:in:step:)`、`Stepper(value:in:)`；音量用 `MPVolumeView`。

## Toggles

**選用**：管理內容或視圖的**兩個對立狀態**（開／關）。要從清單中選擇 → 用 pop-up button／menu，不是 toggle。

- **Switch 樣式只用在 list row 內**，且不另加 label（該列內容即語境）。
- List 之外要做開關，**用 toggle 行為的按鈕**（icon＋狀態背景變化，如電話 app 的過濾按鈕），不要裸放一顆 switch；此類按鈕不需說明文字。API：`changesSelectionAsPrimaryAction`。
- 預設綠色通常最好；改用 accent color 時確保與關閉狀態對比足夠。
- 狀態視覺差異要明顯（填色、背景形狀、checkmark／圓點），**不能只靠顏色差異**傳達狀態（色覺障礙者無法辨識）。

SwiftUI：`Toggle(isOn:)`、`.toggleStyle(.switch)` / `.toggleStyle(.button)`。

## Text Fields

**選用**：請求少量資訊（姓名、email）。長文輸入用 text view。

- **Placeholder 只是提示，不是 label**：placeholder（「Email」）在輸入後消失，因此另加持續可見的說明 label 提醒欄位用途。
- 敏感資料（密碼）一律用 secure text field。
- 欄位寬度對應預期輸入量，幫助使用者預估要填多少；多欄位垂直堆疊、寬度成組一致、間距均勻。
- 驗證時機看語境：email 在**離開欄位時**驗證；建立帳號密碼在**切換欄位前**驗證。數值欄位用 number formatter 限制輸入並做在地化格式，不要自己 parse。
- 依內容顯示正確鍵盤（`.keyboardType`：numberPad、emailAddress、URL…），並設 `textContentType` 啟用自動填入。
- iOS：**trailing 端顯示 Clear button** 讓人一鍵清空；leading 端放表明用途的圖示，trailing 端放附加功能。
- Tab 鍵在多欄位間的焦點順序要符合視覺邏輯。

SwiftUI：`TextField("Email", text:)`、`SecureField`、`.keyboardType(.emailAddress)`、`.textContentType(.username)`、`TextEditor`。

## Progress Indicators

**選擇**：時長可知（檔案轉換、下載）→ **determinate**（進度條／圓形進度）；時長不可知（載入、同步）→ **indeterminate**（spinner）。**能用 determinate 就不用 indeterminate**——它讓人能決定要等、要離開還是要放棄。

- 進度回報要準確且**節奏平均**：5 秒跑到 90% 然後最後 10% 跑 5 分鐘，感覺像當機甚至像欺騙。
- 指示器要保持動態；靜止的指示器 = 使用者眼中的凍結。程序卡住時給出說明與可行動作。
- 中途可得知剩餘時長時，**從 indeterminate 切換為 determinate**；但**不要在圓形（spinner）與長條（bar）之間切換**，形狀尺寸不同會破壞介面。
- 說明文字要具體，**避免「Loading…」「Authenticating…」這類無資訊詞**。
- 可行時提供 Cancel；中斷會有損失（如已下載部分）時再加 Pause，且取消前用 alert 確認。
- iOS refresh control（下拉更新）是輔助手段：**app 仍要定期自動更新內容**，不要把每次更新的責任丟給使用者。

SwiftUI：`ProgressView(value:total:)`（determinate）、`ProgressView()`（spinner）、`.refreshable { }`。

## Charts（圖表）

**選用**：要**傳達資訊、突顯趨勢或幫助分析**時才用圖表；若只是提供資料讓人查閱，用可捲動、可搜尋、可排序的 list/table。

- 保持簡單，漸進揭露：不要塞滿資料；讓使用者自選細節層級或資料子集。
- 優先用常見圖表類型（bar、line）——使用者已會讀；新穎表現法必須附教學式引導（如 Activity rings 首次逐環動畫）。
- 加描述性文字：標題、副標、annotation 突顯關鍵資訊與可行動結論；可加一句 headline 摘要（如 Weather 的「Chance of light rain in the next hour」）。
- 尺寸配功能：可互動、多細節的圖表要夠大；一望即知的摘要可用小圖表（點開展開大圖）。
- 多圖表保持一致：同用途圖表用同類型同樣式；**同一資料集的不同視角必須沿用同一圖型、色彩、annotation 與版面**以示連續性。
- 每個圖表都要無障礙：提供描述數值與元件的 accessibility labels 與互動元素（Audio Graphs），描述性標題不能取代 accessibility label。

SwiftUI：Swift Charts — `Chart { BarMark(x:y:) }`、`LineMark`、`.chartXAxis`、`AXChartDescriptor`。
