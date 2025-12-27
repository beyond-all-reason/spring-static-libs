#!/bin/bash

set -e
source $(dirname $0)/make_static_libs_common.sh

# zlib
if [[ $ARCHINPUT = "generic" || $ARCHINPUT = "nehalem" ]]; then
    WGET https://zlib.net/fossils/zlib-1.3.1.tar.gz \
         9a93b2b7dfdac77ceba5a558a580e74667dd6fede4585b91eefb60f03b72df23
    CFLAGS=$MYCFLAGS CXXFLAGS=$MYCFLAGS ./configure --static --prefix ${WORKDIR}
else
    # high perf zlib version
    #GITCLONE https://github.com/cloudflare/zlib.git zlib gcc.amd64
    #${CMAKE} \
    #-DCMAKE_CXX_FLAGS="${MYCFLAGS}" \
    #-DCMAKE_C_FLAGS="${MYCFLAGS}" \
    #-DCMAKE_CXX_FLAGS_RELWITHDEBINFO="${MYRWDIFLAGS}" \
    #-DCMAKE_C_FLAGS_RELWITHDEBINFO="${MYRWDIFLAGS}" \
    #-DCMAKE_BUILD_TYPE=RelWithDebInfo \
    #-DBUILD_SHARED_LIBS=OFF \
    #-DENABLE_ASSEMBLY=PCLMUL \
    #-DSKIP_CPUID_CHECK=ON \
    #-DUSE_STATIC_RUNTIME=ON \
    #-DCMAKE_INSTALL_PREFIX=${WORKDIR} \
    #.
    # slighty less higher perf zlib version
    GITCLONE https://github.com/zlib-ng/zlib-ng.git zlib 2.1.5
    ${CMAKE} \
    -DCMAKE_CXX_FLAGS="${MYCFLAGS}" \
    -DCMAKE_C_FLAGS="${MYCFLAGS}" \
    -DCMAKE_CXX_FLAGS_RELWITHDEBINFO="${MYRWDIFLAGS}" \
    -DCMAKE_C_FLAGS_RELWITHDEBINFO="${MYRWDIFLAGS}" \
    -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    -DWITH_SSE2=ON \
    -DWITH_SSE4=ON \
    -DWITH_SSSE3=ON \
    -DWITH_AVX2=ON \
    -DZLIB_COMPAT=ON \
    -DZLIB_ENABLE_TESTS=OFF \
    -DCMAKE_INSTALL_PREFIX=${WORKDIR} \
    .
fi

${MAKECMD}
${MAKECMD} install

# libpng
WGET https://downloads.sourceforge.net/project/libpng/libpng16/1.6.50/libpng-1.6.50.tar.gz \
     708f4398f996325819936d447f982e0db90b6b8212b7507e7672ea232210949a
${CMAKE} \
-DCMAKE_CXX_FLAGS="${MYCFLAGS}" \
-DCMAKE_C_FLAGS="${MYCFLAGS}" \
-DCMAKE_CXX_FLAGS_RELWITHDEBINFO="${MYRWDIFLAGS}" \
-DCMAKE_C_FLAGS_RELWITHDEBINFO="${MYRWDIFLAGS}" \
-DCMAKE_BUILD_TYPE=RelWithDebInfo \
-DPNG_SHARED=OFF \
-DZLIB_ROOT=${WORKDIR} \
-DCMAKE_INSTALL_PREFIX=${WORKDIR} \
.

${MAKECMD}
${MAKECMD} install

# libgif
WGET https://downloads.sourceforge.net/project/giflib/giflib-5.2.2.tar.gz \
     be7ffbd057cadebe2aa144542fd90c6838c6a083b5e8a9048b8ee3b66b29d5fb
sed -ie "s/OFLAGS  = -O2/OFLAGS=${MYCFLAGS}/g"  Makefile
${MAKECMD} libgif.a libgif.so  # so is needed only for install-lib to work
${MAKECMD} install-include install-lib PREFIX=${WORKDIR}

# libjpeg
WGET https://www.ijg.org/files/jpegsrc.v9f.tar.gz \
     04705c110cb2469caa79fb71fba3d7bf834914706e9641a4589485c1f832565b
CFLAGS=$MYCFLAGS CXXFLAGS=$MYCFLAGS ./configure --prefix ${WORKDIR}

${MAKECMD}
${MAKECMD} install

# libtiff
WGET https://download.osgeo.org/libtiff/tiff-4.7.0.tar.gz \
     67160e3457365ab96c5b3286a0903aa6e78bdc44c4bc737d2e486bcecb6ba976
CFLAGS=$MYCFLAGS CXXFLAGS=$MYCFLAGS ./configure --disable-lzma --disable-jbig \
  --disable-docs --disable-tests --disable-tools --disable-contrib --prefix ${WORKDIR}

${MAKECMD}
${MAKECMD} install

# libIL (DevIL)
#WGET https://api.github.com/repos/spring/DevIL/tarball/d46aa9989f502b89de06801925d20e53d220c1b4
WGET https://downloads.sourceforge.net/project/openil/DevIL/1.8.0/DevIL-1.8.0.tar.gz \
     0075973ee7dd89f0507873e2580ac78336452d29d34a07134b208f44e2feb709
cd DevIL
cd src-IL
${CMAKE} \
-DCMAKE_CXX_FLAGS="${MYCFLAGS} -fpermissive" \
-DCMAKE_C_FLAGS="${MYCFLAGS} -fpermissive" \
-DCMAKE_CXX_FLAGS_RELWITHDEBINFO="${MYRWDIFLAGS}" \
-DCMAKE_C_FLAGS_RELWITHDEBINFO="${MYRWDIFLAGS}" \
-DCMAKE_BUILD_TYPE=RelWithDebInfo \
-DBUILD_SHARED_LIBS=0 \
-DGIF_INCLUDE_DIR=${INCLUDEDIR} -DGIF_LIBRARY=${LIBDIR}/libgif.a \
-DPNG_PNG_INCLUDE_DIR=${INCLUDEDIR} -DPNG_LIBRARY_RELEASE=${LIBDIR}/libpng.a \
-DJPEG_INCLUDE_DIR=${INCLUDEDIR} -DJPEG_LIBRARY=${LIBDIR}/libjpeg.a \
-DTIFF_INCLUDE_DIR=${INCLUDEDIR} -DTIFF_LIBRARY_RELEASE=${LIBDIR}/libtiff.a \
-DZLIB_INCLUDE_DIR=${INCLUDEDIR} -DZLIB_LIBRARY_RELEASE=${LIBDIR}/libz.a \
-DGLUT_INCLUDE_DIR=${INCLUDEDIR} \
-DCMAKE_INSTALL_PREFIX=${WORKDIR} \
.

${MAKECMD}
${MAKECMD} install

cd ../src-ILU
sed -i "s/ILU SHARED/ILU/g" CMakeLists.txt
${CMAKE} \
-DCMAKE_CXX_FLAGS="${MYCFLAGS}" \
-DCMAKE_C_FLAGS="${MYCFLAGS}" \
-DCMAKE_CXX_FLAGS_RELWITHDEBINFO="${MYRWDIFLAGS}" \
-DCMAKE_C_FLAGS_RELWITHDEBINFO="${MYRWDIFLAGS}" \
-DCMAKE_BUILD_TYPE=RelWithDebInfo \
-DCMAKE_INSTALL_PREFIX=${WORKDIR} \
.

${MAKECMD}
${MAKECMD} install

cd ../src-ILUT
sed -i "s/ILUT SHARED/ILUT/g" CMakeLists.txt
${CMAKE} \
-DCMAKE_CXX_FLAGS="${MYCFLAGS}" \
-DCMAKE_C_FLAGS="${MYCFLAGS}" \
-DCMAKE_CXX_FLAGS_RELWITHDEBINFO="${MYRWDIFLAGS}" \
-DCMAKE_C_FLAGS_RELWITHDEBINFO="${MYRWDIFLAGS}" \
-DCMAKE_BUILD_TYPE=RelWithDebInfo \
-DCMAKE_INSTALL_PREFIX=${WORKDIR} \
.

${MAKECMD}
${MAKECMD} install


# libunwind
WGET https://download.savannah.nongnu.org/releases/libunwind/libunwind-1.6.2.tar.gz \
     4a6aec666991fb45d0889c44aede8ad6eb108071c3554fcdff671f9c94794976
CFLAGS=$MYCFLAGS CXXFLAGS=$MYCFLAGS ./configure --enable-shared=no --enable-static=yes --prefix ${WORKDIR}

${MAKECMD}
${MAKECMD} install

# glew
WGET https://downloads.sourceforge.net/project/glew/glew/2.2.0/glew-2.2.0.tgz \
     d4fc82893cfb00109578d0a1a2337fb8ca335b3ceccf97b97e5cc7f08e4353e1
${CMAKE} \
-DCMAKE_CXX_FLAGS="${MYCFLAGS}" \
-DCMAKE_C_FLAGS="${MYCFLAGS}" \
-DCMAKE_CXX_FLAGS_RELWITHDEBINFO="${MYRWDIFLAGS}" \
-DCMAKE_C_FLAGS_RELWITHDEBINFO="${MYRWDIFLAGS}" \
-DCMAKE_BUILD_TYPE=RelWithDebInfo \
-DCMAKE_INSTALL_PREFIX=${WORKDIR} \
-DOpenGL_GL_PREFERENCE=GLVND \
-DBUILD_UTILS=OFF \
-DBUILD_SHARED_LIBS=OFF \
build/cmake

${MAKECMD} GLEW_PREFIX=${WORKDIR} GLEW_DEST=${WORKDIR} LIBDIR=${LIBDIR} install

# openssl
WGET https://github.com/openssl/openssl/releases/download/openssl-3.5.2/openssl-3.5.2.tar.gz \
     c53a47e5e441c930c3928cf7bf6fb00e5d129b630e0aa873b08258656e7345ec
CFLAGS=$MYCFLAGS CXXFLAGS=$MYCFLAGS ./config no-ssl3 no-comp no-shared no-dso no-weak-ssl-ciphers no-tests no-deprecated --libdir=lib --prefix=${WORKDIR}

${MAKECMD}
${MAKECMD} install_sw

# nghttp2 for curl
WGET https://github.com/nghttp2/nghttp2/releases/download/v1.66.0/nghttp2-1.66.0.tar.gz \
     e178687730c207f3a659730096df192b52d3752786c068b8e5ee7aeb8edae05a
CFLAGS=$MYCFLAGS CXXFLAGS=$MYCFLAGS ./configure --enable-lib-only --disable-shared --prefix ${WORKDIR}

${MAKECMD}
${MAKECMD} install

# libpsl for curl
WGET https://github.com/rockdaboot/libpsl/releases/download/0.21.5/libpsl-0.21.5.tar.gz \
     1dcc9ceae8b128f3c0b3f654decd0e1e891afc6ff81098f227ef260449dae208

CFLAGS=$MYCFLAGS ./configure --disable-shared --prefix ${WORKDIR}
${MAKECMD}
${MAKECMD} install

# curl
WGET https://curl.se/download/curl-8.15.0.tar.gz \
     d85cfc79dc505ff800cb1d321a320183035011fa08cb301356425d86be8fc53c
CFLAGS=$MYCFLAGS CXXFLAGS=$MYCFLAGS ./configure --disable-shared --disable-manual \
  --disable-dict --disable-file --disable-ftp --disable-gopher --disable-imap \
  --disable-pop3 --disable-rtsp --disable-smb --disable-smtp --disable-smtps \
  --disable-telnet --disable-tftp --disable-unix-sockets --disable-ntlm --disable-ipfs \
  --disable-mqtt --disable-docs \
  --with-nghttp2=${WORKDIR} --with-zlib=${WORKDIR} --with-ssl=${WORKDIR} \
  --prefix ${WORKDIR}

${MAKECMD}
${MAKECMD} install

# libogg-dev
WGET https://github.com/xiph/ogg/releases/download/v1.3.6/libogg-1.3.6.tar.gz \
     83e6704730683d004d20e21b8f7f55dcb3383cdf84c0daedf30bde175f774638
CFLAGS=$MYCFLAGS CXXFLAGS=$MYCFLAGS ./configure --prefix ${WORKDIR} \
--enable-shared=no \
--enable-static=yes

${MAKECMD}
${MAKECMD} install

#libvorbis
WGET https://github.com/xiph/vorbis/releases/download/v1.3.7/libvorbis-1.3.7.tar.gz \
     0e982409a9c3fc82ee06e08205b1355e5c6aa4c36bca58146ef399621b0ce5ab
CFLAGS=$MYCFLAGS CXXFLAGS=$MYCFLAGS ./configure --prefix ${WORKDIR} \
--enable-shared=no \
--enable-static=yes \
--disable-oggtest

${MAKECMD}
${MAKECMD} install

#libuuid
WGET https://downloads.sourceforge.net/project/libuuid/libuuid-1.0.3.tar.gz \
     46af3275291091009ad7f1b899de3d0cea0252737550e7919d17237997db5644
CFLAGS=$MYCFLAGS CXXFLAGS=$MYCFLAGS ./configure --prefix ${WORKDIR} \
--enable-shared=no \
--enable-static=yes \
--disable-oggtest

${MAKECMD}
${MAKECMD} install

WGET https://github.com/tukaani-project/xz/releases/download/v5.8.1/xz-5.8.1.tar.gz \
     507825b599356c10dca1cd720c9d0d0c9d5400b9de300af00e4d1ea150795543
CFLAGS=$MYCFLAGS CXXFLAGS=$MYCFLAGS ./configure --prefix ${WORKDIR} \
--enable-shared=no \
--enable-static=yes \
--disable-xz  \
--disable-xzdec  \
--disable-scripts  \
--disable-doc

${MAKECMD}
${MAKECMD} install

#high perf version
GITCLONE https://github.com/nmoinvaz/minizip.git minizip 4.0.10 \
         f3ed731e27a97e30dffe076ed5e0537daae5c1bd
${CMAKE} \
-DCMAKE_CXX_FLAGS="${MYCFLAGS}" \
-DCMAKE_C_FLAGS="${MYCFLAGS}" \
-DCMAKE_CXX_FLAGS_RELWITHDEBINFO="${MYRWDIFLAGS}" \
-DCMAKE_C_FLAGS_RELWITHDEBINFO="${MYRWDIFLAGS}" \
-DCMAKE_BUILD_TYPE=RelWithDebInfo \
-DMZ_COMPAT=ON \
-DMZ_COMPAT_VERSION=110 \
-DMZ_LIBBSD=OFF \
-DMZ_PKCRYPT=OFF \
-DMZ_OPENSSL=OFF \
-DMZ_SIGNING=OFF \
-DMZ_WZAES=OFF \
-DMZ_BZIP2=OFF \
-DMZ_ZSTD=OFF \
-DZLIB_LIBRARY=${LIBDIR}/libz.a \
-DZLIB_INCLUDE_DIR=${INCLUDEDIR} \
-DLIBLZMA_LIBRARIES=${LIBDIR}/liblzma.a \
-DLIBLZMA_STATIC_LIBRARIES=${LIBDIR}/liblzma.a \
-DLIBLZMA_INCLUDEDIR=${INCLUDEDIR} \
-DLIBLZMA_liblzma_INCLUDEDIR=${INCLUDEDIR} \
-DINSTALL_INC_DIR=${INCLUDEDIR}/minizip \
-DCMAKE_INSTALL_PREFIX=${WORKDIR} \
.

${MAKECMD}
${MAKECMD} install

# SDL2
: '
GITCLONE https://github.com/libsdl-org/SDL SDL release-2.0.18
mkdir build
cd build
${CMAKE} \
-S ../ \
-DCMAKE_CXX_FLAGS="${MYCFLAGS}" \
-DCMAKE_C_FLAGS="${MYCFLAGS}" \
-DCMAKE_CXX_FLAGS_RELWITHDEBINFO="${MYRWDIFLAGS}" \
-DCMAKE_C_FLAGS_RELWITHDEBINFO="${MYRWDIFLAGS}" \
-DCMAKE_BUILD_TYPE=RelWithDebInfo \
-DSDL_3DNOW:BOOL=OFF \
-DSDL_ALSA:BOOL=OFF \
-DSDL_ALTIVEC:BOOL=OFF \
-DSDL_ARMNEON:BOOL=OFF \
-DSDL_ARMSIMD:BOOL=OFF \
-DSDL_ARTS:BOOL=OFF \
-DSDL_ASAN:BOOL=OFF \
-DSDL_ASSEMBLY:BOOL=ON \
-DSDL_ASSERTIONS:STRING=auto \
-DSDL_ATOMIC:BOOL=OFF \
-DSDL_AUDIO:BOOL=OFF \
-DSDL_BACKGROUNDING_SIGNAL:STRING=OFF \
-DSDL_CLOCK_GETTIME:BOOL=OFF \
-DSDL_CMAKE_DEBUG_POSTFIX:STRING=d \
-DSDL_COCOA:BOOL=OFF \
-DSDL_CPUINFO:BOOL=OFF \
-DSDL_DIRECTFB:BOOL=OFF \
-DSDL_DIRECTX:BOOL=OFF \
-DSDL_DISKAUDIO:BOOL=OFF \
-DSDL_DLOPEN:BOOL=OFF \
-DSDL_DUMMYAUDIO:BOOL=OFF \
-DSDL_DUMMYVIDEO:BOOL=OFF \
-DSDL_ESD:BOOL=OFF \
-DSDL_EVENTS:BOOL=ON \
-DSDL_FILE:BOOL=OFF \
-DSDL_FILESYSTEM:BOOL=OFF \
-DSDL_FOREGROUNDING_SIGNAL:STRING=OFF \
-DSDL_FUSIONSOUND:BOOL=OFF \
-DSDL_GCC_ATOMICS:BOOL=OFF \
-DSDL_HAPTIC:BOOL=OFF \
-DSDL_HIDAPI:BOOL=OFF \
-DSDL_HIDAPI_JOYSTICK:BOOL=OFF \
-DSDL_JACK:BOOL=OFF \
-DSDL_JOYSTICK:BOOL=OFF \
-DSDL_KMSDRM:BOOL=OFF \
-DSDL_LIBC:BOOL=ON \
-DSDL_LIBSAMPLERATE:BOOL=OFF \
-DSDL_LOADSO:BOOL=OFF \
-DSDL_LOCALE:BOOL=OFF \
-DSDL_METAL:BOOL=OFF \
-DSDL_MMX:BOOL=ON \
-DSDL_NAS:BOOL=OFF \
-DSDL_OFFSCREEN:BOOL=OFF \
-DSDL_OPENGL:BOOL=ON \
-DSDL_OPENGLES:BOOL=OFF \
-DSDL_OSS:BOOL=OFF \
-DSDL_PIPEWIRE:BOOL=OFF \
-DSDL_POWER:BOOL=OFF \
-DSDL_PTHREADS:BOOL=OFF \
-DSDL_PULSEAUDIO:BOOL=OFF \
-DSDL_RENDER:BOOL=OFF \
-DSDL_RENDER_D3D:BOOL=OFF \
-DSDL_RENDER_METAL:BOOL=OFF \
-DSDL_RPATH:BOOL=OFF \
-DSDL_RPI:BOOL=OFF \
-DSDL_SENSOR:BOOL=OFF \
-DSDL_SHARED:BOOL=OFF \
-DSDL_SNDIO:BOOL=OFF \
-DSDL_SNDIO_SHARED:BOOL=OFF \
-DSDL_SSE:BOOL=ON \
-DSDL_SSE2:BOOL=ON \
-DSDL_SSE3:BOOL=OFF \
-DSDL_SSEMATH:BOOL=ON \
-DSDL_STATIC:BOOL=ON \
-DSDL_STATIC_PIC:BOOL=ON \
-DSDL_TEST:BOOL=OFF \
-DSDL_THREADS:BOOL=OFF \
-DSDL_TIMERS:BOOL=OFF \
-DSDL_VIDEO:BOOL=OFF \
-DSDL_VIRTUAL_JOYSTICK:BOOL=OFF \
-DSDL_VIVANTE:BOOL=OFF \
-DSDL_VULKAN:BOOL=OFF \
-DSDL_WASAPI:BOOL=OFF \
-DSDL_WAYLAND:BOOL=OFF \
-DSDL_WAYLAND_LIBDECOR_SHARED:BOOL=OFF \
-DSDL_X11:BOOL=ON \
-DSDL_XINPUT:BOOL=OFF \
-DCMAKE_INSTALL_PREFIX=${WORKDIR}

${MAKECMD}
${MAKECMD} install
'

# Finalize()
cd ${WORKDIR}
rm -rf ${WORKDIR}/download
rm -rf ${WORKDIR}/tmp
