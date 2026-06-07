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

*README Completeness Checking & Auto-Beautification — Detect and update all READMEs, stay in sync with SKILL.md*

</div>

## 🎯 Triggers

- Check if a project has a README
- Update a project's README
- Sync multiple README variants
- Complete missing READMEs
- Beautify existing READMEs (add badges, formatting)
- Check README after skill creation/update

## ✨ Features

- Auto-detect all README variants in a project (README.md / README_zh.md / README_en.md etc.)
- Completeness check: badges + sections + emoji icon standards
- Auto-sync with SKILL.md fields (version / license / platforms / category)
- Bilingual support: English and Chinese READMEs cross-reference each other
- shields.io unified badge format

## 🚀 Quick Start

```bash
# Install
hermes skills install https://github.com/relunctance/readme-skill

# Beautify an existing README
hermes skills run readme-skill --path ./README.md
```

## 📦 Installation

```bash
# Hermes / OpenClaw
hermes skills install https://github.com/relunctance/readme-skill
```

## 📁 File Structure

```
readme-skill/
├── SKILL.md              # Skill definition (with full SOP)
├── README.md             # English documentation
├── README_zh.md          # Chinese documentation
├── LICENSE               # MIT License
└── references/           # Detailed reference docs (optional)
```

## ✅ Post-Installation Verification

- [ ] `hermes skills list` shows readme-skill
- [ ] `hermes skills run readme-skill --help` executes normally

## 🔗 Related Skills

- [skill-created](https://github.com/relunctance/skill-created) — Create new skills
- [dir-skill](https://github.com/relunctance/dir-skill) — Directory structure standardization
- [evolve-skill](https://github.com/relunctance/evolve-skill) — Skill self-evolution engine

## 🤝 Contributing

Contributions, issues and pull requests are welcome!

**Found a bug?**
1. Submit an [Issue](https://github.com/relunctance/readme-skill/issues)
2. Describe reproduction steps
3. Attach error logs

**Want to contribute code?**
1. Fork this repository
2. Create a Feature branch (`git checkout -b feature/AmazingFeature`)
3. Write BDD comments + TDD tests
4. Commit changes (`git commit -m 'Add AmazingFeature'`)
5. Push to branch (`git push origin feature/AmazingFeature`)
6. Create a Pull Request

## 📜 License

MIT — see [LICENSE](LICENSE)
