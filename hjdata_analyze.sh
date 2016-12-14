#! /bin/bash

source hjdata_config.sh

function identify_label_level() {
    local path=$1
    local x=$2
    local y=$3


    local path_chi=$(echo $path | sed 's/eng/chi/')
    local xystr=$(printf "%-16s" "($x,$y)")

    local match_line=$(egrep "$pattern_eng" ${path} | sed -n '1p')
    local match_line_chi=$(egrep "$pattern_chi" ${path_chi} | sed -n '1p')

    echo "ssssssss"
    if [ "${match_line}"x == "x" ]; then
        logger -s "$xystr not match eng"
    else
        xystr=$(printf "$xystr %-16s  $-16s" "[${match_line}]" "[${match_line_chi}]")
        logger -s "$xystr"

        if [ $lang == "eng" ]; then
            analyze_line $x $y "${match_line}"
        fi
    fi
}

function analyze() {
    logger -s "Last coordinate: ($xstart,$ystart) to ($xmax,$ymax)"

    for x in $(seq ${xstart} ${xmax})
    do
        for y in $(seq ${ystart} ${ymax})
        do
            fullpath="result/tmp/$x/${y}_eng.txt"
            [ ! -f $fullpath ] && continue
            identify_label_level ${fullpath} ${x} ${y}
            sety ${y}
        done

        setx ${x}
    done
}

touch analyze_feedback
analyze
sort -u -V analyze_feedback
