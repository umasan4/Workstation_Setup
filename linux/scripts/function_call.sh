#!/bin/bash

#-----------------------------------------------
# 外部ファイルの関数を呼び出す練習
#-----------------------------------------------

# 関数ファイルをrealpathとdirnameで呼び出す
# 相対パス、絶対パスで呼び出すよりも変更に耐性がある
file_path=$(realpath $0)
base_path=$(dirname $file_path)
func_file="${base_path}/function_def.sh"
source $func_file

# main
echo "#-------------------------"
echo "# function print_hello"
echo "#-------------------------"
print_hello

echo ""
echo "#-------------------------"
echo "# function argment_show"
echo "#-------------------------"
argment_show hoge1 hoge2

echo ""
echo "#-------------------------"
echo "# function argment_sum"
echo "#-------------------------"
argment_sum 1 2 3 4
echo ""