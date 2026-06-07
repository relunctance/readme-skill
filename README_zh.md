---
search: false
---

<div align="center">

# 📝 readme-skill

**[English](README.md) · [中文](README_zh.md)**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![version](https://img.shields.io/badge/version-2.0.0-green.svg)](#)
[![platforms](https://img.shields.io/badge/platforms-Hermes%20Agent%20%7C%20Claude%20Code%20%7C%20OpenClaw-4B8FBA.svg)](#)
[![category](https://img.shields.io/badge/category-Productivity-blue.svg)](#)

*README 完整性检查与自动美化 — 检测并更新所有 README，与 SKILL.md 保持同步*

</div>

## 🎯 触发条件

- 需要检查项目是否有 README
- 需要更新项目的 README
- 需要同步多个 README 变体
- 需要补全缺失的 README
- 需要美化现有 README（添加徽章、格式化）
- skill 创建/更新后检查 README

## ✨ 功能特性

- 自动检测项目中所有 README 变体（README.md / README_zh.md / README_en.md 等）
- 完整性检查：徽章 + 章节 + emoji 图标规范
- 与 SKILL.md 字段自动同步（version / license / platforms / category）
- 双语支持：中英文 README 互相引用
- shields.io 统一徽章格式

## 🚀 快速开始

```bash
# 安装
hermes skills install https://github.com/relunctance/readme-skill

# 美化现有 README
hermes skills run readme-skill --path ./README.md
```

## 📦 安装

```bash
# Hermes / OpenClaw
hermes skills install https://github.com/relunctance/readme-skill
```

## 📁 文件结构

```
readme-skill/
├── SKILL.md              # Skill 定义（含完整 SOP）
├── README.md             # 英文文档
├── README_zh.md          # 中文文档
├── LICENSE               # MIT 许可证
└── references/           # 详细参考文档（可选）
```

## ✅ 安装后验证

- [ ] `hermes skills list` 能看到 readme-skill
- [ ] `hermes skills run readme-skill --help` 正常执行

## 🔗 相关 Skills

- [skill-created](https://github.com/relunctance/skill-created) — 创建新 skill
- [dir-skill](https://github.com/relunctance/dir-skill) — 目录结构标准化

## 🤝 欢迎贡献

欢迎提交 Issue 和 Pull Request！

1. Fork 本仓库
2. 创建 Feature 分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

## 📜 许可证

MIT — 详见 [LICENSE](LICENSE)
