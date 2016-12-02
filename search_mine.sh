#! /bin/bash

PATH=$PATH:$HOME/local/bin
min_lv=58
outdir=result

last_x=1
last_y=1

function cleanup() {
    find $outdir -name "*.csv" | xargs rm -f
    rm -f .x .y
    rm -f /tmp/*.txt
}

function load_xy() {
    [ -f .x ] && last_x=$(cat .x)
    [ -f .y ] && last_y=$(cat .y)

    echo last coordinate: "($last_x,$last_y)"
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

    printf "%-16s" "($x,$y)"
    if [ ! -f $output ] ;then
        echo "x,y,level,type" > $output
    fi

    tesseract $file /tmp/$name myconfig 2>/dev/null
    sleep 0.1

    local match=$(egrep -o '(Lv|va)[. ]*[0-9]+$' /tmp/$name.txt)
    if [ "$match"x == "x" ]; then
        echo -e "\033[31mnot match\033[0m tesseract $file $/tmp/$name.txt myconfig"
    else
        modified=
        level=$(echo $match | egrep -o '[0-9]+')

        if [ $level -gt 80 ]; then
            echo "$match  $level            bad value"
        else
            div=$(($level/10))
            rem=$(($level%10))
            if [ $rem -eq 3 ]; then
                rem=8
                modified="fixed"
            elif [ $rem -eq 5 ]; then
                rem=6
                modified="fixed"
            fi
            if [ $modified"x" != "x" ]; then
                level=$(($div*10+$rem))
            fi

            echo "$match  $level            $modified"
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

load_xy
for x in $(seq $last_x 599)
do
    ix=$((x/10))
    output=result/"$((10*$ix))-$(($ix*10+9))".csv
    echo "x:$x result file is $output"
    for y in $(seq $last_y 599)
    do
        name="pic/$x/$x"_"$y.bmp"
        [ ! -f $name ] && continue
        process_pic $name $output
    done
    # reset y
    last_y=1
done
