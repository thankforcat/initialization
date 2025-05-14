#!/bin/bash

# bash <(curl -Ls https://raw.githubusercontent.com/thankforcat/initialization/refs/heads/main/git/init_project.sh)
# https://github.com/thankforcat/initialization
# 提示用户输入项目名称
read -p "请输入你的项目名称: " project_name

# 创建项目目录
mkdir "$project_name" 

cd "$project_name"

# 初始化 Git 仓库
git init

# 创建 dev 分支
git checkout -b dev



# 创建 README.md 文件
echo "# $project_name" > README.md

# 创建 .gitignore 文件
echo "
# === Python 编译产物 ===
__pycache__/
*.py[cod]
*.pyo
*.pyd
*.pyc

# === 虚拟环境 ===
venv/
env/
.venv/
.ENV/
.Python
pip-wheel-metadata/

# === Jupyter Notebook 检查点 ===
.ipynb_checkpoints/

# === 配置/密钥/数据库等本地文件 ===
*.sqlite3
*.db
*.log
*.pid
*.env
.env.*
secrets.*
credentials.*
config.yaml
*.bak

# === 本地缓存/临时文件夹 ===
.cache/
*.swp
*.tmp
*.temp
.DS_Store
Thumbs.db

# === 运行输出、截图、媒体 ===
output/
logs/
screenshots/
*.png
*.jpg
*.jpeg
*.gif
*.mp4
*.webm
*.zip
*.tar.gz

# === VSCode / PyCharm / 编辑器文件 ===
.vscode/
.idea/
*.sublime-workspace
*.sublime-project

# === macOS / Windows 系统文件 ===
.DS_Store
ehthumbs.db
Icon?

# === Node/npm 支持（如果项目混合） ===
node_modules/
package-lock.json

# === Telegram Bot 特定项目建议 ===
# 上传缓存、Token 或认证文件（你可按需删改）
uploaded/
auth.json
token.txt
bot_config.json

# === 自定义规则（你可以自己加） ===
# 忽略你临时写的调试脚本
debug_*.py
test_*.py

# 忽略你使用过的某些数据文件夹
data/

" > .gitignore

# 添加文件到 Git 并提交
git add .
git commit -m "Initial commit"

# 提示用户是创建私人还是公开仓库
read -p "请选择仓库类型 (1: 私人 [默认], 2: 公开): " repo_type

# 设置默认值为 1
repo_type=${repo_type:-1}

# 创建 GitHub 仓库并推送代码
if [ "$repo_type" -eq 2 ]; then
    gh repo create "$project_name" --public --source=. --remote=origin --push
    echo "公开仓库已创建并推送！"
else
    gh repo create "$project_name" --private --source=. --remote=origin --push
    echo "私人仓库已创建并推送！"
fi

# 提示完成
echo "项目 $project_name 已创建，包含 README.md 和 .gitignore 文件，并已推送到 GitHub！"

cd "$project_name"


# 打开 VS Code
# code .
