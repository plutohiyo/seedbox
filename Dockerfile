FROM ubuntu:18.04

MAINTAINER plutohiyo@gmail.com

RUN	sed -i 's/#\ deb-src\ http:\/\/archive.ubuntu.com\/ubuntu\/\ xenial\ universe/deb-src\ http:\/\/archive.ubuntu.com\/ubuntu\/\ xenial\ universe/' /etc/apt/sources.list \
	&& echo "postfix postfix/main_mailer_type string 'Local only'" | debconf-set-selections \
	&& echo "postfix postfix/mailname string 'root'" | debconf-set-selections \
	&& buildDeps='sysstat lsof iotop nload vim smartmontools curl vnstat git iperf3 wget net-tools iputils-ping git screen python nethogs systemd locate python-pip openssh-server software-properties-common' \
	&& apt-get update \
	&& apt-get install -y $buildDeps \
	&& add-apt-repository -y ppa:qbittorrent-team/qbittorrent-stable \
	&& add-apt-repository -y ppa:deluge-team/ppa \
	&& apt-get update \
	&& apt-get install -y qbittorrent qbittorrent-nox deluged deluge-web deluge-console \
	&& sed -i '/^Port/ c\Port 2022' /etc/ssh/sshd_config

COPY conf/limits.conf /etc/security/limits.conf
COPY conf/*.service /etc/systemd/system/
COPY conf/system.conf /etc/systemd/system.conf
COPY deluge-patch/deluge-all.js /usr/lib/python2.7/dist-packages/deluge/ui/web/js/deluge-all.js
COPY deluge-patch/torrentmanager.py /usr/lib/python2.7/dist-packages/deluge/core/torrentmanager.py
COPY deluge-patch/addtorrentdialog.py /usr/lib/python2.7/dist-packages/deluge/ui/gtkui/addtorrentdialog.py
COPY deluge-patch/add_torrent_dialog.glade /usr/lib/python2.7/dist-packages/deluge/ui/gtkui/glade/add_torrent_dialog.glade
COPY conf/deluge-log-conf /etc/logrotate.d/deluge

RUN	cd /usr/lib/python2.7/dist-packages/deluge/core && rm torrentmanager.pyc && python2.7 -m py_compile torrentmanager.py \
	&& cd /usr/lib/python2.7/dist-packages/deluge/ui/gtkui/ && rm addtorrentdialog.pyc && python2.7 -m py_compile addtorrentdialog.py \
	&& systemctl enable /etc/systemd/system/qbittorrent.service \
	&& systemctl start qbittorrent \
	&& systemctl enable /etc/systemd/system/deluged.service \
	&& systemctl start deluged \
	&& systemctl enable /etc/systemd/system/deluge-web.service \
	&& systemctl start deluge-web \
	&& pip install --upgrade pip \
	&& hash -d pip \
	&& pip install --upgrade virtualenv \
	&& pip install --upgrade setuptools \
	&& pip install flexget \
	&& pip install python-qbittorrent \
	&& pip install pushbullet.py \
	&& pip install beautifulsoup4 \
	&& pip install -U selenium \
	&& apt-get autoremove -y \
	&& apt-get autoclean -y

VOLUME ["/download", "/root"] 

EXPOSE 9898/tcp 9797/tcp 9696/tcp 28888/tcp 27777/tcp 26666/tcp 2022/tcp

CMD ["/sbin/init"]
