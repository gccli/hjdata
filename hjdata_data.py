#! /usr/bin/env python
# -*- coding: utf-8 -*-

import os
import csv
import sqlite3
from hjdata_config import config

class HjData(object):
    tbname = 'coordinate'
    pic_path = 'pic'
    result_path = 'result'

    def __init__(self):
        dbname = config.get_config('database')
        self.conn = sqlite3.connect(dbname, isolation_level=None)
        self.cursor = self.conn.cursor()

        sql = 'CREATE TABLE IF NOT EXISTS {0}(x int, y int, level int, label varchar, PRIMARY KEY(x,y))'\
              .format(self.tbname)

        self.cursor.execute(sql)

        userdata = config.get_config('userdata')
        with open(userdata, 'rb') as csvfp:
            reader = csv.reader(csvfp)
            for row in reader:
                self.insert(row[0], row[1], row[2], row[3])

        self.commit()

    def insert(self, *args):
        x,y,lv,t = args

        sql = 'INSERT INTO {0}(x,y,level,label) values({1},{2},{3},"{4}")' \
              .format(self.tbname, x, y, lv, t)

        try:
            self.cursor.execute(sql)
        except sqlite3.Error as e:
            return False

        return True


    def delete(self, x, y):
        sql = 'DELETE FROM {0} WHERE x={1} y={2}'.format(self.tbname, x, y)
        try:
            self.cursor.execute(sql)
        except sqlite3.Error as e:
            return False

        return True

    def commit(self):
        self.conn.commit()

    def get_bmp(self, x, y):
        return self.pic_path + '/{0}/{1}.bmp'.format(x,y)

    def get_report_base(self, x, y):
        path = self.result_path + '/tmp/{0}/{1}.chi'.format(x,y)
        dirn = os.path.dirname(path)
        if not os.path.isdir(dirn):
            os.makedirs(dirn)

        return path

    def export(self, **kwargs):
        min_lv = config.get_config('min_lv')
        sql = 'SELECT * from {0} WHERE level >= {1}'.format(self.tbname, min_lv)
        if kwargs.has_key('label'):
            sql += ' AND label="{0}"'.format(kwargs.get('label'))
        sql += ' ORDER BY x,y'

        self.cursor.execute(sql)
        result = kwargs.get('result') if kwargs.has_key('result') else config.get_config('result')

        with open(result, 'wb') as fp:
            fp.write('x,y,level,label\n')

            for row in self.cursor:
                fp.write('{0},{1},{2},{3}\n'.format(row[0],row[1],row[2],row[3].encode('utf8')))

            fp.close()

    def remove(self, x, y):
        bmp = self.get_bmp(x, y)
        tmp = self.get_report_base(x.y) + '.txt'

        print 'rm -f {0} {1}'.format(bmp, tmp)
        os.unlink(bmp)
        os.unlink(tmp)
        self.delete(x, y)
        self.export()

if __name__ == '__main__':
    hjdata = HjData()
    if len(sys.argv) == 3:
        hjdata.remove(int(sys.argv[1]), int(sys.argv[2]))
    hjdata.export()
