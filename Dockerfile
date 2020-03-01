FROM ubuntu:18.04

MAINTAINER plutohiyo@gmail.com

RUN	sed -i 's/#\ deb-src\ http:\/\/archive.ubuntu.com\/ubuntu\/\ xenial\ universe/deb-src\ http:\/\/archive.ubuntu.com\/ubuntu\/\ xenial\ universe/' /etc/apt/sources.list \
	&& echo "postfix postfix/main_mailer_type string 'Local only'" | debconf-set-selections \
	&& echo "postfix postfix/mailname string 'root'" | debconf-set-selections \
	&& buildDeps='sysstat lsof iotop nload vim smartmontools curl vnstat git iperf3 wget net-tools iputils-ping git screen python nethogs systemd locate python-pip python3 python3-pip openssh-server software-properties-common' \
        && apt-get update \
	&& apt-get install -y $buildDeps \
        && apt-get update \
	&& add-apt-repository -y ppa:qbittorrent-team/qbittorrent-stable \
	&& add-apt-repository -y ppa:deluge-team/ppa \
	&& apt-get install -y qbittorrent qbittorrent-nox deluged deluge-web deluge-console

COPY pkg/transmission_2.93-skip-ubuntu-18.04-1_amd64.deb /root/ 
COPY conf/limits.conf /etc/security/limits.conf
COPY conf/*.service /etc/systemd/system/
COPY deluge-patch/deluge-all.js /usr/lib/python2.7/dist-packages/deluge/ui/web/js/deluge-all.js
COPY deluge-patch/torrentmanager.py /usr/lib/python2.7/dist-packages/deluge/core/torrentmanager.py
COPY deluge-patch/addtorrentdialog.py /usr/lib/python2.7/dist-packages/deluge/ui/gtkui/addtorrentdialog.py
COPY deluge-patch/add_torrent_dialog.glade /usr/lib/python2.7/dist-packages/deluge/ui/gtkui/glade/add_torrent_dialog.glade
COPY conf/deluge-log-conf /etc/logrotate.d/deluge

RUN	dpkg -i /root/transmission_2.93-skip-ubuntu-18.04-1_amd64.deb \
	&& rm /root/transmission_2.93-skip-ubuntu-18.04-1_amd64.deb \
	&& apt-get install -y psmisc libevent-dev libminiupnpc-dev \
	&& cd /usr/lib/python2.7/dist-packages/deluge/core && python2.7 -m py_compile torrentmanager.py \
	&& cd /usr/lib/python2.7/dist-packages/deluge/ui/gtkui && python2.7 -m py_compile addtorrentdialog.py \
	&& systemctl enable /etc/systemd/system/qbittorrent.service \
	&& systemctl enable /etc/systemd/system/deluged.service \
	&& systemctl enable /etc/systemd/system/deluge-web.service \
	&& systemctl enable /etc/systemd/system/transmission.service \
	&& pip install --upgrade pip \
	&& hash -r pip \
	&& pip install --upgrade virtualenv \
	&& pip install --upgrade setuptools \
	&& pip3 install --upgrade pip \
	&& pip3 install --upgrade virtualenv \
	&& pip3 install --upgrade setuptools \
	&& cd /root && virtualenv flexget && /root/flexget/bin/pip3 install flexget \
	&& apt-get autoremove -y \
	&& apt-get autoclean -y  \
	&& sed -i 's/^Port /#Port /g' /etc/ssh/sshd_config \
	&& sed -i 's/^PermitRootLogin /#PermitRootLogin /g' /etc/ssh/sshd_config \
	&& echo "Port 2022" >> /etc/ssh/sshd_config \
	&& echo "PermitRootLogin yes" >> /etc/ssh/sshd_config

RUN	echo 1 | bash -c "$(wget --no-check-certificate -qO- https://github.com/ronggang/transmission-web-control/raw/master/release/install-tr-control.sh)" \
	&& sed -i "s/\"speed\"));system.serverSessionStats=a;/\"speed\"));\$(\'title\').html(\"D:\"+formatSize(a.downloadSpeed,false,\"speed\")+\", U:\"+formatSize(a.uploadSpeed,false,\"speed\"));system.serverSessionStats=a;/g"  /usr/local/share/transmission/web/tr-web-control/script/min/system.min.js

VOLUME ["/download", "/root"] 

EXPOSE 9898/tcp 9797/tcp 9696/tcp 28888/tcp 27777/tcp 26666/tcp 2022/tcp

CMD ["/sbin/init"]
