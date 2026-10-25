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
SITE_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
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

# 断言 #1：导航含「我的作品」下拉（排在「关于」前面），依次含两个子项
menu=$(grep -o 'dropdown-menu.*' <<<"$home" | head -1)
w=$(grep -bo 'href="/product/pp-writer/"' <<<"$menu" | head -1 | cut -d: -f1)
r=$(grep -bo 'href="/product/pp-runner/"' <<<"$menu" | head -1 | cut -d: -f1)
works=$(grep -bo '<span>我的作品</span>' <<<"$home" | head -1 | cut -d: -f1)
about=$(grep -bo '<span>关于</span>' <<<"$home" | head -1 | cut -d: -f1)
if [ -n "$works" ] && [ -n "$about" ] && [ "$works" -lt "$about" ] && [ -n "$w" ] && [ -n "$r" ] && [ "$w" -lt "$r" ] \
   && grep -q '小纸条（PP-Writer）' <<<"$menu" && grep -q '跑步（PP-Runner）' <<<"$menu"; then
  pass "#1 导航含「我的作品」下拉且在「关于」前面，依次为小纸条、跑步"
else
  fail "#1 导航「我的作品」下拉缺失、位置不在「关于」前，或子项顺序/文字不对"
fi

# 断言 #12：产品页第一个区块是 App 关于区（Logo + 名称 + 副标题 + 标语）
for p in $PRODUCTS; do
  f="$OUT/product/$p/index.html"
  [ -f "$f" ] || continue
  page=$(flat "$f")
  first=$(grep -oE '<section id="[a-z_-]+"' <<<"$page" | head -1)
  info=$(sed -n 's/.*id="appinfo"\(.*\)/\1/p' <<<"$page" | sed 's/<\/section>.*//')
  if [ "$first" = '<section id="appinfo"' ] && grep -q 'app-logo' <<<"$info" \
     && grep -q 'app-name' <<<"$info" && grep -q 'app-subtitle' <<<"$info" && grep -q 'app-slogan' <<<"$info"; then
    pass "#12 /product/$p/ 第一个区块是 App 关于区（Logo、名称、副标题、标语齐全）"
  else
    fail "#12 /product/$p/ 第一个区块不是完整的 App 关于区（第一个区块: ${first:-无}）"
  fi
done

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

# 断言 #11：标题区按钮跳到本页的「下载」「新功能」区块（不能变成首页锚点 /#xxx）
for p in $PRODUCTS; do
  f="$OUT/product/$p/index.html"
  [ -f "$f" ] || continue
  hero=$(flat "$f" | sed -n 's/.*id="hero"\(.*\)/\1/p' | sed 's/<\/section>.*//')
  for anchor in download whatsnew; do
    if grep -q "href=\"/product/$p/#$anchor\"" <<<"$hero" && grep -q "id=\"$anchor\"" "$f"; then
      pass "#11 /product/$p/ 标题区按钮跳到本页 #$anchor"
    else
      got=$(grep -oE "href=\"[^\"]*#$anchor\"" <<<"$hero" | head -1)
      fail "#11 /product/$p/ 标题区按钮没有跳到本页 #${anchor}（实际: ${got:-无}）"
    fi
  done
done

# 断言 #13：标题区不再显示与 App 关于区重复的大标题（区块带 product-hero 类，由 custom.css 隐藏 .hero-title）
for p in $PRODUCTS; do
  f="$OUT/product/$p/index.html"
  [ -f "$f" ] || continue
  if grep -qE '<section id="hero" class="[^"]*product-hero' "$f" && grep -rqs 'product-hero .hero-title' "$OUT"/css/; then
    pass "#13 /product/$p/ 标题区隐藏了重复的大标题"
  else
    fail "#13 /product/$p/ 标题区仍显示重复的大标题"
  fi
done

# 断言 #14：Releases 页里的图片都存在，且有配图的功能小节确实渲染出了图片
missing=""
imgs=0
for f in $(find "$OUT/releases" -name index.html); do
  for src in $(grep -oE '<img class="release-img[^"]*" src="[^"]+"' "$f" | sed -E 's/.*src="([^"]+)"/\1/'); do
    imgs=$((imgs + 1))
    case "$src" in http*) continue ;; esac
    [ -f "$OUT$src" ] || missing="$missing $src"
  done
done
expected=$(grep -rlE '^ *(image|images):' "$SITE_ROOT/content/releases" 2>/dev/null | wc -l | tr -d ' ')
if [ -n "$missing" ]; then
  fail "#14 Releases 页有图片文件不存在:$missing"
elif [ "$expected" -gt 0 ] && [ "$imgs" -eq 0 ]; then
  fail "#14 有 $expected 个发布配置了图片，但页面上没有渲染出任何图片"
else
  pass "#14 Releases 功能小节共 ${imgs} 张配图，全部存在"
fi

# 断言 #15：App 关于区有入场动画；副标题打字机效果保留完整文字（无 JS / 搜索引擎可见）
for p in $PRODUCTS; do
  f="$OUT/product/$p/index.html"
  [ -f "$f" ] || continue
  info=$(flat "$f" | sed -n 's/.*id="appinfo"\(.*\)/\1/p' | sed 's/<\/section>.*//')
  sub=$(grep -oE 'data-typewriter="[^"]+"' <<<"$info" | head -1 | sed 's/data-typewriter="//;s/"$//')
  if grep -q 'app-about app-animate' <<<"$info" && [ -n "$sub" ] && grep -q "class=\"tw-ghost\">$sub<" <<<"$info"; then
    pass "#15 /product/$p/ 关于区有入场动画，副标题「${sub}」打字机效果且保留完整文字"
  else
    fail "#15 /product/$p/ 关于区缺少入场动画或打字机副标题"
  fi
done

# 断言 #16：截图展示区紧跟关于区，至少 3 张图，图片都存在，标签数与图片数一致
for p in $PRODUCTS; do
  f="$OUT/product/$p/index.html"
  [ -f "$f" ] || continue
  page=$(flat "$f")
  order=$(grep -oE '<section id="[a-z_-]+"' <<<"$page" | head -2 | sed 's/.*id="//;s/"//' | tr '\n' ' ')
  show=$(sed -n 's/.*id="showcase"\(.*\)/\1/p' <<<"$page" | sed 's/<\/section>.*//')
  n=$(grep -oE '<img class="showcase-img' <<<"$show" | wc -l | tr -d ' ')
  t=$(grep -oE 'class="showcase-tab[ "]' <<<"$show" | wc -l | tr -d ' ')
  bad=""
  for src in $(grep -oE '<img class="showcase-img[^"]*" src="[^"]+"' <<<"$show" | sed -E 's/.*src="([^"]+)"/\1/'); do
    [ -f "$OUT$src" ] || bad="$bad $src"
  done
  if [ "$order" = "appinfo showcase " ] && [ "$n" -ge 3 ] && [ "$n" -eq "$t" ] && [ -z "$bad" ]; then
    pass "#16 /product/$p/ 截图展示区紧跟关于区，${n} 张图、${t} 个标签，图片都存在"
  else
    fail "#16 /product/$p/ 截图展示区不符合要求（区块顺序: ${order}图片 ${n} 张，标签 ${t} 个，缺失:${bad:-无}）"
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
