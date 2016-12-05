#! /usr/bin/env python
# -*- coding: utf-8 -*-

import os
import sys
import glob
import time
import math
import argparse

parser = argparse.ArgumentParser(description='Extract coordinate for specific conditions')

parser.add_argument('-c', '--count', type=int,
                    help='Extract coordinate no more than N')
parser.add_argument('-xy', nargs=2, type=int,
                    help='Extract coordinates near by x and y')
parser.add_argument('-d', '--distance', type=float, default=100,
                    help='When specify xy, the distance = sqrt(abs(x1-x)^2 +abs(y1-y)^2)')
parser.add_argument('-t', type=str, dest='label',
                    help='Extract coordinate for specific type')
parser.add_argument('-ge', type=int,
                    help='Extract mine level greater than or equal to N')
parser.add_argument('-le', type=int,
                    help='Extract mine level less than or equal to N')
parser.add_argument('-eq', type=int,
                    help='Extract mine level less equal to N')

parser.add_argument('csvfiles', nargs='*', help='csv files')
args = parser.parse_args()

csvfiles = args.csvfiles
if not csvfiles:
    csvfiles = glob.glob('result/*.csv')

for path in csvfiles:
    fp = open(path, 'r')

    for line in fp.readlines():
        dest=line.strip().split(',')
        x,y,l=dest[:3]
        if x == 'x':
            continue

        x=int(x)
        y=int(y)
        l=int(l)
        if args.ge and l < args.ge:
            continue
        if args.le and l > args.le:
            continue
        if args.eq and l != args.eq:
            continue

        if args.label and len(dest) > 3:
            if dest[3] != args.label:
                continue
        if args.xy:
            a=abs(args.xy[0]-x)
            b=abs(args.xy[1]-y)
            c=math.hypot(a, b)
            if c > args.distance:
                continue
        print x,y
print -1,-1
