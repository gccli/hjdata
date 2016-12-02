#! /bin/bash

PATH=$PATH:$HOME/local/bin

csv_input=$1

if [ "$csv_input"x == "x" ]; then
    echo "Usage: $0 csv"
    exit 0
fi

line_cnt=-1
while read line
do
    line_cnt=$(($line_cnt+1))
    if [ $line_cnt -eq 0 ]; then
        continue
    fi

    x=$(echo $line | awk -F, '{ print $1 }')
    y=$(echo $line | awk -F, '{ print $2 }')

    file="pic/$x/$x"_"$y.bmp"
    name=$(basename $file | awk -F. '{ print $1 }')_chi

    echo "tesseract -lchi_sim $file /tmp/$name 2>/dev/null"
    tesseract -l chi_sim $file stdout

    sleep 1
done < $csv_input
