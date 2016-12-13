#! /bin/bash

source hjdata_config.sh

function analyze_line() {
    local x=$1
    local y=$2

    local match_line=$3
    local modified=0
    local modified_info=

    local level_start=$(echo "$match_line" | egrep -o '^[6][02468]')
    local match=$(echo $match_line | egrep -o '(Lv|va)[. ]*[0-9]+$')
    local level=$(echo $match | egrep -o '[0-9]+')

    mkdir -p tmp/small/${x}
    mkdir -p tmp/bad/${x}

    if [ $level -gt 80 ]; then
        logger -s "bad value for $x,$y move"
        mv pic/${x}/${y}.bmp tmp/bad/${x}/
        [ $? -ne 0 ] && exit 1
    else
        div_start=0
        if [ -n "$level_start" ]; then
            div_start=6
        fi

        div=$(($level/10))
        rem=$(($level%10))
        if [ $rem -eq 3 ]; then
            rem=8
            modified=1
            modified_info="fix rem from 3 to 8"
        elif [ $rem -eq 5 ]; then
            rem=6
            modified=1
            modified_info="fix rem from 5 to 6"
        fi

        if [ $div_start -eq 6 -a $div -eq 5 ]; then
            div=6
            modified=2
            modified_info="fixed from $level to $level_start"
        fi

        if [ $modified -ne 0 ]; then
            level=$(($div*10+$rem))
        fi

        logger -s "$xystr $modified_info"
        if [ $level -ge $min_lv ]; then
            echo "$x,$y,$level," >> $output
        fi

        if [ $level -lt 30 ]; then
            echo "move to small"
            mv pic/${x}/${y}.bmp tmp/small/${x}/
            [ $? -ne 0 ] && exit 1
        fi
    fi
}

function generate_report() {
    local lang=$1
    local path=$2
    local x=$3
    local y=$(basename $path | awk -F. '{ print $1 }')

    local feedback=feedback.${lang}
    local xystr=$(printf "%-16s" "($x,$y)")

    outbase=result/tmp/${x}/${y}.${lang}
    cmd=
    pattern=
    if [ $lang == "eng" ]; then
        cmd="tesseract $path $outbase eng.config"
        pattern='(Lv|va)[. ]*[0-9]+$'
    elif [ $lang == "chi" ]; then
        cmd="tesseract -l chi $path $outbase"
        pattern='[硅宝铁铜桐洞油锔铢圭筐失]{1}'
    elif [ $lang == "chi" ]; then
        cmd="tesseract -l chi_sim $path $outbase"
        pattern='[0-9]+级[油铁硅铜宝]'
    fi

    mkdir -p tmp/nomatch/${x}
    mkdir -p $(dirname $outbase)
    if [ ! -f ${outbase}.txt ]; then
        $cmd 2>/dev/null
    fi

    local match_line=$(egrep "$pattern" $outbase.txt | sed -n '1p')
    if [ "${match_line}"x == "x" ]; then
        logger -s "$xystr not match - $cmd"
        echo "$x,$y," >> ${feedback}

        mv pic/${x}/${y}.bmp tmp/nomatch/${x}/
        [ $? -ne 0 ] && exit 1
    else
        xystr=$(printf "$xystr %-16s" "match:[${match_line}]")
        logger -s "$xystr"

        if [ $lang == "eng" ]; then
            analyze_line $x $y "${match_line}"
        fi
    fi
}

function scan() {
    local lang=$1
    logger -s "Last coordinate: ($xstart,$ystart) to ($xmax,$ymax)"

    for x in $(seq ${xstart} ${xmax})
    do
        for y in $(seq ${ystart} ${ymax})
        do
            fullpath="pic/$x/$y.bmp"
            [ ! -f $fullpath ] && continue
            generate_report ${lang} ${fullpath} ${x}
            sety ${y}
        done

        setx ${x}
    done
}

if [ -z "$1" ]; then
    echo "Usage: $0 <eng|chi|chi_sim>"
    exit 1
fi

scan $1
sort -u -V feedback.$1
