#!/bin/bash

set -e
source $(dirname $0)/make_static_libs_common.sh

export DEBIAN_FRONTEND=noninteractive

case $UBUNTU_MAJORVER in
    20) GCCVER="13" ;;
    18) GCCVER="13" ;;
    *)
        echo "Unsupported ubuntu version $UBUNTU_MAJORVER"
        exit 1
        ;;
esac

apt-get update
apt-get install --no-install-recommends --yes software-properties-common
add-apt-repository ppa:ubuntu-toolchain-r/test --yes
apt-get update
apt-get upgrade --yes

# Base build dependencies:
apt-get install --no-install-recommends --yes \
    make \
    wget \
    pkg-config \
    git \
    python3-pip \
    gcc-$GCCVER \
    g++-$GCCVER

# For GLEW:
apt-get install --no-install-recommends --yes libxmu-dev libxi-dev libgl-dev

pip3 install --upgrade pip
pip3 install scikit-build
pip3 install cmake==3.27.*

update-alternatives \
--install /usr/bin/gcc gcc /usr/bin/gcc-$GCCVER 60 \
--slave /usr/bin/g++ g++ /usr/bin/g++-$GCCVER \
--slave /usr/bin/gcov gcov /usr/bin/gcov-$GCCVER \
--slave /usr/bin/gcov-tool gcov-tool /usr/bin/gcov-tool-$GCCVER \
--slave /usr/bin/gcc-ar gcc-ar /usr/bin/gcc-ar-$GCCVER \
--slave /usr/bin/gcc-nm gcc-nm /usr/bin/gcc-nm-$GCCVER \
--slave /usr/bin/gcc-ranlib gcc-ranlib /usr/bin/gcc-ranlib-$GCCVER

update-alternatives \
--install /usr/bin/c++ c++ /usr/bin/g++-$GCCVER 60

update-alternatives \
--install /usr/bin/cc cc /usr/bin/gcc-$GCCVER 60
