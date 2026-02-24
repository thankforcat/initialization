#!/bin/bash

# 开启错误检测：一旦有命令执行失败，直接停止脚本，避免一路错到底
set -e

echo "🚀 开始全自动初始化 Zsh、Powerlevel10k 及核心插件..."

# ==========================================
# 1. 基础环境检查与安装 (适配全新的 VPS)
# ==========================================
if ! command -v zsh >/dev/null 2>&1 || ! command -v git >/dev/null 2>&1 || ! command -v curl >/dev/null 2>&1; then
    echo "📦 正在安装必要的依赖 (zsh, git, curl)..."
    # 判断包管理器，兼容 Debian/Ubuntu 和 CentOS/RHEL
    if command -v apt-get >/dev/null 2>&1; then
        apt-get update && apt-get install -y curl wget git zsh nano cron
    elif command -v yum >/dev/null 2>&1; then
        yum install -y curl wget git zsh nano cron
    else
        echo "❌ 无法自动安装依赖，请手动安装 zsh, git, curl 后重试。"
        exit 1
    fi
fi

# ==========================================
# 2. 静默安装 Oh My Zsh
# ==========================================
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "✨ 正在静默安装 Oh My Zsh..."
    # 使用 --unattended 确保脚本不会在此处暂停等待用户输入
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo "✅ Oh My Zsh 已安装，跳过。"
fi

# 定义 Oh My Zsh 自定义目录变量
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"

# ==========================================
# 3. 安装主题与插件到正确目录
# ==========================================
echo "🎨 正在下载 Powerlevel10k 和 效率插件..."

# 安装 Powerlevel10k 主题
if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
fi

# 安装 zsh-autosuggestions (历史命令自动灰色提示)
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

# 安装 zsh-syntax-highlighting (命令语法高亮，输入正确变绿，错误变红)
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

# ==========================================
# 4. 应用你的个人配置
# ==========================================
echo "📥 正在拉取你的专属配置文件..."
ZSHRC_URL="https://raw.githubusercontent.com/thankforcat/initialization/refs/heads/main/linux/.zshrc"
P10K_URL="https://raw.githubusercontent.com/thankforcat/initialization/refs/heads/main/linux/.p10k.zsh"

# 强制覆盖当前的配置文件
curl -fsSL -o "$HOME/.zshrc" "$ZSHRC_URL"
curl -fsSL -o "$HOME/.p10k.zsh" "$P10K_URL"

# 强制更新 .zshrc 中的插件列表，确保刚才下载的插件被激活
# 这行命令会寻找 .zshrc 里以 plugins=( 开头的行，并替换为你需要的列表
sed -i 's/^plugins=(.*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' "$HOME/.zshrc"

# 确保 .zshrc 结尾引用了 p10k 配置
if ! grep -q "p10k.zsh" "$HOME/.zshrc"; then
    echo '[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh' >> "$HOME/.zshrc"
fi

# ==========================================
# 5. 收尾工作
# ==========================================
echo "⚙️ 将 Zsh 设置为默认 Shell..."
# 更改默认 shell，忽略可能出现的非严重警告
chsh -s "$(which zsh)" "$USER" || true

echo "==========================================="
echo "🎉 所有配置已全部完成！"
echo "👉 请输入命令 'exec zsh' 或者重新连接 SSH 即可体验新终端。"
echo "==========================================="