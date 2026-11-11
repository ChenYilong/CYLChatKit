---
title: instructions — Resources
date: 2026-11-08
tags: [instructions]
source: 自动生成（.claude/hooks/folder_assets.py）
---

# Resources · 文件夹规则

- 用途：存放上级文件夹「Class」中笔记引用的图片和附件
- 封面：[[ChatKit-new-version/Class/Resources/Resources.base|Resources.base]]（Folder notes：点击文件夹即打开）
- 继承：[[ChatKit-new-version/Class/instructions|ChatKit-new-version/Class/instructions.md]] 及更上级的全部 instructions.md；冲突时以本文件为准

## 必须遵守

1. 在本文件夹新建任何文件后，创建或更新封面 `Resources.base`（参照 [[English/chunking/chunking.base|chunking.base]]）
2. 新建子文件夹时，同时为它创建封面 `<子文件夹名>.base` 和 `instructions.md`
3. 本文件夹只放附件（图片等），上级笔记用 `![描述](Resources/文件名)` 引用；不在这里新建笔记
4. 不删除已有内容，只追加或更新

## 本文件夹补充规则

- Core localization bundles live here (`Other.bundle`, `DateTools.bundle`, `CYLPBLocalizations.bundle`, and the other
  `*.bundle` folders). Rule 3 above is about notes; resource bundles are the exception, and the podspec ships every
  entry of this folder to clients.
- Every localization table is a file inside a bundle: `<Name>.bundle/<lang>.lproj/<Table>.strings`. Do not add loose
  `.lproj` folders here. The existing loose ones (`en.lproj`, `ar.lproj`, `zh-Hans.lproj`, `zh-Hant.lproj`, and
  `localization/`) stay as they are until their lookups are checked; see `docs/localization.md`.
- Core bundles are always kept: never delete or rename a bundle, table, or key. Add keys and languages only, add each
  new key to every language of its table in the same commit, and keep `%@` / `%1$@` specifiers identical.
- Core code reads these bundles only through the core localization macro, `CYLLocalizedStrings(key)`
  (`ChatKit/Class/Tool/CYLChatConstants.h`), or the macro of another core bundle. A new core bundle gets its own
  `CYL<Domain>LocalizedString(key)` macro.
- Example strings never go in this folder. The example has its own bundle and its own macro,
  `CYLDemoExampleLocalizedString(key, defaultValue)`, so a project always has at least two different localization macros.
- Before changing anything here, read `.agents/skills/cylchatkit-localization/SKILL.md` and the "Internationalization
  and localization" section of the root `AGENTS.md`.
