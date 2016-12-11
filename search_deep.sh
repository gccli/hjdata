#! /bin/bash

outdir=result
csv_input=$1

if [ "$csv_input"x == "x" ]; then
    echo "Usage: $0 csv"
    exit 0
fi

function process_csv() {
    local csv_input=$1
    local line_num=0
    local csv_output=/tmp/$(basename ${csv_input}).tmp
    local nomatch=/tmp/nomatch
    echo
    echo "-------- output to file $csv_output --------"
    rm -f $csv_output
    rm -f $nomatch
    while read line
    do
        [ -z "$line" ] && echo "empty line" && continue
        x=$(echo $line | awk -F, '{ print $1 }')
        y=$(echo $line | awk -F, '{ print $2 }')
        l=$(echo $line | awk -F, '{ print $3 }')
        [ "$x" == "x" ] && continue
        echo -n $line

        xy="$x,$y"
        userline=$(egrep "^$xy," userdata.csv)
        if [ -n "$userline" ]; then
            echo "userdata - $userline"
            echo $userline >> $csv_output
            continue
        fi

        file="pic/$x/$x"_"$y.bmp"
        name=$(basename $file | awk -F. '{ print $1 }')_chi
        result=$outdir/tmp/$x/$name

        cmd="tesseract -l chi_sim $file $result"
        if [ ! -f $result.txt ]; then
            $cmd 2>/dev/null
        fi

        pattern='[硅宝铁铜桐洞油锔铢圭筐失]{1}'
        label=$(egrep -o "$pattern" $result.txt | sed -n '1p')
        if [ -z "$label" ]; then
            logger -s "$line - not match: $cmd"
            echo "$xy," >> $nomatch
            continue
        fi
        echo $label

        [ $label == "圭" ] && label='硅'
        [ $label == "筐" ] && label='硅'
        [ $label == "失" ] && label='铁'
        [ $label == "铢" ] && label='铁'
        [ $label == "锔" ] && label='铜'
        [ $label == "桐" ] && label='铜'
        [ $label == "洞" ] && label='铜'
        echo "${x},${y},${l},${label}" >>  $csv_output
    done < $csv_input

    echo
    echo "-------- done process file $csv_output --------"
    sed -i '1ix,y,level,type' $csv_output

    [ -f  $csv_output ] && mv $csv_output $csv_input && git diff $csv_input
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
