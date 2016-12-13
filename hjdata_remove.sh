#! /bin/bash

x=$1
y=$2
[ -z "$1" ] && echo "Usage: $0 x [y]" && exit 1

if [ -n "$y" ]; then
    # TODO: remove line from csv
    resultfile=result/${x}/result.csv

    echo remove "$x,$y" from $resultfile
    echo remove pic/$x/${y}.bmp result/tmp/$x/${y}_*.txt
    sed -i "/^$x,$y,/d" $resultfile
    rm -f pic/$x/${x}_${y}.bmp result/tmp/$x/${y}_*.txt
fi
