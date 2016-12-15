#! /bin/bash

source hjdata_config.sh

feedback=feedback.txt
touch ${feedback}

function generate_eng() {
    local x=$1
    local y=$2
    local path=$3
    local xystr=$(printf "%-16s" "($x,$y)")

    outb_eng=result/tmp/${x}/${y}.eng
    outb_chi=result/tmp/${x}/${y}.chi
    cmd_eng="tesseract $path $outb_eng eng.config"
    cmd_chi="tesseract -l chi $path $outb_chi"

    mkdir -p tmp/{nomatch,small,bad}/${x}
    mkdir -p $(dirname ${outb_eng})

    if [ ! -f ${outb_eng}.txt ]; then
        ${cmd_eng} 2>/dev/null
    fi
    if [ ! -f ${outb_chi}.txt ]; then
        ${cmd_chi} 2>/dev/null
    fi

    local match_line_eng=$(egrep "${pattern_eng}" ${outb_eng}.txt | sed -n '1p')
    local match_line_chi=$(egrep "${pattern_chi}" ${outb_chi}.txt | sed -n '1p')

    if [ "${match_line_chi}"x == "x" ]; then
        logger -s "$xystr not match - ${cmd_chi}"
        echo "$x,$y,notmatch" >> ${feedback}
        mv pic/${x}/${y}.bmp tmp/nomatch/${x}/
        [ $? -ne 0 ] && exit 1
        return
    fi

    local level=0
    local label=""
    local modified_flag=0
    local modified_info=""

    local match_eng=$(echo ${match_line_eng} | egrep -o "${pattern_eng}")  # only for Lv.##
    local level_eng=$(echo ${match_eng} | egrep -o "${pattern_level}")





    local match_chi=$(echo ${match_line_chi} | egrep -o "${pattern_chi}")
    local level_chi=$(echo ${match_chi} | egrep -o "${pattern_level}")

    label=$(echo ${match_chi} | egrep -o "${pattern_label}")
    local lv_match=$(echo ${match_line_chi} | egrep -o "${pattern_lv}")
    local lv_level=$(echo ${match_chi} | egrep -o "${pattern_level}")

    xystr=$(printf "$xystr %-16s %-12s" "match:[$match]" "level:[$level_eng/$level_chi]")

    echo "  eng: line:[${match_line_eng}] match:[$match_eng] level:[$level_eng]"
    echo "  chi: line:[${match_line_chi}] label:[$label] level:[$level_chi] lv:[$level_lv]"

    if [ ${level_eng} -gt 80 ]; then
        echo "$x,$y,badvalue" >> ${feedback}
        logger -s "$xystr bad value, move it"
        mv pic/${x}/${y}.bmp tmp/bad/${x}/
        [ $? -ne 0 ] && exit 1
        return
    fi

    div_start=0
    if [ -n "$level_start" ]; then
        div_start=6
    fi

    div=$((${level_eng}/10))
    rem=$((${level_eng}%10))
    if [ $rem -eq 3 ]; then
        rem=8
        modified_flag=1
        modified_info="fix rem from 3 to 8"
    elif [ $rem -eq 5 ]; then
        rem=6
        modified_flag=1
        modified_info="fix rem from 5 to 6"
    fi

    if [ $div_start -eq 6 -a $div -eq 5 ]; then
        div=6
        modified_flag=2
        modified_info="fixed from ${level_eng} to ${level_start}"
    fi

    if [ $modified_flag -ne 0 ]; then
        level_eng=$(($div*10+$rem))
    fi

    logger -s "$xystr $modified_info"
    if [ $level -le $low_lv ]; then
        echo "remove to small"
        mv pic/${x}/${y}.bmp tmp/small/${x}/
        [ $? -ne 0 ] && exit 1
    fi
}

function scan() {
    logger -s "Last coordinate: ($xstart,$ystart) to ($xmax,$ymax)"

    for x in $(seq ${xstart} ${xmax})
    do
        for y in $(seq ${ystart} ${ymax})
        do
            fullpath="pic/$x/$y.bmp"
            [ ! -f $fullpath ] && continue
            generate_eng ${x} ${y} ${fullpath}
            sety ${y}
        done

        setx ${x}
    done
}

if [ -n "$1" ]; then
    if [ "$1" == "reset" ]; then
        echo "reset x,y"
        setx 0
        sety 0
    else
        echo "set x=$1"
        setx $1
        if [ -n "$2" ]; then
            setx $2
        fi
    fi

    source hjdata_config.sh
fi

scan
