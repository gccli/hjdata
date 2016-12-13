#! /bin/bash

source hjdata_config.sh

function generate_report() {
    local lang=$1
    local path=$2
    local x=$3
    local y=$(basename $path | awk -F. '{ print $1 }')

    local feedback=feedback.${lang}
    local xystr=$(printf "%-16s" "($x,$y)")

    outbase=result/${x}/tmp/${y}.${lang}
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

    mkdir -p $(dirname $outbase)
    if [ ! -f ${outbase}.txt ]; then
        $cmd 2>/dev/null
    fi

    local match_line=$(egrep "$pattern" $outbase.txt | sed -n '1p')
    if [ "${match_line}"x == "x" ]; then
        logger -s "$xystr not match - tesseract $path stdout myconfig"
        echo "$x,$y," >> ${feedback}
    else
        xystr=$(printf "$xystr %-16s" "match:[${match_line}]")
        logger -s "$xystr"
    fi
}

function scan() {
    local lang=$1
    logger -s "Last coordinate: ($xstart,$ystart) to ($xmax,$ymax)"

    for x in $(seq $xstart $xmax)
    do
        for y in $(seq $ystart $ymax)
        do
            fullpath="pic/$x/$y.bmp"
            [ ! -f $fullpath ] && continue
            generate_report ${lang} ${fullpath} ${x}
            sety ${y}
        done

        setx ${x}
    done
}

scan eng
sort -u -V feedback.eng

scan chi
sort -u -V feedback.chi
