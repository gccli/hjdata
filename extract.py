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
                    help='When -xy is given, search radius no more than RADIUS, default is 100')
parser.add_argument('-level', nargs=2, metavar=('OP', 'N'),
                    help='Extract specific mine level, where OP must be one of (gt, ge, eq, le, lt), e.g. -level gt 60')

parser.add_argument('-x', nargs=2, metavar=('OP', 'N'),
                    help='Extract specific X, where OP must be one of (gt, ge, eq, le, lt), e.g. -x gt 300')
parser.add_argument('-y', nargs=2, metavar=('OP', 'N'),
                    help='Extract specific Y, where OP must be one of (gt, ge, eq, le, lt), e.g. -y gt 350')

parser.add_argument('label', nargs='*', choices=['si','gem','iron','cu','oil'])

args = parser.parse_args()

def exec_level(x, op, y):
    if op == 'ge':
        if x >= y: return 1
    elif op == 'gt':
        if x > y:  return 1
    elif op == 'eq':
        if x == y: return 1
    elif op == 'le':
        if x <= y: return 1
    elif op == 'lt':
        if x < y:  return 1
    return 0

csvfiles = glob.glob('result/*.csv')
for path in csvfiles:
    fp = open(path, 'r')

    for line in fp.readlines():
        line_fields=line.strip().split(',')
        x,y,l=line_fields[:3]
        if x == 'x': continue

        x=int(x)
        y=int(y)
        l=int(l)
        t=''
        if len(line_fields) > 3 and line_fields[3]:
            t = line_fields[3]

        if args.level:
            if not exec_level(l, args.level[0], int(args.level[1])):
                continue

        if args.x:
            if not exec_level(x, args.x[0], int(args.x[1])):
                continue

        if args.y:
            if not exec_level(y, args.y[0], int(args.y[1])):
                continue


        if args.label:
            if not t:
                continue
            else:
                label = label_mapping[t]
                if not label in args.label:
                    continue
        if args.xy:
            a=abs(args.xy[0]-x)
            b=abs(args.xy[1]-y)
            c=math.hypot(a, b)
            if c > args.radius:
                continue
        print x,y
