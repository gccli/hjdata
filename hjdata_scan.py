#! /usr/bin/env python
# -*- coding: utf-8 -*-

import os
import re
import sys
import time
import shlex
import codecs
import subprocess
from hjdata_config import config
from hjdata_data import HjData


class HjAnalysis(HjData):
    def __init__(self, **kwargs):
        super(HjAnalysis, self).__init__()
        self.fpfeedback = open(config.get_config('feedback'), 'w')

    def create_tmpdir(self, x, y):
        tmp = 'tmp/notmatch/{0}'.format(x)
        if not os.path.isdir(tmp):
            os.makedirs(tmp)

        tmp = 'tmp/low/{0}'.format(x)
        if not os.path.isdir(tmp):
            os.makedirs(tmp)

        tmp = 'tmp/bak/{0}'.format(x)
        if not os.path.isdir(tmp):
            os.makedirs(tmp)

    def analyze(self, x, y, filename):
        pattern = u'([0-9]+)级([铜铁油硅宝]).*Lv[^0-9]*([0-9]{2})'
        xystr = '({0},{1})'.format(x, y)

        myre = re.compile(pattern, re.U)

        self.create_tmpdir(x, y)
        outb_chi = self.get_report_base(x, y)
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
            self.fpfeedback.write('{0},{1}\n'.format(x,y))
            self.fpfeedback.flush()
            time.sleep(1)
            return

        level = match.group(1)
        label = match.group(2)
        label = label.encode('utf8')

        line = match.group(0).encode('utf8')
        line = '{:<24}'.format('[{0}]'.format(line))

        print '{0} match:{1} level:{2} label:{3}'.format(logstr, line, level, label)
        self.insert(x,y,level,label)

    def scan(self):
        xstart = config.get_config('xstart')
        ystart = config.get_config('ystart')
        xmax = config.get_config('xmax')
        ymax = config.get_config('ymax')

        prompt='Start from ({0},{1}) to ({2},{3}), continue (y/n)? ' \
            .format(xstart,ystart,xmax,ymax)

        c = raw_input(prompt)
        if c != 'y': sys.exit(0)

        for x in range(xstart, xmax):
            if not os.path.isdir('pic/{0}'.format(x)):
                continue

            for y in range(ystart, ymax):
                fullpath = self.get_bmp(x ,y)
                if not os.path.exists(fullpath):
                    continue

                self.analyze(x, y, fullpath)
                config.set_config('ystart', y)
            self.commit()

            config.set_config('xstart', x)
            ystart = 0

if __name__ == '__main__':
    if len(sys.argv) > 1 and sys.argv[1] == 'reset':
        config.set_config('xstart', 0)
        config.set_config('ystart', 0)

    hjant = HjAnalysis()
    hjant.scan()
