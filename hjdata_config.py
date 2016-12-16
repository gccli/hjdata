#! /usr/bin/env python
# -*- coding: utf-8 -*-

import ConfigParser

class HjConfig(object):
    def __init__(self, cfg='hjdata.ini'):
        self.config_file = cfg

        self.config = ConfigParser.ConfigParser()
        self.config.read(cfg)


    def get_config(self, cfgitem):
        if cfgitem == 'xstart':
            return self.config.getint('default', cfgitem)
        elif cfgitem == 'ystart':
            return self.config.getint('default', cfgitem)
        elif cfgitem == 'xmax':
            return self.config.getint('default', cfgitem)
        elif cfgitem == 'ymax':
            return self.config.getint('default', cfgitem)
        elif cfgitem == 'min_level':
            return self.config.getint('default', cfgitem)
        elif cfgitem == 'min_level':
            return self.config.get('default', cfgitem)

        return self.config.get('default', cfgitem)

    def set_config(self, cfgitem, val):
        self.config.set('default', cfgitem, str(val))
        with open(self.config_file, 'wb') as cfgfp:
            self.config.write(cfgfp)

config = HjConfig()
