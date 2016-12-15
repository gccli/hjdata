#! /usr/bin/env python
# -*- coding: utf-8 -*-

import os
import re
import sys
import time
import shlex
import codecs
import subprocess
import ConfigParser

config_file = 'scan.ini'
config = ConfigParser.ConfigParser()
config.read('scan.ini')

def get_config(cfgitem):
    if cfgitem == 'xstart':
        return config.getint('default', cfgitem)
    elif cfgitem == 'ystart':
        return config.getint('default', cfgitem)
    elif cfgitem == 'xmax':
        return config.getint('default', cfgitem)
    elif cfgitem == 'ymax':
        return config.getint('default', cfgitem)
    elif cfgitem == 'min_level':
        return config.getint('default', cfgitem)
    elif cfgitem == 'min_level':
        return config.get('default', cfgitem)

    return config.get('default', cfgitem)

fpfeedback = open(get_config('feedback'), 'w')

def set_config(cfgitem, val):
    config.set('default', cfgitem, val)
    with open(config_file, 'wb') as cfgfp:
        config.write(cfgfp)

def get_bmp(x, y):
    return 'pic/{0}/{1}.bmp'.format(x,y)

def get_report_base(x, y):
    path = 'result/tmp/{0}/{1}.chi'.format(x,y)
    dirn = os.path.dirname(path)
    if not os.path.isdir(dirn):
        os.makedirs(dirn)

    return path

def get_result(x):
    path = 'result/tmp/{0}/result.txt'.format(x)
    dirn = os.path.dirname(path)
    if not os.path.isdir(dirn):
        os.makedirs(dirn)

    return path

def create_tmpdir(x, y):
    tmp = 'tmp/notmatch/{0}'.format(x)
    if not os.path.isdir(tmp):
        os.makedirs(tmp)

    tmp = 'tmp/low/{0}'.format(x)
    if not os.path.isdir(tmp):
        os.makedirs(tmp)

    tmp = 'tmp/bak/{0}'.format(x)
    if not os.path.isdir(tmp):
        os.makedirs(tmp)

def analyze(x, y, filename, fpresult):
    pattern = u'([0-9]+)级([铜铁油硅宝]).*Lv[^0-9]*([0-9]{2})'
    xystr = '({0},{1})'.format(x, y)

    myre = re.compile(pattern, re.U)

    create_tmpdir(x, y)
    outb_chi = get_report_base(x, y)
    outb_txt = outb_chi + '.txt'

    cmd_chi = 'tesseract -l chi {0} {1}'.format(filename, outb_chi)
    if not os.path.exists(outb_txt):
        args = shlex.split(cmd_chi)
        p = subprocess.Popen(args, stderr=subprocess.PIPE)
        p.wait()

    logstr = '{:<10}'.format(xystr)
    fp = codecs.open(outb_txt, encoding='utf-8')
    xtext = fp.read()
    fp.close()

    match = myre.search(xtext)
    if not match:
        print '{0} not match in text file:{1} cmd:{2}'.format(logstr, outb_txt, cmd_chi)
        print xtext
        fpfeedback.write('{0},{1}\n'.format(x,y))
        fpfeedback.flush()
        time.sleep(1)
        return

    level = match.group(1)
    label = match.group(2)
    label = label.encode('utf8')

    line = match.group(0).encode('utf8')
    line = '{:<24}'.format('[{0}]'.format(line))

    print '{0} match:{1} level:{2} label:{3}'.format(logstr, line, level, label)
    fpresult.write('{0},{1},{2},{3}\n'.format(x,y,level,label))

def scan():
    xstart = config.getint('default', 'xstart')
    ystart = config.getint('default', 'ystart')
    xmax = config.getint('default', 'xmax')
    ymax = config.getint('default', 'ymax')


    prompt='Start from ({0},{1}) to ({2},{3}), continue (y/n)? '.format(xstart,ystart,xmax,ymax)
    c = raw_input(prompt)
    if c != 'y': sys.exit(0)

    for x in range(xstart, xmax):
        if not os.path.isdir('pic/{0}'.format(x)):
            continue

        result_file = get_result(x)
        fp = open(result_file, "a+")
        for y in range(ystart, ymax):
            fullpath = get_bmp(x ,y)
            if not os.path.exists(fullpath):
                continue

            analyze(x, y, fullpath, fp)
            set_config('ystart', str(y))
        fp.close()
        set_config('xstart', str(x))

if __name__ == '__main__':
    if len(sys.argv) > 1 and sys.argv[1] == 'reset':
        print 'Reset last scan coordinate'
        set_config('xstart', 0)
        set_config('ystart', 0)

    scan()
