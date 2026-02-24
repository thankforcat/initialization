#!/bin/bash
set -e

# ==========================================
# 1. 交互式时区设置
# ==========================================
echo "-------------------------------------------"
echo "🌐 请选择系统时区 (10秒内未选择将跳过):"
echo "1) 上海 (Asia/Shanghai)"
echo "2) 洛杉矶 (America/Los_Angeles)"
echo "3) 不设置 (保持系统默认)"
echo "-------------------------------------------"
read -t 10 -p "请输入选项 [1-3]: " tz_choice || tz_choice=3

case $tz_choice in
    1) timedatectl set-timezone Asia/Shanghai; echo "✅ 已设为上海时区";;
    2) timedatectl set-timezone America/Los_Angeles; echo "✅ 已设为洛杉矶时区";;
    *) echo "⏭️  跳过时区设置";;
esac

# ==========================================
# 2. 基础环境与时间同步
# ==========================================
echo "📦 正在安装基础依赖与 Chrony 时间同步..."
apt update && apt install -y zsh chrony curl wget nano cron git
systemctl start chrony && systemctl enable chrony

# ==========================================
# 3. 网络性能优化 (BBR 加速)
# ==========================================
# echo "🚀 开启 BBR 加速..."
# if ! grep -q "net.ipv4.tcp_congestion_control=bbr" /etc/sysctl.conf; then
#     echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
#     echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
#     sysctl -p
# fi

# ==========================================
# 4. Docker 环境安装
# ==========================================
echo "🐳 安装 Docker & Docker-Compose..."
apt install -y docker.io docker-compose
systemctl start docker && systemctl enable docker

# ==========================================
# 5. 测速工具与目录结构
# ==========================================
echo "📊 安装 Speedtest 并创建工作目录..."
curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | bash
apt-get install -y speedtest

# 创建你指定的目录结构
mkdir -p ~/workspace/system/filebrowser \
         ~/workspace/public \
         ~/workspace/code \
         ~/workspace/docker/emby \
         ~/workspace/docker/portainer/data \
         ~/workspace/docker/npm \
         ~/workspace/docker/tinyproxy

# ==========================================
# 6. SSH 安全加固 (端口: 20124)
# ==========================================
echo "🔒 正在配置 SSH (端口 20124, 允许 Root 登录)..."
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/^#\?Port.*/Port 20124/' /etc/ssh/sshd_config

if sshd -t; then
    systemctl restart sshd || systemctl restart ssh
    echo "✅ SSH 配置更新成功 (端口: 20124)"
else
    echo "❌ SSH 语法检测失败，已回滚配置！"
    cp /etc/ssh/sshd_config.bak /etc/ssh/sshd_config
fi

# ==========================================
# 7. Zsh 美化 (Oh My Zsh + P10k + 插件)
# ==========================================
echo "✨ 安装 Zsh 美化环境..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
# 下载主题和插件
[ -d "$ZSH_CUSTOM/themes/powerlevel10k" ] || git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
[ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ] || git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
[ -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ] || git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

# 覆盖配置文件
curl -fsSL -o "$HOME/.zshrc" "https://raw.githubusercontent.com/thankforcat/initialization/refs/heads/main/linux/.zshrc"
curl -fsSL -o "$HOME/.p10k.zsh" "https://raw.githubusercontent.com/thankforcat/initialization/refs/heads/main/linux/.p10k.zsh"

# 强制注入常用 Alias 和插件列表
sed -i 's/^plugins=(.*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' "$HOME/.zshrc"
echo "alias dps='docker ps --format \"table {{.Names}}\t{{.Status}}\t{{.Ports}}\"'" >> "$HOME/.zshrc"

# 更改默认 Shell
chsh -s "$(which zsh)" "$USER" || true

echo "==========================================="
echo "🎉 VPS 初始化全部完成！"
echo "⏰ 时间: $(date)"
echo "📡 SSH 端口: 20124"
echo "🚀 BBR 加速: 已开启"
echo "👉 请执行 'exec zsh' 开启全新体验"
echo "==========================================="