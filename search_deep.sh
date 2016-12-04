#! /bin/bash

PATH=$PATH:$HOME/local/bin
outdir=result
csv_input=$1

if [ "$csv_input"x == "x" ]; then
    echo "Usage: $0 csv"
    exit 0
fi


function process_csv() {
    local csv_input=$1
    local line_num=0
    while read line
    do
        line_num=$(($line_num+1))
        if [ $line_num -eq 1 ]; then
            echo $line
            continue
        fi

        echo -n $line

        x=$(echo $line | awk -F, '{ print $1 }')
        y=$(echo $line | awk -F, '{ print $2 }')
        l=$(echo $line | awk -F, '{ print $3 }')

        file="pic/$x/$x"_"$y.bmp"
        name=$(basename $file | awk -F. '{ print $1 }')_chi

        result=$outdir/chi/$name

        cmd="tesseract -l chi_sim $file $result chicfg"
        if [ ! -f $result.txt ]; then
            $cmd 2>/dev/null
        fi

        pattern='[硅宝铁铜桐油锔铢圭筐失]{1}'
        label=$(egrep -o "$pattern" $result.txt | sed -n '1p')
        if [ -z "$label" ]; then
            logger -s "$line - not match: $cmd"
            continue
        fi
        echo $label

        [ $label == "圭" ] && label='硅'
        [ $label == "筐" ] && label='硅'
        [ $label == "失" ] && label='铁'
        [ $label == "铢" ] && label='铁'
        [ $label == "锔" ] && label='铜'
        [ $label == "桐" ] && label='铜'

        sed -i "${line_num}d" $csv_input
        sed -i "${line_num}i${x},${y},${l},${label}" $csv_input
    done < $csv_input
}


mkdir -p $outdir/chi
if [ "$csv_input" == "all" ]; then
    for f in $(ls result/*.csv)
    do
        process_csv $f
    done
else
    process_csv $csv_input
fi
