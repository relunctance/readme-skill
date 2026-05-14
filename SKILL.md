---
name: readme-skill
description: 当需要检查或更新项目 README 时使用。检测项目中是否存在 README，判断是否需要美化或补全，自动更新所有 README 变体（README.md / README.zh.md / README_en.md 等），与 SKILL.md 保持同步
version: "1.0.0"
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

> README 完整性检查与自动美化 — 检测并更新所有 README 变体

## 触发条件

当需要以下操作时使用：
- 检查项目是否有 README
- 更新项目的 README
- 同步多个 README 变体
- 补全缺失的 README
- 美化现有 README（添加徽章、格式化）
- 项目提交后检查 README 是否需要更新

## 核心流程

```
项目有 README？
  ├── 是 → 检测变体数量 → 判断是否需要统一美化
  │         ├── 单一 README → 检查内容完整性
  │         ├── 多语言变体（zh/en/...）→ 全部更新
  └── 否 → 生成标准 README
```

## Step 1：检测 README 存在性和变体

```bash
# 检测所有 README 变体
detect_readmes() {
    local dir="${1:-.}"
    find "$dir" -maxdepth 2 -iname "readme*" -type f 2>/dev/null | sort
}

READMES=$(detect_readmes "$PROJECT_DIR")
echo "发现 README 变体：$READMES"
```

## Step 2：判断是否需要更新

### 必须更新的情况

| 情况 | 判断标准 |
|------|---------|
| 缺少 shields 徽章 | 无 `![license]` 或 `![version]` |
| 缺少触发条件 | SKILL.md 有但 README 无 |
| 缺少安装说明 | 有安装步骤但 README 无 |
| 缺少关键章节 | 无 ## 触发条件 / ## 安装 |
| 多语言变体不同步 | README.zh ≠ README.en 内容差异大 |
| 版本号过时 | SKILL.md version 与 README 不同步 |

### 自动检测脚本

```bash
check_readme_quality() {
    local readme="$1"
    local score=0
    local issues=""

    # 检查徽章
    if ! grep -q '!\[license\]' "$readme"; then
        issues+="缺少 license 徽章;"
    fi
    if ! grep -q '!\[version\]' "$readme"; then
        issues+="缺少 version 徽章;"
    fi
    if ! grep -q '!\[platforms\]' "$readme"; then
        issues+="缺少 platforms 徽章;"
    fi

    # 检查关键章节
    if ! grep -q '^## 触发条件' "$readme"; then
        issues+="缺少「触发条件」章节;"
    fi
    if ! grep -q '^## 安装' "$readme"; then
        issues+="缺少「安装」章节;"
    fi

    # 计算得分
    score=$(($(grep -c '!\[.*\]' "$readme" 2>/dev/null) * 15 + $(grep -c '^## ' "$readme" 2>/dev/null) * 10))
    echo "score:$score|issues:$issues"
}
```

## Step 3：生成标准 README 章节

```markdown
# {项目名称}

[![license](https://img.shields.io/badge/license-MIT-blue.svg)](#)
[![platforms](https://img.shields.io/badge/platforms-claude_code%20%7C%20openclaw%20%7C%20hermes-blue.svg)](#)
[![version](https://img.shields.io/badge/version-X.Y.Z-green.svg)](#)
[![category](https://img.shields.io/badge/category-{分类}-blue.svg)](#)

{一句话描述}

## 触发条件

当{场景}时使用。

## 功能特性

- 特性 1
- 特性 2

## 安装

```bash
# 安装命令
```

## 配合 skills

| 场景 | 调用 skill |
|------|-----------|
| {场景} | {skill} |

## 踩坑

| 坑 | 解决 |
|------|------|
| {坑} | {解决} |
```

## Step 4：更新所有变体

### 多语言同步规则

| 变体 | 更新策略 |
|------|---------|
| `README.md` | 主版本，始终更新 |
| `README.zh.md` | 与主版本同步中文内容 |
| `README_en.md` / `README-en.md` | 与主版本同步英文内容 |
| `README_*.md` | 其他语言变体各自翻译更新 |

```bash
# 同步多语言变体
sync_readme_variants() {
    local main_readme="$1"
    local dir=$(dirname "$main_readme")

    # 更新中文变体
    if [ -f "$dir/README.zh.md" ]; then
        update_readme_lang "$main_readme" "$dir/README.zh.md" "zh"
    fi

    # 更新英文变体
    for en_file in "$dir/README_en.md" "$dir/README-en.md"; do
        if [ -f "$en_file" ]; then
            update_readme_lang "$main_readme" "$en_file" "en"
        fi
    done
}
```

## Step 5：与 SKILL.md 保持同步

创建或更新项目时，README 必须与 SKILL.md 同步以下字段：

| SKILL.md 字段 | → README 章节 |
|--------------|--------------|
| `name` | 标题 |
| `description` | 首段描述 |
| `version` | shields 徽章 |
| `license` | shields 徽章 |
| `tags` | keywords 行 |
| `metadata.hermes.platforms` | shields platforms 徽章 |
| `triggers` / description | 触发条件章节 |
| `category` | shields category 徽章 |

## 典型场景

### 场景 1：提交前检查

```bash
# 在 git commit 前检查 README 是否需要更新
pre_commit_check() {
    local project_dir="$(pwd)"
    READMES=$(detect_readmes "$project_dir")

    if [ -z "$READMES" ]; then
        echo "⚠️  未发现 README，建议创建：README.md"
        return 1
    fi

    for rm in $READMES; do
        result=$(check_readme_quality "$rm")
        score=$(echo "$result" | cut -d: -f2)
        issues=$(echo "$result" | cut -d: -f3)

        if [ "$score" -lt 50 ]; then
            echo "⚠️  $rm 需要更新（得分 $score）：$issues"
        fi
    done
}
```

### 场景 2：新建 skill 后自动生成

当使用 skill-created 创建新 skill 后，readme-skill 自动检查并生成/更新 README。

### 场景 3：多语言项目同步

项目同时维护中英文档时，确保每次更新主 README 后，所有语言变体同步更新。

## 约束

1. **不删除已有内容** — 只补充，不覆盖已有有效内容
2. **保持风格一致** — 多语言版本保持相同结构
3. **徽章使用 shields.io** — 统一使用 shields.io 格式
4. **与 SKILL.md 同步** — description / version / platforms 必须一致
5. **不修改 LICENSE 文件** — 只更新文档，不动许可证

## 安装

```bash
# Hermes
mkdir -p ~/.hermes/skills/readme-skill
ln -sf ~/repos/readme-skill/SKILL.md ~/.hermes/skills/readme-skill/SKILL.md

# Claude Code
mkdir -p ~/claude/skills/readme-skill
ln -sf ~/repos/readme-skill/SKILL.md ~/claude/skills/readme-skill/SKILL.md
```
