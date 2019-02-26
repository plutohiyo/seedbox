#!/usr/bin/env python 
#coding=utf-8

import requests
import codecs
import re
import HTMLParser
#import feedparser
import bs4
from bs4 import BeautifulSoup
from qbittorrent import Client



session = requests.session()
baseURL = "http://asiandvdclub.org"
headers = {'user-agent':'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.113 Safari/537.36'}
session.post(baseURL+"/takelogin.php", {"apple":"evil", "username":"", "password":""},headers = headers)

filterWordA = re.compile(r'(\d{6})')
filterTime = re.compile(r'(\d{2})m')
filterOwner=["poppipe", "kakeruSMC"]

def filterSeederAndDiscount(Obj):
    dataTorrentOwner = Obj.find('td', class_="torrentowner" )
    dataTorrentName = Obj.find('td', class_="torrentname" )
    dataSeeder = Obj.find('td',class_="seeders")
    dataLeecher = Obj.find('td',class_="leechers")
    dataAge = Obj.find('td',class_="time")
    isSilver = Obj.find('img',src="/pic/silver.gif")
    isBlu = Obj.find('img',class_="main-bluray tt-bluray")

    soupTorrentOwner = BeautifulSoup(str(dataTorrentOwner),'html.parser')
    soupTorrentName = BeautifulSoup(str(dataTorrentName),'html.parser')
    soupSeeder = BeautifulSoup(str(dataSeeder),'html.parser')
    soupLeecher = BeautifulSoup(str(dataLeecher),'html.parser')
    soupTimer = BeautifulSoup(str(dataAge),'html.parser')

    Age = re.search(filterTime, str(soupTimer.span.string))
    TorrentOwner = BeautifulSoup(str(soupTorrentOwner.find_all(href=re.compile("userdetails"))),'html.parser').a.string

    if TorrentOwner not in filterOwner:
        #print TorrentOwner
        if isSilver or isBlu:
            if not (soupSeeder.find_all('a')) or (soupSeeder.find_all('a') and int(soupSeeder.td.string) == 1):
                #print soupTorrentName  
                #seeders = int(soupSeeder.td.string)
                #if seeders == 1:
                if soupLeecher.find_all('a'):
                    leechers = int(soupLeecher.td.string)
                    if leechers >=5 and len(soupTimer.span.string)<4 and int(Age.group(1))<=59:
                        TorrentId = (re.search(filterWordA, soupTorrentName.a["href"]).group())
                        return TorrentId
    return False

def filterIndexPage():
    
    return

'''def getTorrentDetails(torrentId,cookies):
    detailData = requests.get("https://asiandvdclub.org/details.php?id="+torrentId,cookies=cookies,headers=headers)
    print detailData.content
    return detailData.content
    '''


IndexPage = session.get(baseURL+"/browse.php?orderBy=added&direction=DESC&page=1",headers=headers)

soup = BeautifulSoup(IndexPage.text,"html.parser")
browsedata = soup.find_all('tr',class_=re.compile('even|odd'),limit=10)

qb = Client('http://localhost:9898/')
qb.login('', '')
dl_path = '/home/Download/qbittorent/'


for item in browsedata:
    getSingleData = str(item)
    getSingleSoup = BeautifulSoup(getSingleData,"html.parser")
    TorrentID = filterSeederAndDiscount(getSingleSoup)
    if TorrentID:
        print TorrentID
        fileContent = session.get(baseURL+'/download.php?id='+TorrentID,headers = headers)
        #fpoint = open(TorrentID+'.torrent','wb')
        #fpoint.write(fileContent.content)
        #fpoint.close()
        #torrent_file = open(TorrentID+'.torrent','rb')
        qb.download_from_file(fileContent.content, savepath=dl_path)
        
#fileContent = session.get(baseURL+'/download.php?id=28490',headers = headers)
#qb.download_from_file(fileContent.content, savepath=dl_path)
#getTorrentDetails(a, session.cookies)

