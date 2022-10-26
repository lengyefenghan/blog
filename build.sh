#/bin/sh

echo '|: 清理旧项目'
rm public -rf
rm docs -rf

#echo '|: 同步子模块'
#git submodule update --init --recursive
#echo '|: 更新子模块'
#git submodule update --rebase --remote


echo '|: 重新生成'
hugo --minify

echo '|: 整理生成'
mv public docs

echo '|: 脚本运行完成'