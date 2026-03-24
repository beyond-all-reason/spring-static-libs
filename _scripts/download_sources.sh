#!/bin/bash

set -e

if [ $# -eq 0 ]; then
	echo "Usage: $0 <destination-directory>"
	exit 2
fi

DLDIR=$1
mkdir -p "${DLDIR}"

GCS_CACHE_BASE=https://storage.googleapis.com/recoil-linux-static-build-sources-17834

function DOWNLOAD {
	local URL=$1
	local SHA256=$2
	local NAME=${3:-$(basename "$URL")}
	local FILENAME=${DLDIR}/${NAME}
	if [ -s "$FILENAME" ] && echo "$SHA256  $FILENAME" | sha256sum --check 2>/dev/null; then
		return
	fi
	rm -f "$FILENAME"
	echo "Trying cache for ${NAME}..."
	if wget -q "${GCS_CACHE_BASE}/${NAME}" -O "$FILENAME" 2>/dev/null \
	   && echo "$SHA256  $FILENAME" | sha256sum --check 2>/dev/null; then
		return
	fi
	rm -f "$FILENAME"
	echo "Downloading ${NAME} from origin..."
	wget -q "$URL" -O "$FILENAME"
	echo "$SHA256  $FILENAME" | sha256sum --check
}

# zlib (used for generic/nehalem builds)
DOWNLOAD https://zlib.net/fossils/zlib-1.3.1.tar.gz \
         9a93b2b7dfdac77ceba5a558a580e74667dd6fede4585b91eefb60f03b72df23

# zlib-ng (used for non-generic builds)
DOWNLOAD https://github.com/zlib-ng/zlib-ng/archive/refs/tags/2.1.5.tar.gz \
         3f6576971397b379d4205ae5451ff5a68edf6c103b2f03c4188ed7075fbb5f04 \
         zlib-ng-2.1.5.tar.gz

# libpng
DOWNLOAD https://downloads.sourceforge.net/project/libpng/libpng16/1.6.50/libpng-1.6.50.tar.gz \
         708f4398f996325819936d447f982e0db90b6b8212b7507e7672ea232210949a

# libgif
DOWNLOAD https://downloads.sourceforge.net/project/giflib/giflib-5.x/giflib-5.2.2.tar.gz \
         be7ffbd057cadebe2aa144542fd90c6838c6a083b5e8a9048b8ee3b66b29d5fb

# libjpeg
DOWNLOAD https://www.ijg.org/files/jpegsrc.v9f.tar.gz \
         04705c110cb2469caa79fb71fba3d7bf834914706e9641a4589485c1f832565b

# libtiff
DOWNLOAD https://download.osgeo.org/libtiff/tiff-4.7.0.tar.gz \
         67160e3457365ab96c5b3286a0903aa6e78bdc44c4bc737d2e486bcecb6ba976

# DevIL
DOWNLOAD https://downloads.sourceforge.net/project/openil/DevIL/1.8.0/DevIL-1.8.0.tar.gz \
         0075973ee7dd89f0507873e2580ac78336452d29d34a07134b208f44e2feb709

# libunwind
DOWNLOAD https://download.savannah.nongnu.org/releases/libunwind/libunwind-1.6.2.tar.gz \
         4a6aec666991fb45d0889c44aede8ad6eb108071c3554fcdff671f9c94794976

# GLEW
DOWNLOAD https://downloads.sourceforge.net/project/glew/glew/2.2.0/glew-2.2.0.tgz \
         d4fc82893cfb00109578d0a1a2337fb8ca335b3ceccf97b97e5cc7f08e4353e1

# OpenSSL
DOWNLOAD https://github.com/openssl/openssl/releases/download/openssl-3.5.2/openssl-3.5.2.tar.gz \
         c53a47e5e441c930c3928cf7bf6fb00e5d129b630e0aa873b08258656e7345ec

# nghttp2
DOWNLOAD https://github.com/nghttp2/nghttp2/releases/download/v1.66.0/nghttp2-1.66.0.tar.gz \
         e178687730c207f3a659730096df192b52d3752786c068b8e5ee7aeb8edae05a

# libpsl
DOWNLOAD https://github.com/rockdaboot/libpsl/releases/download/0.21.5/libpsl-0.21.5.tar.gz \
         1dcc9ceae8b128f3c0b3f654decd0e1e891afc6ff81098f227ef260449dae208

# curl
DOWNLOAD https://curl.se/download/curl-8.15.0.tar.gz \
         d85cfc79dc505ff800cb1d321a320183035011fa08cb301356425d86be8fc53c

# libogg
DOWNLOAD https://github.com/xiph/ogg/releases/download/v1.3.6/libogg-1.3.6.tar.gz \
         83e6704730683d004d20e21b8f7f55dcb3383cdf84c0daedf30bde175f774638

# libvorbis
DOWNLOAD https://github.com/xiph/vorbis/releases/download/v1.3.7/libvorbis-1.3.7.tar.gz \
         0e982409a9c3fc82ee06e08205b1355e5c6aa4c36bca58146ef399621b0ce5ab

# libuuid
DOWNLOAD https://downloads.sourceforge.net/project/libuuid/libuuid-1.0.3.tar.gz \
         46af3275291091009ad7f1b899de3d0cea0252737550e7919d17237997db5644

# xz
DOWNLOAD https://github.com/tukaani-project/xz/releases/download/v5.8.1/xz-5.8.1.tar.gz \
         507825b599356c10dca1cd720c9d0d0c9d5400b9de300af00e4d1ea150795543

# minizip
DOWNLOAD https://github.com/nmoinvaz/minizip/archive/refs/tags/4.0.10.tar.gz \
         c362e35ee973fa7be58cc5e38a4a6c23cc8f7e652555daf4f115a9eb2d3a6be7 \
         minizip-ng-4.0.10.tar.gz

echo "All sources downloaded and verified."
