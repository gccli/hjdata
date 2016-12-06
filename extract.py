#! /usr/bin/env python
# -*- coding: utf-8 -*-

import os
import sys
import glob
import time
import math
import argparse

label_mapping = {'硅':'si','宝':'gem','铁':'iron','铜':'cu','油':'oil'}
parser = argparse.ArgumentParser(description='Extract coordinate for specific conditions')

parser.add_argument('-c', type=int, dest='count',
                    help='Extract coordinate no more than COUNT')
parser.add_argument('-xy', nargs=2, type=int, metavar=('X', 'Y'),
                    help='Extract coordinates near by X and Y')
parser.add_argument('-r', type=float, default=100, dest='radius',
                    help='When specify xy, the RADIUS = sqrt(abs(x-x0)^2+abs(y-y0)^2)')
parser.add_argument('-ge', type=int, metavar='N',
                    help='Extract mine level greater than or equal to N')
parser.add_argument('-le', type=int, metavar='N',
                    help='Extract mine level less than or equal to N')
parser.add_argument('-eq', type=int, metavar='N',
                    help='Extract mine level less equal to N')
parser.add_argument('label', nargs='*', choices=['si','gem','iron','cu','oil'])

args = parser.parse_args()

csvfiles = glob.glob('result/*.csv')
for path in csvfiles:
    fp = open(path, 'r')

    for line in fp.readlines():
        line_fields=line.strip().split(',')
        x,y,l=line_fields[:3]
        if x == 'x':
            continue

        x=int(x)
        y=int(y)
        l=int(l)
        t=''
        if len(line_fields) > 3 and line_fields[3]:
            t = line_fields[3]
        if args.ge and l < args.ge:
            continue
        if args.le and l > args.le:
            continue
        if args.eq and l != args.eq:
            continue
        if args.label and not t:
            continue
        if args.label and t:
            label = label_mapping[t]
            if not label in args.label:
                continue

        if args.xy:
            a=abs(args.xy[0]-x)
            b=abs(args.xy[1]-y)
            c=math.hypot(a, b)
            if c > args.distance:
                continue
        print x,y
print -1,-1
