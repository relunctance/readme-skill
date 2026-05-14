#!/usr/bin/env bash
# skill-pre-commit-check.sh
# Skill 提交前必检：验证所有引用的文件/脚本/链接是否存在
# 只检查代码块内的本地路径引用，不检查 markdown 文字内容
# 用法: bash scripts/pre-commit-check.sh <skill-repo-root>

ROOT="${1:-.}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

ERRORS=0

# 检查一个文件中的代码块路径引用
check_file() {
    local file="$1"
    local label="$2"

    if [ ! -f "$file" ]; then
        echo -e "${YELLOW}⚠️  未找到: $label${NC}"
        return
    fi

    local in_code=0
    local linenum=0
    local errors=0

    while IFS= read -r line; do
        linenum=$((linenum + 1))

        # 跟踪代码块状态
        if echo "$line" | grep -qE '^\s*```'; then
            if [ "$in_code" -eq 0 ]; then
                in_code=1
            else
                in_code=0
            fi
            continue
        fi

        # 只在代码块内检查
        [ "$in_code" -eq 0 ] && continue

        # 检查有意义的本地路径模式
        # 1. ln -sf ~/xxx/xxx
        echo "$line" | grep -oE 'ln -sf [^ ]+' | while read -r frag; do
            path=$(echo "$frag" | awk '{print $3}')
            if [ -n "$path" ] && [[ "$path" == ~/* || "$path" == /* ]]; then
                expanded="${path/#\~/$HOME}"
                if [ ! -e "$expanded" ]; then
                    echo -e "${RED}❌ $file:$linenum  —  ln -sf 目标不存在: $path${NC}"
                    ERRORS=$((ERRORS + 1))
                    errors=$((errors + 1))
                fi
            fi
        done

        # 2. mkdir -p ~/xxx 或 mkdir -p $HOME/xxx
        echo "$line" | grep -oE 'mkdir -p ([~$][^ ]+|[^ ]+/[^*$]+)' | while read -r frag; do
            path=$(echo "$frag" | awk '{print $3}' | tr -d "'\"")
            [ -z "$path" ] && continue
            expanded="${path/#\~/$HOME}"
            expanded="${expanded/\$HOME/$HOME}"
            expanded=$(echo "$expanded" | sed 's/\$\{HOME\}/'"$HOME"'/g')
            if [[ "$expanded" == /* ]] && [ ! -e "$expanded" ]; then
                # mkdir -p 的路径不存在是正常的（会创建），只警告
                :  # skip mkdir targets
            fi
        done

        # 3. cd ~/xxx 或 cd $HOME/xxx 或 cd /home/xxx
        echo "$line" | grep -oE 'cd ([~$][^ ]+|[^ ]+/[^*$"'"'"']+)' | while read -r frag; do
            path=$(echo "$frag" | cut -d' ' -f2 | tr -d "'\"")
            [ -z "$path" ] && continue
            expanded="${path/#\~/$HOME}"
            expanded="${expanded/\$HOME/$HOME}"
            expanded=$(echo "$expanded" | sed 's/\$\{HOME\}/'"$HOME"'/g')
            if [[ "$expanded" == /* ]]; then
                # 目标目录可能不存在，只检查绝对路径且不在同一 repo 内的情况
                if [ ! -d "$expanded" ] && [[ "$expanded" != "$ROOT"/* ]]; then
                    # 可能是 repo 外的路径，正常
                    :
                fi
            fi
        done

        # 4. references/xxx / scripts/xxx / templates/xxx
        echo "$line" | grep -oE '(references|scripts|templates|assets)/[a-zA-Z0-9_./-]+' | while read -r ref; do
            # 去除末尾的 ] ; 等
            ref=$(echo "$ref" | sed 's/[@\])].*//')
            full="$ROOT/$ref"
            if [ ! -e "$full" ]; then
                echo -e "${RED}❌ $file:$linenum  —  引用文件不存在: $ref${NC}"
                ERRORS=$((ERRORS + 1))
                errors=$((errors + 1))
            fi
        done

        # 5. ./xxx.sh 或 ./scripts/xxx
        echo "$line" | grep -oE '\./[a-zA-Z0-9_/.-]+\.(sh|py|yaml|yml|json)' | while read -r ref; do
            full="$ROOT/$ref"
            if [ ! -e "$full" ]; then
                echo -e "${RED}❌ $file:$linenum  —  引用脚本不存在: $ref${NC}"
                ERRORS=$((ERRORS + 1))
                errors=$((errors + 1))
            fi
        done

    done < "$file"

    if [ "$errors" -eq 0 ]; then
        echo -e "${GREEN}✅ $label — 无路径问题${NC}"
    fi
}

echo "=== Skill Pre-Commit Check ==="
echo "检查: $ROOT"
echo ""

# 检查 SKILL.md 和 README.md
check_file "$ROOT/SKILL.md" "SKILL.md"
check_file "$ROOT/README.md" "README.md"
echo ""

# 脚本权限检查
echo "--- 脚本权限检查 ---"
find "$ROOT" -name "*.sh" -type f 2>/dev/null | while read -r script; do
    if [ ! -x "$script" ]; then
        echo -e "${YELLOW}⚠️  脚本无执行权限: $script${NC}"
    fi
done
echo -e "${GREEN}✅ 脚本权限检查完成${NC}"
echo ""

# gql-skills 注册检查
echo "--- gql-skills 同步检查 ---"
if [ -f "$ROOT/SKILL.md" ]; then
    name=$(grep '^name:' "$ROOT/SKILL.md" 2>/dev/null | head -1 | cut -d: -f2 | xargs)
    if [ -n "$name" ]; then
        echo "skill: $name"
        if grep -q "$name" ~/repos/gql-skills/SKILL.md 2>/dev/null || \
           grep -q "$name" ~/repos/gql-skills/README.md 2>/dev/null; then
            echo -e "${GREEN}✅ gql-skills 中已注册${NC}"
        else
            echo -e "${YELLOW}⚠️  gql-skills 中未找到 $name${NC}"
        fi
    fi
fi
echo ""

# 汇总
echo "=== 汇总 ==="
if [ "$ERRORS" -eq 0 ]; then
    echo -e "${GREEN}✅ 所有检查通过，可安全提交${NC}"
    exit 0
else
    echo -e "${RED}❌ 发现 $ERRORS 个问题，请修复后再提交${NC}"
    exit 1
fi
