#!/usr/bin/env bash
# 姜小胡提问 skill 一键部署（大磊分发给小伙伴）
# 用法: bash -c "$(curl -fsSL <URL>/install.sh)"
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

echo "→ 3/4 解压到 ~/.claude/skills/"
mkdir -p ~/.claude/skills
unzip -o -q jxh_ask.zip -d ~/.claude/skills/ 2>/dev/null || unzip -o jxh_ask.zip -d ~/.claude/skills/
[ -f ~/.claude/skills/姜小胡提问/SKILL.md ] && echo "   ✓ 已安装: ~/.claude/skills/姜小胡提问/"

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
echo "✅ 部署完成！"
echo "下一步：运行 zsxq-cli auth login 登录你的星球账号（需已加入「姜胡说」星球）"
echo "然后在 Claude Code 里输入：你的问题 + 以上问题发到姜小胡"
