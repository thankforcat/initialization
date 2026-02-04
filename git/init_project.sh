#!/bin/bash

# bash <(curl -Ls https://raw.githubusercontent.com/thankforcat/initialization/refs/heads/main/git/init_project.sh)
# https://github.com/thankforcat/initialization

# 提示用户输入项目名称
read -p "请输入你的项目名称: " project_name

# 创建项目目录
mkdir "$project_name"
cd "$project_name"

# 初始化 Git 仓库并创建 main 分支
git init -b main


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
uploaded/
auth.json
token.txt
bot_config.json

# === 自定义规则（你可以自己加）===
debug_*.py
test_*.py
data/
tests/


" > .gitignore

# 创建基础文件和目录
mkdir logs utils images
touch main.py .env requirements.txt

# 添加文件到 Git 并提交
git add .
git commit -m "Initial commit"

# 创建 dev 分支
git checkout -b dev


# 提示用户是创建私人还是公开仓库
read -p "请选择仓库类型 (1: 私人 [默认], 2: 公开): " repo_type
repo_type=${repo_type:-1}

# 创建 GitHub 仓库（默认主分支为 main）
if [ "$repo_type" -eq 2 ]; then
    gh repo create "$project_name" --public --source=. --remote=origin --push --default-branch main
    echo "公开仓库已创建并推送 main 分支！"
else
    gh repo create "$project_name" --private --source=. --remote=origin --push --default-branch main
    echo "私人仓库已创建并推送 main 分支！"
fi

# 推送所有分支
git push -u origin --all

# 提示完成
echo "项目 $project_name 初始化完成，已推送 main 和 dev 分支到 GitHub！"

# 可选：打开 VS Code
# code .
