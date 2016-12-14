#! /bin/bash

xstart=599
ystart=599

export xstart
export ystart
export xmax=599
export ymax=599
export min_lv=58

export pattern_eng='(Lv|va)[. ]*[0-9]+$'
export pattern_chi='[0-9]+级[油铁硅铜宝]'
export pattern_chi_sim='级[硅宝铁铜桐洞油锔铢圭筐失]{1}'

function setx() {
    sed -i "s/^xstart.*/xstart=$1/" hjdata_config.sh
}

function sety() {
    sed -i "s/^ystart.*/ystart=$1/" hjdata_config.sh
}
