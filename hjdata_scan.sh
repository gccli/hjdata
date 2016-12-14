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
        echo ${cmd_chi}
    fi

    local match_line_eng=$(egrep "${pattern_eng}" ${outb_eng}.txt | sed -n '1p')
    local match_line_chi=$(egrep "${pattern_chi}" ${outb_chi}.txt | sed -n '1p')

    if [ "${match_line_eng}"x == "x" -o "${match_line_chi}"x == "x" ]; then
        logger -s "$xystr not match - ${outb_eng} ${outb_chi}"
        echo "$x,$y,notmatch" >> ${feedback}
        #mv pic/${x}/${y}.bmp tmp/nomatch/${x}/
        #[ $? -ne 0 ] && exit 1
        return
    fi


    local modified=0
    local modified_info=

    local match=$(echo ${match_line_eng} | egrep -o "${pattern_eng}")      # only for Lv.##
    local level_start=$(echo "${match_line_eng}" | egrep -o '^[6][02468]') # start number
    local level=$(echo $match | egrep -o "${pattern_level}")

    local match_chi=$(echo ${match_line_chi} | egrep -o "${pattern_chi}")
    local match_lv=$(echo ${match_line_chi} | egrep -o "${pattern_lv}")
    local label=$(echo ${match_chi} | egrep -o "${pattern_label}")
    local level_chi=$(echo ${match_chi} | egrep -o "${pattern_level}")
    local level_lv=$(echo ${match_chi} | egrep -o "${pattern_level}")

    xystr=$(printf "$xystr %-16s %-12s" "match:[$match]" "level:[$level]")

    echo "eng: line:[${match_line_eng}] match:[$match]"
    echo "chi: line:[${match_line_chi}] label:[$label] level:[$level_chi] lv:[$level_lv]"

    if [ $level -gt 80 ]; then
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
