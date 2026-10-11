#!/usr/bin/env bash
# 对 hugo55 构建产物做结构断言（「我的产品」栏目）
# 用法: scripts/check-products-build.sh <构建输出目录>
#   先自行构建: hugo55 -d <目录>   （不要加 --gc；审阅草稿时加 -D）
# 退出码: 0 = 全部通过；1 = 有断言失败；2 = 用法错误
set -u

OUT="${1:-}"
if [ -z "$OUT" ] || [ ! -f "$OUT/index.html" ]; then
  echo "用法: $0 <构建输出目录>（目录下须有 index.html）" >&2
  exit 2
fi

PRODUCTS="pp-writer pp-runner"
FAILED=0
TOTAL=0

pass() { TOTAL=$((TOTAL + 1)); echo "PASS  $1"; }
fail() { TOTAL=$((TOTAL + 1)); FAILED=$((FAILED + 1)); echo "FAIL  $1"; }

# 把 HTML 压成一行，方便跨行匹配
flat() { tr '\n' ' ' < "$1"; }

# 断言 #9：原有首页区块与菜单项不变
home=$(flat "$OUT/index.html")
if grep -q 'id="posts"' <<<"$home" && grep -q 'id="about"' <<<"$home"; then
  pass "#9 首页仍含「最新博文」(#posts) 和「关于」(#about) 区块"
else
  fail "#9 首页缺少 #posts 或 #about 区块"
fi
missing=""
for href in 'href="/#"' 'href="/#posts"' 'href="/#about"'; do
  grep -qF "$href" <<<"$home" || missing="$missing $href"
done
if [ -z "$missing" ]; then
  pass "#9 原有菜单项「首页 / 博客 / 关于」链接不变"
else
  fail "#9 原有菜单项链接缺失:$missing"
fi

# 断言 #1：导航含「我的产品」下拉，依次含两个子项
menu=$(grep -o 'dropdown-menu.*' <<<"$home" | head -1)
w=$(grep -bo 'href="/product/pp-writer/"' <<<"$menu" | head -1 | cut -d: -f1)
r=$(grep -bo 'href="/product/pp-runner/"' <<<"$menu" | head -1 | cut -d: -f1)
if grep -q '我的产品' <<<"$home" && [ -n "$w" ] && [ -n "$r" ] && [ "$w" -lt "$r" ] \
   && grep -q '小纸条（PP-Writer）' <<<"$menu" && grep -q '跑步（PP-Runner）' <<<"$menu"; then
  pass "#1 导航含「我的产品」下拉，依次为小纸条、跑步"
else
  fail "#1 导航缺少「我的产品」下拉或子项顺序/文字不对"
fi

# 断言 #2：两个产品页存在
for p in $PRODUCTS; do
  if [ -f "$OUT/product/$p/index.html" ]; then
    pass "#2 产品页 /product/$p/ 存在"
  else
    fail "#2 产品页 /product/$p/ 不存在"
  fi
done

# 断言 #4：产品介绍卡片数 3–6
for p in $PRODUCTS; do
  f="$OUT/product/$p/index.html"
  [ -f "$f" ] || { fail "#4 /product/$p/ 不存在，无法检查产品介绍"; continue; }
  intro=$(flat "$f" | sed -n 's/.*id="intro"\(.*\)/\1/p' | sed 's/<section.*//')
  n=$(grep -o 'featurette-icon' <<<"$intro" | wc -l | tr -d ' ')
  if [ "$n" -ge 3 ] && [ "$n" -le 6 ]; then
    pass "#4 /product/$p/ 产品介绍有 $n 张能力卡片"
  else
    fail "#4 /product/$p/ 产品介绍能力卡片数为 ${n}（应为 3–6）"
  fi
done

# 断言 #5：下载区块全部为内测，没有下载按钮
for p in $PRODUCTS; do
  f="$OUT/product/$p/index.html"
  [ -f "$f" ] || { fail "#5 /product/$p/ 不存在，无法检查下载"; continue; }
  dl=$(flat "$f" | sed -n 's/.*id="download"\(.*\)/\1/p' | sed 's/<section.*//')
  if [ -z "$dl" ]; then
    fail "#5 /product/$p/ 没有下载区块 (#download)"
  elif grep -q 'download-btn' <<<"$dl"; then
    fail "#5 /product/$p/ 下载区块出现了下载按钮（当前应全部为内测）"
  elif ! grep -q '内测中，暂未开放下载' <<<"$dl"; then
    fail "#5 /product/$p/ 下载区块缺少「内测中，暂未开放下载」"
  else
    pass "#5 /product/$p/ 下载区块为内测状态，无下载按钮"
  fi
done

# 断言 #3：三个区块按顺序出现
for p in $PRODUCTS; do
  f="$OUT/product/$p/index.html"
  [ -f "$f" ] || { fail "#3 /product/$p/ 不存在"; continue; }
  page=$(flat "$f")
  i=$(grep -bo 'id="intro"' <<<"$page" | head -1 | cut -d: -f1)
  d=$(grep -bo 'id="download"' <<<"$page" | head -1 | cut -d: -f1)
  n=$(grep -bo 'id="whatsnew"' <<<"$page" | head -1 | cut -d: -f1)
  if [ -n "$i" ] && [ -n "$d" ] && [ -n "$n" ] && [ "$i" -lt "$d" ] && [ "$d" -lt "$n" ]; then
    pass "#3 /product/$p/ 依次含产品介绍、下载、新功能三个区块"
  else
    fail "#3 /product/$p/ 缺少区块或顺序不对（intro=${i} download=${d} whatsnew=${n}）"
  fi
done

# 断言 #6 #7 #8：「新功能」链接
for p in $PRODUCTS; do
  f="$OUT/product/$p/index.html"
  [ -f "$f" ] || continue
  news=$(flat "$f" | sed -n 's/.*id="whatsnew"\(.*\)/\1/p' | sed 's/<\/section>.*//')
  links=$(grep -oE 'href="/releases/[^"]*#[^"]+"' <<<"$news" | sed 's/^href="//;s/"$//' | sort -u)
  if [ -z "$links" ]; then
    fail "#6 /product/$p/ 「新功能」没有指向 Releases 小节的链接"
  else
    bad=""
    for l in $links; do
      path=${l%%#*}; id=${l#*#}
      t="$OUT${path}index.html"
      { [ -f "$t" ] && grep -q "id=\"$id\"" "$t"; } || bad="$bad $l"
    done
    if [ -z "$bad" ]; then
      pass "#6 /product/$p/ 「新功能」$(wc -w <<<"$links" | tr -d ' ') 个链接都能落到 Releases 对应小节"
    else
      fail "#6 /product/$p/ 以下链接找不到目标小节:$bad"
    fi
    other=$(grep -v "^/releases/$p/" <<<"$links" || true)
    if [ -z "$other" ]; then
      pass "#8 /product/$p/ 「新功能」只链接到本产品的 Releases"
    else
      fail "#8 /product/$p/ 「新功能」链接到了其他产品: $other"
    fi
  fi
  if grep -q "href=\"/releases/$p/\"" <<<"$news" && grep -q '查看全部 Releases' <<<"$news" && [ -f "$OUT/releases/$p/index.html" ]; then
    pass "#7 /product/$p/ 有「查看全部 Releases」且列表页存在"
  else
    fail "#7 /product/$p/ 缺少「查看全部 Releases」链接或列表页不存在"
  fi
done

# 断言 #10：全站不含幕布链接
hits=$(grep -rl 'mubu\.com' "$OUT" --include='*.html' 2>/dev/null | head -3)
if [ -z "$hits" ]; then
  pass "#10 页面中没有 mubu.com 链接"
else
  fail "#10 发现 mubu.com 链接: $hits"
fi

echo "----"
echo "共 $TOTAL 条断言，失败 $FAILED 条"
[ "$FAILED" -eq 0 ]
