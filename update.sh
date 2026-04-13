#!/bin/bash
# 一键更新选题库热点数据并推送到 GitHub Pages
# 用法: ./update.sh [天数]  (默认15天)

set -e

DAYS=${1:-15}
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SITE_DIR="$SCRIPT_DIR"
FETCH_SCRIPT="/Users/wanglu/Desktop/选题库资料/牛客热点抓取sill/nowcoder-hotmarketing/scripts/fetch_hotpoints.py"
OUTPUT_JSON="$SITE_DIR/nowcoder_hotpoints.json"

# 检查 Metabase 凭证
if [ -z "$METABASE_USERNAME" ] || [ -z "$METABASE_PASSWORD" ]; then
  echo "⚠️  请先配置 Metabase 凭证:"
  echo "  export METABASE_USERNAME=\"your-email@nowcoder.com\""
  echo "  export METABASE_PASSWORD=\"your-password\""
  echo ""
  echo "或在 ~/.zshrc 中添加以上两行后执行 source ~/.zshrc"
  exit 1
fi

echo "📊 正在从 Metabase 拉取最近 ${DAYS} 天的热点数据..."
python3 "$FETCH_SCRIPT" --days "$DAYS" --min-views 50 --min-cvr 0.0 --output "$OUTPUT_JSON" > /dev/null

echo "✅ 热点数据已更新: $OUTPUT_JSON"

# 推送到 GitHub
cd "$SITE_DIR"
if git diff --quiet nowcoder_hotpoints.json 2>/dev/null; then
  echo "ℹ️  数据无变化，无需推送"
else
  git add nowcoder_hotpoints.json
  git commit -m "更新热点数据 $(date +%Y-%m-%d)"
  git push
  echo "🚀 已推送到 GitHub Pages，对方刷新页面即可看到最新数据"
fi

echo ""
echo "🔗 页面地址: https://wlu229123-prog.github.io/nowcoder-topic-lib/"
