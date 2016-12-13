#! /bin/bash



function justrename() {
    local path=$1
    local name=$(basename $path | awk -F. '{ print $1 }')
    local suff=$(basename $path | awk -F. '{ print $2 }')
    local dirn=$(dirname $path)

    x=$(echo $name | awk -F_ '{ print $1 }')
    y=$(echo $name | awk -F_ '{ print $2 }')

    [ -z "${x}" ] && return
    [ -z "${y}" ] && return

    echo mv ${dirn}/${x}_${y}.bmp ${dirn}/${y}.bmp
         mv ${dirn}/${x}_${y}.bmp ${dirn}/${y}.bmp
}

for i in $(find pic -type f -name "*.bmp")
do
    justrename $i
done
