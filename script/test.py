#!/usr/bin/env python 
#coding=utf-8


from qbittorrent import Client
import time
import requests
from time import sleep
import ConfigParser
import os
import sys




qb = Client('http://localhost:9898/')

qb.login('plutohiyo', '')
# not required when 'Bypass from localhost' setting is active.
# defaults to admin:admin.
# to use defaults, just do qb.login()
info_hash = '6ef2fb254fd27f33d1f31f9d066259359713bc88'
qb.pause(info_hash)
torrents = qb.torrents()

for torrent in torrents:
  print torrent['name']
  print torrent
