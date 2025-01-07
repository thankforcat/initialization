#!/bin/bash

# 定义配置文件的URL
ZSHRC_URL="https://raw.githubusercontent.com/thankforcat/initialization/refs/heads/main/linux/.zshrc"
P10K_URL="https://raw.githubusercontent.com/thankforcat/initialization/refs/heads/main/linux/.p10k.zsh"

# 定义目标路径
ZSHRC_PATH="$HOME/.zshrc"
P10K_PATH="$HOME/.p10k.zsh"

echo "开始设置 Zsh、Powerlevel10k 和 Zsh 插件配置..."

# 下载 .zshrc 文件
echo "下载 .zshrc 配置文件..."
curl -fsSL -o "$ZSHRC_PATH" "$ZSHRC_URL"
if [ $? -eq 0 ]; then
    echo ".zshrc 文件下载成功！"
else
    echo "下载 .zshrc 文件失败，请检查 URL 或网络连接。" >&2
    exit 1
fi

# 下载 .p10k.zsh 文件
echo "下载 .p10k.zsh 配置文件..."
curl -fsSL -o "$P10K_PATH" "$P10K_URL"
if [ $? -eq 0 ]; then
    echo ".p10k.zsh 文件下载成功！"
else
    echo "下载 .p10k.zsh 文件失败，请检查 URL 或网络连接。" >&2
    exit 1
fi

# 检查是否安装 Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "安装 Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    if [ $? -eq 0 ]; then
        echo "Oh My Zsh 安装成功！"
    else
        echo "Oh My Zsh 安装失败，请检查网络连接。" >&2
        exit 1
    fi
else
    echo "Oh My Zsh 已安装，跳过安装步骤。"
fi

# 安装 Powerlevel10k
echo "安装 Powerlevel10k..."
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
if [ $? -eq 0 ]; then
    echo "Powerlevel10k 安装成功！"
else
    echo "Powerlevel10k 安装失败，请检查网络连接或 Git 仓库状态。" >&2
    exit 1
fi

# 设置 Powerlevel10k 主题
echo "配置 Powerlevel10k 主题..."
sed -i '/^ZSH_THEME=/c\ZSH_THEME="powerlevel10k/powerlevel10k"' "$ZSHRC_PATH"

# 安装 zsh-autosuggestions 插件
echo "安装 zsh-autosuggestions 插件..."
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
if [ $? -eq 0 ]; then
    echo "zsh-autosuggestions 插件安装成功！"
else
    echo "zsh-autosuggestions 插件安装失败，请检查网络连接。" >&2
    exit 1
fi

# 添加 zsh-autosuggestions 到插件列表
echo "配置 zsh-autosuggestions 插件..."
sed -i '/^plugins=(/s/)$/ zsh-autosuggestions)/' "$ZSHRC_PATH"

# 确保 .zshrc 中引用了 .p10k.zsh
if ! grep -q "source ~/.p10k.zsh" "$ZSHRC_PATH"; then
    echo '[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh' >> "$ZSHRC_PATH"
    echo "已将 .p10k.zsh 文件引用添加到 .zshrc。"
fi

# 重启 Zsh 以应用新配置
echo "重新加载 Zsh..."
exec zsh
