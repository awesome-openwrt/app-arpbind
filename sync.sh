#!/usr/bin/env bash

# if error occured, then exit
set -e

# path
project_root_path=`pwd`
tmp_path="$project_root_path/.tmp"

if [ ! -d $tmp_path ]; then
    mkdir -p $tmp_path
fi

# git 同步 lean 源码
if [ ! -d $tmp_path/lean ]; then
    mkdir -p $tmp_path/lean
    cd $tmp_path/lean
    git init
    git remote add origin https://github.com/coolsnowwolf/lede.git
    git config core.sparsecheckout true
fi
cd $tmp_path/lean
if [ ! -e .git/info/sparse-checkout ]; then
    touch .git/info/sparse-checkout
fi
if [ `grep -c "package/lean/luci-app-arpbind" .git/info/sparse-checkout` -eq 0 ]; then
    echo "package/lean/luci-app-arpbind" >> .git/info/sparse-checkout
fi
git pull --depth 1 origin master

############################################################################################

# luci-app-arpbind 同步更新
if [ -d $project_root_path/luci-app-arpbind ]; then
    rm -rf $project_root_path/luci-app-arpbind
fi
cp -R $tmp_path/lean/package/lean/ $project_root_path/

# 提交
# cd $tmp_path/lean
# latest_commit_id=`git rev-parse HEAD`
# latest_commit_msg=`git log --pretty=format:"%s" $current_git_branch_latest_id -1`
# echo $latest_commit_id
# echo $latest_commit_msg

cd $project_root_path
cur_time=$(date "+%Y%m%d-%H%M%S")
git add -A && git commit -m "$cur_time" && git push origin master
