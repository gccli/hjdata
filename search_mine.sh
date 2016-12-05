#! /bin/bash

PATH=$PATH:$HOME/local/bin
min_lv=58
outdir=result

last_x=1
last_y=1

function cleanup() {
    find $outdir -name "*.csv" | xargs rm -f
    rm -f .x .y
    rm -f $outdir/tmp/*.txt
}

function load_xy() {
    [ -f .x ] && last_x=$(cat .x)
    [ -f .y ] && last_y=$(cat .y)

    logger -s "Last coordinate: ($last_x,$last_y)"
}

function save_xy() {
    echo -n $1 > .x
    echo -n $2 > .y
}

function process_pic() {
    local file=$1
    local output=$2
    local name=$(basename $file | awk -F. '{ print $1 }')
    local x=$(echo $name | awk -F_ '{ print $1 }')
    local y=$(echo $name | awk -F_ '{ print $2 }')

    local xystr=$(printf "%-16s" "($x,$y)")
    if [ ! -f $output ] ;then
        echo "x,y,level,type" > $output
    fi

    if [ ! -f $outdir/tmp/$name.txt ]; then
        tesseract $file $outdir/tmp/$name myconfig 2>/dev/null
        sleep 0.05
    fi

    local match_line=$(egrep '(Lv|va)[. ]*[0-9]+$' $outdir/tmp/$name.txt | sed -n '1p')
    local match=$(egrep -o '(Lv|va)[. ]*[0-9]+$' $outdir/tmp/$name.txt | sed -n '1p')
    if [ "$match"x == "x" ]; then
        logger -s "$xystr not match - tesseract $file stdout myconfig"
    else
        modified=0
        modified_info=

        level_start=$(echo $match_line | egrep -o '^[6][02468]')
        level=$(echo $match | egrep -o '[0-9]+')
        xystr=$(printf "$xystr %-16s %-12s" "match:[$match]" "level:[$level]")

        #echo
        #echo "match:    [$match_line]"
        #echo "level:    [$level_start] [$level]"
        #echo

        if [ $level -gt 80 ]; then
            logger -s "$xystr - bad value"
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
        fi
    fi

    save_xy $x $y
}

if [ "$1"x == "cleanupx" ]; then
    echo do cleanup
    cleanup
    exit 0
fi
mkdir -p $outdir/tmp

load_xy
for x in $(seq $last_x 599)
do
    ix=$((x/10))
    output=$outdir/"$((10*$ix))-$(($ix*10+9))".csv
    logger -s "X=$x result output to $output"
    for y in $(seq $last_y 599)
    do
        name="pic/$x/$x"_"$y.bmp"
        [ ! -f $name ] && continue
        process_pic $name $output
    done
    # reset y
    last_y=1
done
