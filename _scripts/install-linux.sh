#!/bin/bash

set -e
source $(dirname $0)/make_static_libs_common.sh

# >= 2.0 harfbuzz for freetype
add-apt-repository -y ppa:reviczky/harfbuzz

# cmake >= 3.13 required for some of the libs
wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | apt-key -y add -
apt-add-repository -y 'deb https://apt.kitware.com/ubuntu/ bionic main'

apt update -y
apt -y install make cmake ninja-build \
	p7zip-full \
	freeglut3-dev \
	libogg-dev \
	wget \
	vim \
	dpkg-dev \
	apt-utils \
	pkg-config \
	po4a \
	autoconf \
	libtool \
	autopoint \
	xmlto \
	libharfbuzz-dev

apt install -y build-essential software-properties-common

apt remove -y snapd || true
apt remove -y gcc g++ || true
apt remove -y $(apt list --installed | cut -d'/' -f1 | grep -e "gcc-[0-9]+$")
apt remove -y $(apt list --installed | cut -d'/' -f1 | grep -e "g\+\+-[0-9]+*$")

#apt install -y gcc-snapshot
case $UBUNTU_MAJORVER in
20)
  VER="10"
  ;;
18)
  VER="10"
  add-apt-repository ppa:ubuntu-toolchain-r/test -y
  apt update -y
  ;;
16)
  VER="9"
  add-apt-repository ppa:ubuntu-toolchain-r/test -y
  apt update -y
  ;;
*)
  exit 1
  ;;
esac

apt install -y gcc-$VER g++-$VER

apt -y autoremove

update-alternatives \
--install /usr/bin/gcc gcc /usr/bin/gcc-$VER 60 \
--slave /usr/bin/g++ g++ /usr/bin/g++-$VER \
--slave /usr/bin/gcov gcov /usr/bin/gcov-$VER \
--slave /usr/bin/gcov-tool gcov-tool /usr/bin/gcov-tool-$VER \
--slave /usr/bin/gcc-ar gcc-ar /usr/bin/gcc-ar-$VER \
--slave /usr/bin/gcc-nm gcc-nm /usr/bin/gcc-nm-$VER \
--slave /usr/bin/gcc-ranlib gcc-ranlib /usr/bin/gcc-ranlib-$VER

update-alternatives \
--install /usr/bin/c++ c++ /usr/bin/g++-$VER 60

update-alternatives \
--install /usr/bin/cc cc /usr/bin/gcc-$VER 60

sed -i 's/# deb-src/deb-src/g' /etc/apt/sources.list
apt update -y
