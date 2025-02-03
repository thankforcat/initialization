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
echo "*.log
*.db

logs/
keys/

# See https://help.github.com/articles/ignoring-files/ for more about ignoring files.

# dependencies
/node_modules
/.pnp
.pnp.*
.yarn/*
!.yarn/patches
!.yarn/plugins
!.yarn/releases
!.yarn/versions

# testing
/coverage

# next.js
/.next/
/out/

# production
/build

# misc
.DS_Store
*.pem

# debug
npm-debug.log*
yarn-debug.log*
yarn-error.log*
.pnpm-debug.log*

# env files (can opt-in for committing if needed)
.env*

# vercel
.vercel

# typescript
*.tsbuildinfo
next-env.d.ts
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
