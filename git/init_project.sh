#!/bin/bash

# 提示用户输入项目名称
read -p "请输入你的项目名称: " project_name

# 创建项目目录
mkdir "$project_name" && cd "$project_name"

# 打开 VS Code
code .

# 创建 README.md 文件
echo "# $project_name" > README.md

# 创建 .gitignore 文件
echo "node_modules/
.DS_Store
*.log
src/images/
.vscode
.gitignore
src/config/
images
*.db
.env" > .gitignore

echo "项目 $project_name 已创建，包含 README.md 和 .gitignore 文件，并已打开 VS Code！"
