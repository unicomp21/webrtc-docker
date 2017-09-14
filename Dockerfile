FROM ubuntu:16.04

MAINTAINER John Davis "jdavis@pcprogramming.com"
RUN apt-get update
RUN apt-get install -y curl
RUN apt-get install -y git wget emacs python

WORKDIR /tmp
RUN git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
ENV PATH=/tmp/depot_tools:"$PATH"

RUN apt-get install -y build-essential lsb-release sudo
RUN apt-get install -y zip xvfb xutils-dev xsltproc xcompmgr x11-utils
RUN echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | sudo debconf-set-selections
RUN apt-get install -y ttf-mscorefonts-installer
RUN apt-get install -y subversion ruby python-yaml python-psutil python-openssl python-opencv
RUN apt-get install -y python-numpy python-crypto python-cherrypy3 php7.0-cgi openbox
RUN apt-get install -y mesa-common-dev linux-libc-dev-armhf-cross libxtst-dev libxt-dev
RUN apt-get install -y libxss-dev libxslt1-dev libxkbcommon-dev libwww-perl libudev-dev
RUN apt-get install -y libtinfo-dev libssl-dev libsqlite3-dev libspeechd2 libspeechd-dev
RUN apt-get install -y libsctp-dev libpulse0 libpulse-dev libpci3 libpci-dev libnss3-dev
RUN apt-get install -y libnss3 libnspr4-dev libnspr4 libkrb5-dev libjpeg-dev libgtk2.0-dev
RUN apt-get install -y libgtk2.0-0 libgtk-3-dev libgnome-keyring0 libgnome-keyring-dev
RUN apt-get install -y libglu1-mesa-dev libglib2.0-dev libgles2-mesa-dev libgl1-mesa-dev
RUN apt-get install -y libgconf2-dev libgbm-dev libffi-dev libelf-dev libdrm-dev
RUN apt-get install -y libcurl4-gnutls-dev libcups2-dev libcap2 libcap-dev libcairo2-dev
RUN apt-get install -y libc6-dev-armhf-cross libbz2-dev libbrlapi0.6 libbrlapi-dev
RUN apt-get install -y libbluetooth-dev libav-tools libasound2-dev libapache2-mod-php7.0
RUN apt-get install -y lib32z1-dev lib32ncurses5-dev intltool gperf
RUN apt-get install -y gcc-5-multilib-arm-linux-gnueabihf g++-mingw-w64-i686
RUN apt-get install -y g++-arm-linux-gnueabihf g++-5-multilib-arm-linux-gnueabihf
RUN apt-get install -y fonts-thai-tlwg fonts-ipafont fonts-indic elfutils cdbs
RUN apt-get install -y binutils-aarch64-linux-gnu appmenu-gtk apache2-bin ant

RUN mkdir /tmp/webrtc
WORKDIR /tmp/webrtc
RUN fetch --nohooks webrtc
RUN gclient sync

RUN /tmp/webrtc/src/build/install-build-deps.sh --no-chromeos-fonts --no-nacl --no-prompt

WORKDIR /tmp/webrtc/src
RUN gclient sync
RUN gn gen out/Default
RUN ninja -C out/Default webrtc

### ssh server
RUN apt-get update && apt-get install -y openssh-server
RUN mkdir /var/run/sshd
RUN echo 'root:screencast' | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
