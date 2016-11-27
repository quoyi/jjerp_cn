#!/bin/bash
echo "图片大小转换";
for i in `find . -size +100k`;
do
  convert +profile '*' $i -quality 75 -resize 1024x768! $i;
  echo "图片 $i 转换成功！";
done

# 执行此脚本前，需要使用 chmod +x resize.sh 赋予运行权限，然后使用 ./resize.sh 运行。
# 此脚本用于缩小当前目录下，所有大于100k的图片。去掉图片非必要信息，以75%的质量、1024x768尺寸缩小。
