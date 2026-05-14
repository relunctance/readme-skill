#!/usr/bin/env bash
# readme-skill/scripts/check_readme.sh
# README 质量检查脚本

set -e

PROJECT_DIR="${1:-.}"

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=== README 质量检查 ==="
echo "项目: $PROJECT_DIR"
echo ""

# Step 1: 检测所有 README 变体
readmes=$(find "$PROJECT_DIR" -maxdepth 2 -iname "readme*" -type f 2>/dev/null | sort)

if [ -z "$readmes" ]; then
    echo -e "${YELLOW}⚠️  未发现 README 文件${NC}"
    echo "建议: 创建 README.md"
    exit 1
fi

echo "发现 README 变体:"
echo "$readmes" | while read -r rm; do
    echo "  - $rm"
done
echo ""

# Step 2: 逐个检查质量
total_score=0
count=0

check_single() {
    local readme="$1"
    local dir=$(dirname "$readme")
    local name=$(basename "$readme")
    local score=0
    local issues=""

    # 徽章检查
    if grep -q '!\[license\]' "$readme" 2>/dev/null; then
        score=$((score + 20))
    else
        issues+="缺少 license 徽章; "
    fi

    if grep -q '!\[version\]' "$readme" 2>/dev/null; then
        score=$((score + 20))
    else
        issues+="缺少 version 徽章; "
    fi

    if grep -q '!\[platforms\]' "$readme" 2>/dev/null; then
        score=$((score + 10))
    else
        issues+="缺少 platforms 徽章; "
    fi

    # 关键章节检查
    if grep -q '^## 触发条件' "$readme" 2>/dev/null; then
        score=$((score + 20))
    else
        issues+="缺少「触发条件」章节; "
    fi

    if grep -q '^## 安装' "$readme" 2>/dev/null; then
        score=$((score + 15))
    else
        issues+="缺少「安装」章节; "
    fi

    if grep -q '^## ' "$readme" 2>/dev/null; then
        local sections=$(grep -c '^## ' "$readme" 2>/dev/null || echo 0)
        score=$((score + sections * 5))
    fi

    # 输出结果
    echo "--- $name ---"
    if [ "$score" -ge 80 ]; then
        echo -e "得分: ${GREEN}${score}/100 ✅${NC}"
    elif [ "$score" -ge 50 ]; then
        echo -e "得分: ${YELLOW}${score}/100 ⚠️${NC}"
    else
        echo -e "得分: ${RED}${score}/100 ❌${NC}"
    fi

    if [ -n "$issues" ]; then
        echo "问题: $issues"
    else
        echo -e "状态: ${GREEN}无明显问题${NC}"
    fi
    echo ""

    total_score=$((total_score + score))
    count=$((count + 1))
}

echo "$readmes" | while read -r rm; do
    check_single "$rm"
done

# ============================================================
# 表格校验：检测列数不一致
# ============================================================
check_tables() {
    local file="$1"
    local name=$(basename "$file")
    local errors=0
    local in_table=0
    local prev_cols=0
    local table_start=0
    local linenum=0

    while IFS= read -r line; do
        linenum=$((linenum + 1))

        # 判断是否表格行（以 | 开头和结尾）
        is_row=$(echo "$line" | grep -cE '^\s*\|.*\|\s*$' || true)
        if [ "$is_row" -eq 0 ]; then
            in_table=0
            continue
        fi

        # 跳过 markdown 表格分隔行 |---|---|
        if echo "$line" | grep -qE '^\s*\|\s*[-:]+\s*\|'; then
            continue
        fi

        # 跳过空行
        stripped=$(echo "$line" | sed 's/^\s*|//' | sed 's/|\s*$//' | tr -d ' ')
        [ -z "$stripped" ] && continue

        # 计算列数
        col_count=$(echo "$stripped" | awk -F'|' '{print NF}')

        if [ "$in_table" -eq 0 ]; then
            in_table=1
            prev_cols=$col_count
            table_start=$linenum
        else
            if [ "$col_count" -ne "$prev_cols" ] && [ "$col_count" -gt 0 ]; then
                echo -e "${RED}❌ $name:$linenum — 列数不一致（期望 $prev_cols 列，实际 $col_count 列）${NC}"
                echo "   行内容: ${line:0:100}"
                errors=$((errors + 1))
                prev_cols=$col_count
            fi
        fi
    done < "$file"

    return $errors
}

echo "--- 表格结构检查 ---"
total_table_errors=0
for rm in $readmes; do
    check_tables "$rm" || total_table_errors=$((total_table_errors + $?))
done
if [ "$total_table_errors" -eq 0 ]; then
    echo -e "${GREEN}✅ 所有表格结构正常${NC}"
else
    echo -e "${RED}❌ 共发现 $total_table_errors 个表格问题${NC}"
fi
echo ""

# ============================================================
# 徽章 + 章节检查
# ============================================================

# 多语言变体检测
if [ -f "$PROJECT_DIR/README.md" ]; then
    main_readme="$PROJECT_DIR/README.md"
elif [ -f "$PROJECT_DIR/readme.md" ]; then
    main_readme="$PROJECT_DIR/readme.md"
fi

if [ -n "$main_readme" ]; then
    echo "--- 多语言变体同步检查 ---"
    dir=$(dirname "$main_readme")

    for variant in "$dir/README.zh.md" "$dir/README_en.md" "$dir/README-en.md"; do
        if [ -f "$variant" ]; then
            name=$(basename "$variant")
            # 简单检查：主版本有的章节变体是否也有
            main_sections=$(grep -c '^## ' "$main_readme" 2>/dev/null || echo 0)
            variant_sections=$(grep -c '^## ' "$variant" 2>/dev/null || echo 0)
            diff=$((main_sections - variant_sections))

            if [ "$diff" -gt 2 ]; then
                echo -e "${YELLOW}⚠️  $name 章节数差异较大（主版本 $main_sections vs 变体 $variant_sections）${NC}"
            else
                echo -e "${GREEN}✅ $name 章节结构正常${NC}"
            fi
        fi
    done
fi

# 最终汇总
echo ""
echo "=== 汇总 ==="
if [ "$count" -gt 0 ]; then
    avg=$((total_score / count))
    echo "平均得分: $avg/100"
    if [ "$avg" -ge 80 ]; then
        echo -e "状态: ${GREEN}整体良好${NC}"
    elif [ "$avg" -ge 50 ]; then
        echo -e "状态: ${YELLOW}需要改进${NC}"
    else
        echo -e "状态: ${RED}建议重新生成 README${NC}"
    fi
fi
