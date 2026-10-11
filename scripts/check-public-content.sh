#!/usr/bin/env bash
# 扫描对外公开的内容，发现内部信息（IP、凭据、脚本名、内部域名等）即失败
# 用法: scripts/check-public-content.sh [目录...]
#   默认扫描 content/product 和 content/releases（草稿也扫描）
# 禁止模式:
#   scripts/public-content-denylist.txt        通用模式（提交）
#   scripts/public-content-denylist.local.txt  具体敏感词（不提交，存在时加载）
# 退出码: 0 = 没有命中；1 = 有命中；2 = 用法错误或通用词表缺失
set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DENY="$SCRIPT_DIR/public-content-denylist.txt"
DENY_LOCAL="$SCRIPT_DIR/public-content-denylist.local.txt"

if [ ! -f "$DENY" ]; then
  echo "错误: 找不到通用禁止模式文件 $DENY" >&2
  exit 2
fi

if [ "$#" -gt 0 ]; then
  DIRS=("$@")
else
  DIRS=("$ROOT/content/product" "$ROOT/content/releases")
fi

# 合并词表，去掉空行和注释
PATTERNS="$(mktemp)"
trap 'rm -f "$PATTERNS"' EXIT
grep -vE '^[[:space:]]*(#|$)' "$DENY" > "$PATTERNS"
if [ -f "$DENY_LOCAL" ]; then
  grep -vE '^[[:space:]]*(#|$)' "$DENY_LOCAL" >> "$PATTERNS"
  echo "已加载本地敏感词表"
else
  echo "提示: 未加载本地敏感词表（$DENY_LOCAL 不存在），只检查通用模式"
fi

FILES=0
HITS=0
for dir in "${DIRS[@]}"; do
  if [ ! -d "$dir" ]; then
    echo "跳过: 目录不存在 $dir"
    continue
  fi
  while IFS= read -r -d '' file; do
    FILES=$((FILES + 1))
    while IFS= read -r pattern; do
      while IFS= read -r line; do
        [ -z "$line" ] && continue
        echo "${file#"$ROOT"/}:${line%%:*}: 命中模式 $pattern"
        HITS=$((HITS + 1))
      done < <(grep -nE -- "$pattern" "$file" 2>/dev/null)
    done < "$PATTERNS"
  done < <(find "$dir" -type f \( -name '*.md' -o -name '*.toml' -o -name '*.yaml' -o -name '*.yml' -o -name '*.html' \) -print0)
done

echo "----"
echo "扫描 $FILES 个文件，命中 $HITS 处"
[ "$HITS" -eq 0 ]
