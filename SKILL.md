---
name: readme-skill
description: 当需要检查或更新项目 README 时使用。检测项目中是否存在 README，判断是否需要美化或补全，与 SKILL.md 保持同步
version: "2.0.0"
author: relunctance
license: MIT
category: productivity
tags:
  - readme
  - documentation
  - sync
  - badge
  - markdown
metadata:
  hermes:
    platforms:
      claude_code: true
      openclaw: true
      hermes: true
    related_skills: [skill-created, dir-skill]
---

# readme-skill

> README 完整性检查与自动美化 — 检测并更新所有 README，与 SKILL.md 保持同步

## 触发条件

当需要以下操作时使用：
- 检查项目是否有 README
- 更新项目的 README
- 补全缺失的 README
- 美化现有 README（添加徽章、格式化）
- skill 创建/更新后检查 README

## 核心流程

```
项目有 README？
  ├── 是 → 检查完整性（徽章 + 章节）→ 补充缺失项
  └── 否 → 生成标准 README
```

## 判断标准（LLM 直接执行）

### 必须包含的徽章

| 徽章 | shields.io URL |
|------|---------------|
| License | `![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)` |
| Version | `![version](https://img.shields.io/badge/version-X.Y.Z-green.svg)` |
| Platforms | `![platforms](https://img.shields.io/badge/platforms-hermes-blue.svg)` |
| Category | `![category](https://img.shields.io/badge/category-{category}-blue.svg)` |

### 必须包含的章节

| 章节 | 说明 |
|------|------|
| `## 触发条件` | 什么情况下使用这个项目 |
| `## 功能特性` | 核心能力列表（`- 特性 1` 格式） |
| `## 安装` | 安装命令 |

### 推荐包含的章节

| 章节 | 说明 |
|------|------|
| `## 快速开始` | 最少步骤跑起来 |
| `## 文件结构` | 目录/文件说明 |
| `## 安装后验证` | 检查清单（`- [ ]` 格式） |
| `## 相关 Skills` | 关联项目 |
| `## 许可证` | MIT 等 |

## Before / After 示例

### Before（不完整）

```markdown
# my-skill

这个 skill 用来做某件事

## 使用

运行 xxx 即可
```

### After（完整）

```markdown
# my-skill

> 做某件事的 skill

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)]
[![version](https://img.shields.io/badge/version-1.0.0-green.svg)]
[![platforms](https://img.shields.io/badge/platforms-hermes-blue.svg)]
[![category](https://img.shields.io/badge/category-devops-blue.svg)]

## 触发条件

当需要做某件事时使用。

## 功能特性

- 特性 1
- 特性 2

## 快速开始

```bash
hermes skills install https://github.com/relunctance/my-skill
```

## 安装

```bash
hermes skills install https://github.com/relunctance/my-skill
```

## 文件结构

```
my-skill/
├── SKILL.md
├── README.md
└── scripts/
```

## 安装后验证

- [ ] skill 加载成功
- [ ] 触发词生效

## 相关 Skills

- [skill-created](https://github.com/relunctance/skill-created) — 创建新 skill

## 许可证

MIT
```

## 与 SKILL.md 同步规则

| SKILL.md 字段 | → README 内容 |
|--------------|--------------|
| `name` | 标题 |
| `description` | 首段描述 |
| `version` | shields version 徽章 |
| `license` | shields license 徽章 |
| `category` | shields category 徽章 |
| `metadata.hermes.platforms` | shields platforms 徽章 |
| `triggers` / description | 触发条件章节 |

## 约束

1. **不删除已有内容** — 只补充，不覆盖已有有效内容
2. **保持风格一致** — 多语言版本保持相同结构
3. **徽章使用 shields.io** — 统一使用 shields.io 格式
4. **与 SKILL.md 同步** — description / version / platforms 必须一致
5. **不修改 LICENSE 文件** — 只更新文档，不动许可证

## 安装

```bash
# Hermes
hermes skills install https://github.com/relunctance/readme-skill
```
