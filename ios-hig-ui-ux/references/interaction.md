# 互動設計：手勢、輸入與觸覺回饋（HIG Interaction）

依據 Apple Human Interface Guidelines（Gestures、Entering Data、Drag and Drop、Undo and Redo、Playing Haptics、Keyboards、Virtual Keyboards、Pointing Devices）整理，聚焦 iOS / iPadOS。

## 目錄

- [手勢（Gestures）](#手勢gestures)
- [資料輸入（Entering Data）](#資料輸入entering-data)
- [虛擬鍵盤與輸入視圖（Virtual Keyboards）](#虛擬鍵盤與輸入視圖virtual-keyboards)
- [Drag and Drop](#drag-and-drop)
- [Undo 與 Redo](#undo-與-redo)
- [觸覺回饋（Haptics）](#觸覺回饋haptics)
- [外接鍵盤與快捷鍵（Hardware Keyboards）](#外接鍵盤與快捷鍵hardware-keyboards)
- [Pointer 互動（iPadOS Trackpad／Mouse）](#pointer-互動ipados-trackpadmouse)
- [常見錯誤檢查清單](#常見錯誤檢查清單)

## 手勢（Gestures）

### 標準手勢語彙 — 不要重新定義

| 手勢 | 系統預期行為 |
|---|---|
| Tap | 觸發控制項、選取項目 |
| Swipe | 揭示動作與控制項、關閉視圖、捲動 |
| Drag | 移動 UI 元素 |
| Touch and hold | 揭示額外控制項或功能（如 context menu） |
| Double tap | 放大／縮小 |
| Pinch（zoom） | 縮放視圖或內容 |
| Rotate | 旋轉選取的項目 |

iOS / iPadOS 額外的系統手勢：三指左右滑動＝undo／redo、三指捏合＝copy／paste、搖動裝置＝undo／redo、四指滑動（iPad）＝切換 App。

- 讓熟悉手勢做熟悉的事：tap 就是啟動／選取。避免把 tap、swipe 挪作 App 專屬的特殊行為，也避免發明新手勢去做「按按鈕」「捲動」這類標準動作。
- 避免與系統手勢衝突：螢幕邊緣 swipe（Home indicator、通知中心、控制中心）屬於系統。全螢幕遊戲等特殊情境可延後系統手勢（UIKit：`preferredScreenEdgesDeferringSystemGestures`），但不要佔用。
- 手勢永遠只是捷徑，不是唯一入口：任何靠手勢觸達的功能，必須同時有可見的替代操作（按鈕、選單）。例如支援側滑返回的同時保留 Back 按鈕。使用者可能依賴語音、鍵盤或 Switch Control。
- 最小觸控目標 44x44 pt：所有可點擊元素的 hit target 不小於 44x44 pt（視覺尺寸可以更小，用 padding 補足 hit region）。
- 即時回饋：手勢進行中就要提供視覺回饋，幫助預測結果；手勢不可用時要明確顯示（例如鎖定物件被拖曳時的視覺提示），否則使用者會以為 App 凍結。
- 自訂手勢僅限必要：高頻、專門且現有手勢無法涵蓋的任務（遊戲、繪圖）。必須同時滿足：可被發現、容易執行、與其他手勢有區別、不是重要功能的唯一途徑。難以用一句話加簡圖說明的手勢，就是太難學的手勢。
- 遊戲可考慮允許多手勢同時辨識（如搖桿＋射擊鈕）；一般 App 通常不需要。

SwiftUI：`.onTapGesture`、`.gesture(DragGesture())`、`.highPriorityGesture()`、`.simultaneousGesture()`。

## 資料輸入（Entering Data）

核心策略：能不打字就不打字；能自動取得就不要問。

- 從系統取得資料：位置、行事曆、聯絡人等可經授權自動取得的資訊，不要要求手動輸入。
- 用選擇代替輸入：picker、menu、segmented control 比打字快且不會打錯。也支援 paste 與 drag and drop 作為輸入途徑。
- 明確標示需要的資料：placeholder（如 `username@company.com`）或欄位標籤（如「Email」），並盡量預填合理預設值。
- 選對 keyboard type：Email 用 `.emailAddress`、數字用 `.numberPad`、電話用 `.phonePad`、網址用 `.URL`。SwiftUI：`.keyboardType(_:)`。
- 設定 textContentType 啟用自動填入：`.textContentType(.username)`、`.password`、`.newPassword`、`.oneTimeCode`、`.emailAddress` 等，系統據此提供 AutoFill 與更準的鍵盤建議。
- 即時驗證，不要等送出：每個欄位輸入完成當下就驗證並回饋錯誤，避免使用者填完長表單才被退回。數值欄位用 number formatter 限制只接受數字並格式化（小數位、百分比、貨幣）。
- 必填未完成前停用「下一步」：Next／Continue 按鈕在必要資料齊全前保持 disabled，讓使用者理解前進條件。
- 密碼欄位：使用 secure text field 遮蔽輸入；永遠不要預填密碼——改用 biometric 或 keychain 認證。
- 自訂 Return 鍵讓語意一致：搜尋情境用 Search 等。SwiftUI：`.submitLabel(.search)`、`.onSubmit {}`。

## 虛擬鍵盤與輸入視圖（Virtual Keyboards）

- 用 keyboard layout guide 避免鍵盤遮擋內容與按鈕（UIKit：`UIKeyboardLayoutGuide`；SwiftUI 的 safe area 會自動處理多數情況）。
- 鍵盤上方的自訂控制列（input accessory view）：只放與當前任務相關的控制項。若 App 其他視圖使用 Liquid Glass，包含這些控制項的視圖也要套用 Liquid Glass 保持一致；使用標準 toolbar 則自動採用 Liquid Glass（iOS 26+）。
- Custom input view（僅在你的 App 內取代系統鍵盤，如 Numbers 的數值輸入面板）：必須明顯優於系統鍵盤才做；打字時播放標準鍵盤音效（UIKit：`UIDevice.playInputClick()`）。
- Custom keyboard extension（系統層級第三方鍵盤）：只適合全系統的獨特輸入法（新輸入方式、系統不支援的語言）；只是 App 內需求就用 custom input view。不要重複系統提供的 Globe／Dictation 鍵。注意 secure text field 與電話號碼欄位不會啟用第三方鍵盤。

## Drag and Drop

- Move 或 Copy 的預設規則：同一容器內拖放＝move；跨容器＝copy；跨 App 一律 copy。改變預設前先想清楚哪種較不會造成資料遺失的挫折。
- 提供替代操作：拖放對部分使用者不便或不可行，必須有等效的選單命令（copy／paste／move to）。用 accessibility API 標注 drag source 與 drop destination，讓輔助技術可以操作。
- iPad 跨 App 拖放：支援多項目 flocking（拖曳中陸續加入項目成群）、接受多項目同時 drop；Universal Control 讓內容在 Mac 與 iPad 間拖放。
- 全程視覺回饋：拖曳約 3 pt 就顯示半透明 drag image；目的地能接受時顯示 insertion point 或 highlight，不能接受時不給回饋或顯示 `circle.slash`；drop 失敗時讓項目飛回原位或淡出。多項目可用 badge 數字顯示數量。
- 提供多種 fidelity 的內容表示，由高至低排序（如原生物件 → PDF → PNG → JPEG），讓目的地挑選能接受的最高品質；接收端則取用能處理的最高 fidelity。
- 讓拖放可 undo：誤放很常見。無法 undo 的拖放操作，考慮先確認或提供反悔途徑。
- Drop 後保持內容在目的地的選取狀態，讓使用者能立即接續操作；耗時傳輸要顯示進度與 placeholder。
- 考慮支援 spring loading（拖曳懸停在按鈕／segmented control 上使其觸發）。

SwiftUI：`.draggable(_:)`、`.dropDestination(for:)`、`Transferable`。

## Undo 與 Redo

- 標準觸發方式不要重新定義：iPhone 搖動裝置、三指左右滑動；iPad／Mac 外接鍵盤 Command-Z ／ Shift-Command-Z。
- 幫助預測 undo 的對象：搖動出現的 alert 與選單項目都要描述動作，如「Undo Typing」「Redo Address Change」——只需提供「Undo 」前綴後面的簡短描述文字。
- 顯示 undo 的結果：若被還原的內容不在畫面上（例如還原了畫面外被刪的段落），捲動到該處突顯結果，否則使用者會以為沒生效而重複操作。
- 支援多次 undo：不要對次數設不必要的上限；使用者預期能一路退回開檔或上次儲存的狀態。適當時提供批次還原（一次撤銷一組相關的連續調整）。
- 專用 Undo／Redo 按鈕僅在必要時提供，使用系統標準符號並放在 toolbar。

API：Foundation `UndoManager`；SwiftUI 環境值 `\.undoManager`。

## 觸覺回饋（Haptics）

- 按系統定義的語意使用標準 pattern，不要挪用：

| 類別 | Pattern | 語意 |
|---|---|---|
| Notification | success / warning / error | 任務或動作的結果 |
| Impact | light / medium / heavy / rigid / soft | 視覺上的碰撞、落定的物理隱喻 |
| Selection | selection | UI 元素的值正在變更（如 picker 滾動） |

- 一致的因果關係：同一個 haptic pattern 永遠對應同一類事件。失敗用過的 pattern 不能又拿來表示成功。
- 與視覺、聽覺回饋協調：haptic 的強度與銳利度要配合所伴隨動畫的強度；可與音效同步。
- 克制，寧少勿多：高頻播放會讓回饋變得煩人並稀釋意義。最好的 haptic 是使用者沒意識到、關掉才發現少了什麼。一般 App 偏好短促的 transient 事件搭配離散動作；長時間連續 haptic 留給遊戲。
- 不要重複系統已有的回饋：switch、slider、picker 等標準元件在支援的 iPhone 上已自帶 haptics，不要再疊加。
- 必須可關閉：提供關閉選項，且關閉後 App 功能完整不受影響。
- 注意物理副作用：震動可能干擾相機、陀螺儀、麥克風的使用。
- 自訂 haptics（Core Haptics）：以 transient（短促如敲擊）與 continuous（持續震動）兩種事件組合，調整 sharpness 與 intensity，可依情境動態變化並同步音訊。僅在標準 pattern 語意不合時使用。

SwiftUI：`.sensoryFeedback(.success, trigger:)`；UIKit：`UINotificationFeedbackGenerator`、`UIImpactFeedbackGenerator`、`UISelectionFeedbackGenerator`。

## 外接鍵盤與快捷鍵（Hardware Keyboards）

- 支援 Full Keyboard Access（iOS／iPadOS／macOS／visionOS）：讓使用者只用鍵盤導航與觸發所有功能。測試方式：設定 > 輔助使用開啟 Full Keyboard Access。
- iPadOS 分工：文字欄位、text view、sidebar、collection view 支援方向鍵導航；但不要自行為按鈕、segmented control、switch 實作鍵盤導航——把控制項的導航與觸發交給 Full Keyboard Access。
- 尊重標準快捷鍵：Command-Z（undo）、Command-C／V／X、Command-F 等在所有 App 行為一致。不要把標準快捷鍵重新指定給無關動作；也避免在既有快捷鍵上加 modifier 去做無關的命令（Shift-Command-Z 是 redo，不能是別的）。
- 自訂快捷鍵只給最高頻的 App 專屬命令，太多反而顯得難學。
- Modifier 使用慣例：以 Command 為主要 modifier；Shift 作為相關命令的變體；Option 留給少用的進階功能；避免用 Control（系統大量佔用）。多個 modifier 依 Control、Option、Shift、Command 順序列出。
- 本地化交給系統：系統會依連接的鍵盤自動本地化快捷鍵，RTL 版面自動鏡像；非 Command 的 modifier 盡量只搭配字母鍵，避免某些語系鍵盤打不出來。

SwiftUI：`.keyboardShortcut("s", modifiers: [.command])`、`.onKeyPress`。

## Pointer 互動（iPadOS Trackpad／Mouse）

- Pointer 是 touch 的補充，不是取代：同一功能在 touch 與 pointer 下都要可用且結果一致（例如 Option-drag 複製物件，用手指拖或 pointer 拖結果相同）。
- 優先使用系統 content effects，依元素類型選擇：
  - highlight：小型、透明背景的元素（bar button、tab bar、segmented control 預設採用）。
  - lift：小型、不透明背景的元素（App icon 式的浮起效果）；非標準形狀要指定 corner radius。
  - hover：大型元素，自訂 scale／tint／shadow；空間不足的元素只用 tint，不要 scale；不要只有 shadow 沒有 scale。
- Hit region 留白：帶 bezel 的元素周圍約加 12 pt padding；無 bezel 的元素約加 24 pt。相鄰的自訂 bar button 讓 hit region 連續，避免 pointer 在按鈕間閃回預設形狀。
- 利用 pointer hover 揭示自動隱藏的控制項（如全螢幕影片的播放控制、最小化的 toolbar）。
- 自訂 pointer 形狀保持簡單，不加說明文字；只在有實際價值時改變 pointer 或內容外觀，不做純裝飾效果。
- 需要時支援 pointer 拖曳框選多項目（iPadOS 15+；標準 collection view 內建，自訂視圖需自行實作）。
- 不要重新定義系統層級的 trackpad 手勢（Dock、Mission Control 等）。

SwiftUI：`.hoverEffect(.highlight)` / `.lift` / `.automatic`、`.onHover`；UIKit：`UIPointerInteraction`。

## 常見錯誤檢查清單

審查或實作互動時，逐項確認以下高頻錯誤：

- 功能只能靠 swipe／long press 觸達，沒有可見的按鈕或選單替代 → 違反手勢替代原則。
- 可點擊元素 hit target 小於 44x44 pt（圖示按鈕、關閉鈕、表格附屬按鈕最常見）。
- 自訂手勢佔用螢幕邊緣，與返回、通知中心、控制中心、Home indicator 衝突。
- TextField 沒設 `.keyboardType` 與 `.textContentType`，使用者在 Email 欄看到一般鍵盤、拿不到 AutoFill。
- 表單送出時才一次列出所有錯誤，而不是逐欄即時驗證。
- 鍵盤彈出遮住正在編輯的欄位或送出按鈕（沒用 keyboard layout guide／safe area）。
- 對已內建 haptics 的系統元件（switch、picker）再手動疊加 haptic，或在捲動這類高頻事件上播放 haptics。
- 成功與失敗共用同一個 haptic pattern，破壞因果一致性。
- 用 `UIImpactFeedbackGenerator` 表達任務結果（應該用 notification 的 success／error）。
- 攔截 Command-Z、三指滑動或搖動手勢做非 undo 的行為。
- 拖放操作無法 undo，也沒有確認步驟。
- iPad 上自製按鈕的方向鍵導航，與 Full Keyboard Access 打架。
- 自訂 pointer 效果純裝飾、或對表格列使用 scale 型 hover 效果造成相鄰列重疊。
