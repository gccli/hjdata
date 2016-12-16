#! /usr/bin/env python
# -*- coding: utf-8 -*-

import csv
import sqlite3
from hjdata_config import config

class HjData(object):
    tbname = 'coordinate'

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
            pass

    def commit(self):
        self.conn.commit()

    def export(self):
        result = config.get_config('result')
