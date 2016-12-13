#! /bin/bash

xstart=10
ystart=342

export xstart
export ystart
export xmax=599
export ymax=599
export min_lv=58

function setx() {
    sed -i "s/^xstart.*/xstart=$1/" hjdata_config.sh
}

function sety() {
    sed -i "s/^ystart.*/ystart=$1/" hjdata_config.sh
}
