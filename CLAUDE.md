# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repo 定位

這是 Leo Ho 自己撰寫的 Agent Skills Registry (GitHub: `leoho0722/skills-registry`)，供 Claude Code 與 Codex 兩邊共用。倉庫內容純粹是 Markdown + YAML，沒有 build、lint、test 流程；每個頂層目錄就是一個 skill。

## Skill 目錄慣例

以 `ios-hig-ui-ux/` 為範本，每個 skill 固定長這樣：

```text
<skill-name>/
├── SKILL.md            # 必要。frontmatter 的 name 必須與目錄名相同
├── agents/openai.yaml  # Codex 專用的 interface / policy 中繼資料
└── references/*.md     # 依主題拆分的細節，由 SKILL.md 按需導向
```

- `SKILL.md` frontmatter 只允許 `name`、`description`、`license`、`allowed-tools`、`metadata` 五個 key；`description` 要同時寫「做什麼」與「何時觸發」(含使用者可能提到的關鍵字)，因為 Claude Code / Codex 靠它決定是否自動載入。
- `SKILL.md` 本體是「路由器」：只放鐵則、核心原則、工作流程與一張「任務情境 → 讀哪份 reference」導覽表，細節全部下放到 `references/`，讓 agent 只載入需要的部分 (progressive disclosure)。
- 每份 `references/*.md` 開頭放目錄 (anchor 連結) 並註明依據來源與版本日期，方便日後對照更新。
- `agents/openai.yaml` 提供 `interface.display_name`、`short_description`、`default_prompt` 與 `policy.allow_implicit_invocation`。
- 內容以正體中文撰寫，技術名詞與 API 名稱保留英文。
- `metadata.version` 依 skill 的性質二選一：內容對應外部來源（如 HIG）的 skill 用來源的年月（`2026-06`），回答「對應到哪個時間點的來源」；自行維護的規範型 skill（如 `ios-dev-kit`）用語義化版號（`1.0.0`）。語義化版號的進位規則：MAJOR 為既有程式碼會變違規或 reference 檔改名、移除、拆分；MINOR 為新增規則、樣板或 reference 且既有程式碼不受影響；PATCH 為措辭、範例、錯字修正。`skills` CLI 不讀此欄位，它只給人看，但每次修改 skill 內容時都要對應調整。

## 常用指令

Skill 的安裝、驗證與腳手架一律透過 [`skills` CLI](https://skills.sh) (`npx skills`)，不再依賴本機任何共用資料夾：

```bash
# 驗證本 repo 的 skill 結構是否能被正確辨識（唯讀，不會安裝）
npx skills add . -l

# 建立新 skill 骨架（在 repo 根目錄執行，會產生 <skill-name>/SKILL.md）
npx skills init <skill-name>

# 從 GitHub 安裝本 repo 的某個 skill 到 Claude Code 與 Codex（-g 為使用者層級）
npx skills add leoho0722/skills-registry -s <skill-name> -a claude-code -a codex -g

# 列出遠端 repo 目前可安裝的 skill
npx skills add leoho0722/skills-registry -l

# 更新已安裝的 skill 到最新版
npx skills update -g
```

## 發布流程

本 repo 是唯一的 source of truth，使用者端一律用 `npx skills add` 從 GitHub 拉取。這代表：

- 修改要 **push 到 `main` 之後**才會被安裝端看到；本機未 commit 的變更對 `npx skills add leoho0722/skills-registry` 完全不可見。
- 已安裝的使用者需要自行執行 `npx skills update` 才會拿到新版，因此修改既有 skill 時避免破壞性改動 (改名、移除 reference 檔)。

## 新增或修改 skill 的檢查重點

1. 目錄名、`SKILL.md` 的 `name`、`agents/openai.yaml` 三者一致。
2. 新增 reference 檔時，同步更新 `SKILL.md` 的導覽表與工作流程步驟，避免孤兒檔案。
3. 新增 skill 時在 `README.md` 的 Skills 表格補一列，說明欄只寫一句話；完整描述留在該 skill 的 `SKILL.md`，不要把 `description` 整段貼進表格。
4. 跑 `npx skills add . -l` 確認 skill 能被辨識、`description` 顯示正確，再 commit 並 push。

## Commit 慣例

**只在使用者明確要求時才 commit，且絕不自行 push。** 使用者說「之後拆成兩個 commit」這類描述是在說明拆分方式，不是要求立刻執行。

### 格式

- 採用 [Conventional Commits](https://www.conventionalcommits.org/)：`<type>(<scope>): <標題>`。
- **標題用正體中文**，祈使語氣，不加句號；type 與 scope 保持英文小寫。
- scope 填 skill 目錄名；跨 skill 或 repo 層級的變更不填 scope。
- 常用 type：`feat` 新增 skill 或 reference、`fix` 修正內容錯誤、`docs` README／CLAUDE.md 等 repo 文件、`chore` .gitignore 等基礎設施、`refactor` 重整結構但不改語意。
- body 用列點，寫「為什麼改」與影響範圍；標題已足夠說明的小改動可省略 body。
- 結尾保留 harness 當次注入的署名 trailer（`Co-Authored-By`、`Claude-Session` 等），逐字複製，不要自行改寫或省略；這些值每個 session 都不同，不得寫死在文件裡。

```text
feat(ios-hig-ui-ux): 新增 Liquid Glass reference

- 補上 HIG Materials 頁面的 functional layer / content layer 分層守則
- SKILL.md 導覽表新增對應列

Co-Authored-By: <harness 注入的模型署名>
Claude-Session: <harness 注入的 session URL>
```

### 拆分

- **skill 內容與 repo 基礎設施分開 commit**；一次動到多個 skill 時，每個 skill 各自一個 commit。
- 提交前先 `git status --short` 確認暫存區只包含本次變更的檔案，尤其不要把使用者仍在編輯中的檔案一併帶入。
