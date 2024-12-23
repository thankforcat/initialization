#!/bin/bash

# 提示用户输入项目名称
read -p "请输入你的项目名称: " project_name

# 创建项目目录并进入
mkdir "$project_name" && cd "$project_name"

# 初始化 Git 仓库
git init

# 创建 dev 分支
git checkout -b dev

# 创建 README.md 文件
echo "# $project_name" > README.md

# 创建 .gitignore 文件
cat > .gitignore <<EOF
node_modules/
.DS_Store
*.log
src/images/
.vscode
.gitignore
src/config/
images
*.db
.env
EOF

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

# 打开 VS Code
code .
