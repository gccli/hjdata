#! /usr/bin/env python
# -*- coding: utf-8 -*-

import os
import re
import sys
import time
import shlex
import signal
import shutil
import codecs
import subprocess
from hjdata_config import config
from hjdata_data import HjData

class HjAnalysis(HjData):
    modify_rule = {15:16, 13:18, 25:26, 23:28, 35:36, 33:38, 45:46, 43:48, 55:56, 53:58, 65:66, 63:68}

    def __init__(self, **kwargs):
        super(HjAnalysis, self).__init__()
        self.fpfeedback = open(config.get_config('feedback'), 'w')

        pattern = u'([0-9]+)级([铜铁油硅宝]).*Lv[^0-9]*([0-9]+)'
        self.regex = re.compile(pattern, re.U)

    def create_tmpdir(self, x, y):
        tmp = 'tmp/notmatch/{0}'.format(x)
        if not os.path.isdir(tmp):
            os.makedirs(tmp)

        tmp = 'tmp/low/{0}'.format(x)
        if not os.path.isdir(tmp):
            os.makedirs(tmp)

        tmp = 'tmp/bad/{0}'.format(x)
        if not os.path.isdir(tmp):
            os.makedirs(tmp)

    def analyze(self, x, y, filename):
        xystr = '({0},{1})'.format(x, y)

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

        match = self.regex.search(xtext)
        if not match:
            print '{0} not match in text file:{1} cmd:{2}'.format(logstr, outb_txt, cmd_chi)
            print xtext.encode('utf8')
            self.fpfeedback.write('{0},{1},mismatch\n'.format(x,y))
            # time.sleep(1)
            return

        level  = int(match.group(1))
        label  = match.group(2)
        level2 = int(match.group(3))
        label  = label.encode('utf8')

        line = match.group(0).encode('utf8')
        line = '{:<24}'.format('[{0}]'.format(line))

        level2 = level2%100

        infostr = ''
        if self.modify_rule.has_key(level):
            infostr = 'modify {0} to {1}'.format(level, self.modify_rule[level])
            level = self.modify_rule[level]

        if self.modify_rule.has_key(level2):
            infostr += ' lv {0} to {1}'.format(level2, self.modify_rule[level2])
            level2 = self.modify_rule[level2]

        if level != level2:
            infostr += ' not equal'
            self.fpfeedback.write('{0},{1},ne\n'.format(x,y))

        if (level%2) == 1:
            infostr += ' odd level'
            self.fpfeedback.write('{0},{1},odd\n'.format(x,y))

        print '{0} match:{1} level:({2},{3}) label:{4} {5}' \
            .format(logstr, line, level, level2, label, infostr)

        if level <= 30:
            dest = 'tmp/low/{0}/{1}.bmp'.format(x,y)
            ddir = os.path.dirname(dest)
            try:
                os.mkdir(ddir)
            except:
                pass
            shutil.move(filename, dest)
            self.remove(x,y,0)
            print 'file moved'
            return

        if (level%2) == 1:
            return

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

                self.fpfeedback.flush()
            self.commit()

            config.set_config('xstart', x)
            ystart = 0

if __name__ == '__main__':
    hjant = None

    def signal_handler(signo, frame):
        if hjant:
            print '\nQuit and commit data'
            hjant.commit()
        sys.exit(0)

    if len(sys.argv) > 1 and sys.argv[1] == 'reset':
        config.set_config('xstart', 0)
        config.set_config('ystart', 0)

    signal.signal(signal.SIGINT, signal_handler)
    hjant = HjAnalysis()
    hjant.scan()
