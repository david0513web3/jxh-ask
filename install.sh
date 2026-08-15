#!/usr/bin/env bash
# 姜小胡提问 skill 通用部署（Claude Code / Codex / Hermes 一装全通）
# 用法: PASS=<密码> bash -c "$(curl -fsSL <URL>/install.sh)"
set -e
PASS="${PASS:-}"
if [ -z "$PASS" ]; then
  read -r -p "请输入部署密码: " PASS
fi
REPO='david0513web3/jxh-ask'
BRANCH='main'
BASE_GH="https://raw.githubusercontent.com/$REPO/$BRANCH"
BASE_CDN="https://cdn.jsdelivr.net/gh/$REPO@$BRANCH"

echo "→ 1/4 下载加密包"
mkdir -p /tmp/jxh_install && cd /tmp/jxh_install
if ! curl -fsSL -o jxh_ask.zip.enc "$BASE_GH/jxh_ask.zip.enc"; then
  echo "   (GitHub 直连失败，切换 CDN)"
  curl -fsSL -o jxh_ask.zip.enc "$BASE_CDN/jxh_ask.zip.enc" || { echo "❌ 下载失败，请检查网络"; exit 1; }
fi

echo "→ 2/4 解密"
openssl enc -d -aes-256-cbc -pbkdf2 -pass pass:"$PASS" -in jxh_ask.zip.enc -out jxh_ask.zip || { echo "❌ 解密失败（openssl 版本过旧？）"; exit 1; }

echo "→ 3/4 部署到本机所有 AI 客户端"
rm -rf jxh_unzip && mkdir jxh_unzip && unzip -o -q jxh_ask.zip -d jxh_unzip/
installed=0
for dir in "$HOME/.claude/skills" "$HOME/.codex/skills" "$HOME/.hermes/skills"; do
  if [ -d "$dir" ]; then
    rm -rf "$dir/姜小胡提问"
    cp -R jxh_unzip/姜小胡提问 "$dir/姜小胡提问"
    rm -rf "$dir/姜小胡提问/__pycache__"
    echo "   ✓ 已装到 $dir"
    installed=1
  fi
done
if [ "$installed" = "1" ]; then
  echo "   (未检测到的客户端会自动跳过：只有 Claude Code 就只装 Claude Code)"
else
  echo "❌ 未检测到任何 AI 客户端的 skills 目录（~/.claude/skills / ~/.codex/skills / ~/.hermes/skills）"
  exit 1
fi

echo "→ 4/4 检查 zsxq-cli"
if command -v zsxq-cli >/dev/null 2>&1; then
  echo "   ✓ zsxq-cli 已存在"
else
  echo "   安装 zsxq-cli..."
  if ! npm install -g zsxq-cli 2>/dev/null; then
    npm install -g --prefix ~/.npm-global zsxq-cli 2>/dev/null || { echo "❌ 安装 zsxq-cli 失败，请先安装 Node.js 后重试"; exit 1; }
    export PATH="$HOME/.npm-global/bin:$PATH"
    echo "   (已装到 ~/.npm-global/bin，若提示找不到命令，重开终端即可)"
  fi
fi

echo ""
echo "✅ 部署完成！本机的 Claude Code / Codex / Hermes 已全部就绪。"
echo "用法：输入你的问题 + 「以上问题发到姜小胡」"
echo "（Hermes 需重启网关后才识别新 skill；首次使用前运行 zsxq-cli auth login 登录星球账号）"
