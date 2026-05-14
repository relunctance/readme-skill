#!/usr/bin/env bash
# skill-pre-commit-check.sh
# Skill 提交前必检：验证所有引用的文件/脚本/链接是否存在
# 用法: bash scripts/pre-commit-check.sh <skill-repo-root>

set -e

ROOT="${1:-.}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

ERRORS=0

check() {
    local file="$1"
    local pattern="$2"
    local description="$3"

    if [ ! -f "$file" ]; then
        return
    fi

    matches=$(grep -n "$pattern" "$file" 2>/dev/null || true)
    if [ -z "$matches" ]; then
        return
    fi

    echo "$matches" | while read -r line; do
        linenum=$(echo "$line" | cut -d: -f1)
        content=$(echo "$line" | cut -d: -f2-)

        # 提取路径（去除引号、反引号、括号等）
        path=$(echo "$content" | grep -oE '[`"'"'"']*[^`"'"'"'(]*[`"'"'"')]' | head -1 | tr -d '`'"'"'")
        path=$(echo "$path" | sed 's/[()"]//g' | xargs)

        if [ -z "$path" ]; then
            return
        fi

        # 跳过 URL
        if echo "$path" | grep -qE '^https?://'; then
            return
        fi

        # 跳过变量和命令
        if echo "$path" | grep -qE '^\$|curl |wget |git |bash '; then
            return
        fi

        # 解析相对路径
        local_dir=$(dirname "$file")
        full_path=""
        if [[ "$path" == /* ]]; then
            full_path="$path"
        else
            full_path="$local_dir/$path"
        fi

        # 清理多余 ../
        full_path=$(realpath "$full_path" 2>/dev/null || echo "$full_path")

        if [ ! -e "$full_path" ]; then
            echo -e "${RED}❌ $file:$linenum${NC}"
            echo -e "   引用路径不存在: $path"
            echo -e "   完整: $full_path"
            ERRORS=$((ERRORS + 1))
        fi
    done
}

echo "=== Skill Pre-Commit Check ==="
echo "检查目录: $ROOT"
echo ""

# 1. 检查 SKILL.md 引用的所有本地路径
echo "--- SKILL.md 引用检查 ---"
if [ -f "$ROOT/SKILL.md" ]; then
    check "$ROOT/SKILL.md" 'scripts/' 'scripts/ 引用'
    check "$ROOT/SKILL.md" 'references/' 'references/ 引用'
    check "$ROOT/SKILL.md" '\.sh' 'shell 脚本引用'
    check "$ROOT/SKILL.md" '\.py' 'python 脚本引用'
    check "$ROOT/SKILL.md" '~\/' 'HOME 相对路径引用'
    check "$ROOT/SKILL.md" '/home/' '绝对路径引用'
    check "$ROOT/SKILL.md" '\.md' 'markdown 文件引用'
    echo -e "${GREEN}✅ SKILL.md 引用检查完成${NC}"
else
    echo -e "${YELLOW}⚠️  未发现 SKILL.md${NC}"
fi
echo ""

# 2. 检查 README.md 引用的所有本地路径
echo "--- README.md 引用检查 ---"
if [ -f "$ROOT/README.md" ]; then
    check "$ROOT/README.md" 'scripts/' 'scripts/ 引用'
    check "$ROOT/README.md" 'references/' 'references/ 引用'
    check "$ROOT/README.md" '\.sh' 'shell 脚本引用'
    check "$ROOT/README.md" '~\/' 'HOME 相对路径引用'
    check "$ROOT/README.md" '/home/' '绝对路径引用'
    echo -e "${GREEN}✅ README.md 引用检查完成${NC}"
else
    echo -e "${YELLOW}⚠️  未发现 README.md${NC}"
fi
echo ""

# 3. 检查所有 shell 脚本是否有执行权限
echo "--- 脚本权限检查 ---"
find "$ROOT" -name "*.sh" -type f 2>/dev/null | while read -r script; do
    if [ ! -x "$script" ]; then
        echo -e "${YELLOW}⚠️  脚本无执行权限: $script${NC}"
        echo "   建议: chmod +x $script"
    fi
done
echo -e "${GREEN}✅ 脚本权限检查完成${NC}"
echo ""

# 4. 检查 gql-skills 引用（如果 SKILL.md 中有）
echo "--- gql-skills 同步检查 ---"
if [ -f "$ROOT/SKILL.md" ]; then
    name=$(grep '^name:' "$ROOT/SKILL.md" | head -1 | cut -d: -f2 | xargs || true)
    if [ -n "$name" ]; then
        echo "skill 名称: $name"
        # 检查 gql-skills 中是否有此 skill
        if grep -q "$name" ~/repos/gql-skills/SKILL.md 2>/dev/null || grep -q "$name" ~/repos/gql-skills/README.md 2>/dev/null; then
            echo -e "${GREEN}✅ gql-skills 中已注册${NC}"
        else
            echo -e "${YELLOW}⚠️  gql-skills 中未找到 $name${NC}"
        fi
    fi
fi
echo ""

# 5. 汇总
echo "=== 汇总 ==="
if [ "$ERRORS" -eq 0 ]; then
    echo -e "${GREEN}✅ 所有检查通过，可安全提交${NC}"
    exit 0
else
    echo -e "${RED}❌ 发现 $ERRORS 个问题，请修复后再提交${NC}"
    exit 1
fi
