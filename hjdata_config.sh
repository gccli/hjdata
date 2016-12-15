#! /bin/bash

xstart=0
ystart=294

export xstart
export ystart
export xmax=599
export ymax=599
export min_lv=58
export low_lv=30

export pattern_eng='(Lv|va)[. ]*[0-9]+$'
export pattern_chi='[0-9]+级[油铁硅铜宝]'
export pattern_label='[油铁硅铜宝]'
export pattern_level='[0-9]+'
export pattern_lv='Lv[. ]*[0-9]+$'

function setx() {
    sed -i "s/^xstart.*/xstart=$1/" hjdata_config.sh
}

function sety() {
    sed -i "s/^ystart.*/ystart=$1/" hjdata_config.sh
}
