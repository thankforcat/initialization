#!/bin/bash
set -e

# ==========================================
# 1. 交互式设置 (时区 & Swap)
# ==========================================
echo "-------------------------------------------"
echo "🌐 请选择系统时区 (10秒内未选择将跳过):"
echo "1) 上海 (Asia/Shanghai) | 2) 洛杉矶 (America/Los_Angeles) | 3) 跳过"
read -t 10 -p "请输入选项 [1-3]: " tz_choice || tz_choice=3
case $tz_choice in
    1) timedatectl set-timezone Asia/Shanghai; echo "✅ 已设为上海时区";;
    2) timedatectl set-timezone America/Los_Angeles; echo "✅ 已设为洛杉矶时区";;
esac

echo "-------------------------------------------"
echo "💾 是否需要开启 1G Swap 虚拟内存? (默认不开启)"
read -t 10 -p "请输入 [y/N] (默认 n): " swap_choice || swap_choice="n"

if [[ "$swap_choice" =~ ^[Yy]$ ]]; then
    if [ ! -f /swapfile ]; then
        echo "⏳ 正在创建 1G Swap..."
        fallocate -l 1G /swapfile && chmod 600 /swapfile
        mkswap /swapfile && swapon /swapfile
        echo '/swapfile none swap sw 0 0' >> /etc/fstab
        echo "✅ Swap 1G 开启成功"
    else
        echo "ℹ️  Swap 已存在，跳过"
    fi
else
    echo "⏭️  根据选择或超时，跳过 Swap 设置"
fi

# ==========================================
# 2. 基础环境安装
# ==========================================
echo "📦 正在安装基础依赖..."
apt update && apt install -y zsh chrony wget nano cron git python3 python3-pip unzip ca-certificates
systemctl start chrony && systemctl enable chrony

# ==========================================
# 3. 安装 UV (Python 管理神器)
# ==========================================
echo "🐍 正在安装 UV 并配置 Alias..."
if ! command -v uv >/dev/null 2>&1; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
    # 立即让当前脚本环境识别 uv (uv 默认安装在 ~/.local/bin 或 ~/.cargo/bin)
    source $HOME/.cargo/env || true
    export PATH="$HOME/.cargo/bin:$PATH"
fi

# ==========================================
# 4. 创建目录结构
# ==========================================
mkdir -p ~/workspace/system/filebrowser ~/workspace/public ~/workspace/code \
         ~/workspace/docker/{emby,portainer/data,npm,tinyproxy}

# ==========================================
# 5. SSH 安全加固 (端口: 20124)
# ==========================================
echo "🔒 配置 SSH 端口 20124..."
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/^#\?Port.*/Port 20124/' /etc/ssh/sshd_config
sshd -t && (systemctl restart sshd || systemctl restart ssh) || echo "⚠️ SSH 重启失败，请检查配置"

# ==========================================
# 6. Zsh 美化与 Alias 注入
# ==========================================
echo "✨ 安装 Zsh 美化环境..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
[ -d "$ZSH_CUSTOM/themes/powerlevel10k" ] || git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
[ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ] || git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
[ -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ] || git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

# 覆盖配置文件
curl -fsSL -o "$HOME/.zshrc" "https://raw.githubusercontent.com/thankforcat/initialization/refs/heads/main/linux/.zshrc"
curl -fsSL -o "$HOME/.p10k.zsh" "https://raw.githubusercontent.com/thankforcat/initialization/refs/heads/main/linux/.p10k.zsh"

# 注入 Alias (包括你的 UV 需求)
{
    echo ""
    echo "# --- Custom Alias ---"
    echo "alias dps='docker ps --format \"table {{.Names}}\t{{.Status}}\t{{.Ports}}\"'"
    echo "alias pip=\"uv pip\""
    echo "alias pip3=\"uv pip\""
    echo "export PATH=\"\$HOME/.cargo/bin:\$PATH\""
} >> "$HOME/.zshrc"

# 强制激活插件
sed -i 's/^plugins=(.*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' "$HOME/.zshrc"

# 更改默认 Shell
chsh -s "$(which zsh)" "$USER" || true

echo "==========================================="
echo "🎉 VPS 初始化全部完成！"
echo "🐍 Python 管理器: UV 已就绪 (pip/pip3 已指向 uv pip)"
echo "📡 SSH 端口: 20124"
echo "👉 请执行 'exec zsh' 重新登录"
echo "==========================================="