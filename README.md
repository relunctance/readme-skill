# readme-skill

[![license](https://img.shields.io/badge/license-MIT-blue.svg)](#)
[![platforms](https://img.shields.io/badge/platforms-claude_code%20%7C%20openclaw%20%7C%20hermes-blue.svg)](#)
[![version](https://img.shields.io/badge/version-1.0.0-green.svg)](#)
[![category](https://img.shields.io/badge/category-Productivity-blue.svg)](#)

README 完整性检查与自动美化 — 检测并更新所有 README 变体，与 SKILL.md 保持同步。

## 触发条件

- 检查项目是否有 README
- 更新项目的 README
- 同步多个 README 变体
- 补全缺失的 README
- 美化现有 README（添加徽章、格式化）

## 快速开始

```bash
# 检测 README 变体
find . -maxdepth 2 -iname "readme*" -type f

# 质量检查
bash readme-skill/scripts/check_readme.sh /path/to/project
```

## 安装

```bash
# Hermes
mkdir -p ~/.hermes/skills/readme-skill
ln -sf ~/repos/readme-skill/SKILL.md ~/.hermes/skills/readme-skill/SKILL.md
```
