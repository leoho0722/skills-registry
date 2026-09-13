# Skills Registry

Leo Ho 自行撰寫與維護的 [Agent Skills](https://agentskills.io) 集合，供 [Claude Code](https://claude.com/claude-code) 與 [Codex](https://openai.com/codex) 等 AI coding agent 使用。

每個頂層目錄即為一個 skill，透過 [`skills` CLI](https://skills.sh) 安裝。

## Skills

每列只列一句摘要，完整說明與使用方式請見各 skill 目錄內的 `SKILL.md`。

| Skill                             | 說明                                                                    |
|-----------------------------------|-------------------------------------------------------------------------|
| [`ios-hig-ui-ux`](ios-hig-ui-ux/) | 依 Apple HIG（Liquid Glass 世代）設計、實作與審查 iOS/iPadOS App 的 UI/UX。 |
| [`ios-dev-kit`](ios-dev-kit/)     | Leo Ho 個人的 Swift coding style、排版、file template、專案結構與 TCA 架構規範。 |

## 安裝

需要 Node.js 與 `npx`。

```bash
# 列出本 repo 可安裝的 skill
npx skills add leoho0722/skills-registry -l

# 安裝指定 skill 到 Claude Code 與 Codex（使用者層級）
npx skills add leoho0722/skills-registry -s ios-hig-ui-ux -a claude-code -a codex -g

# 安裝全部 skill 到所有偵測到的 agent
npx skills add leoho0722/skills-registry --all -g
```

省略 `-g` 則安裝到目前專案層級；省略 `-a` 會由 CLI 自動偵測本機已安裝的 agent。

### 更新

```bash
npx skills update -g
```

### 移除

```bash
npx skills remove ios-hig-ui-ux -g
```

## 使用方式

安裝後，agent 會依 `SKILL.md` 的 `description` 自動判斷何時載入該 skill；也可以直接在對話中指名使用，例如：

```
Use $ios-hig-ui-ux to review my iOS app's UI against the latest Apple HIG.
```

## 目錄結構

```
<skill-name>/
├── SKILL.md            # 必要。frontmatter 含 name 與 description，本體為工作流程與 reference 導覽
├── agents/openai.yaml  # Codex 用的 interface / policy 中繼資料
├── references/*.md     # 依主題拆分的細節，由 SKILL.md 按需引導 agent 載入
└── assets/             # 選用。樣板、範例等供 agent 直接複製的實體檔案
```

`SKILL.md` 只放不可違反的規則、核心原則與「任務情境 → 讀哪份 reference」的導覽表，細節下放到 `references/`，讓 agent 只載入當前任務需要的內容。

## 開發

```bash
# 建立新 skill 骨架
npx skills init <skill-name>

# 驗證本 repo 的 skill 能否被正確辨識（唯讀）
npx skills add . -l
```

修改需 push 到 `main` 後，安裝端才能透過 `npx skills add` 或 `npx skills update` 取得。

## 授權

[MIT](LICENSE)
