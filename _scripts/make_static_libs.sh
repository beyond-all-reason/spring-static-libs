#!/bin/bash

set -e
source $(dirname $0)/make_static_libs_common.sh

# zlib
if [[ $ARCHINPUT = "generic" || $ARCHINPUT = "nehalem" ]]; then
    WGET https://www.zlib.net/zlib-1.2.11.tar.gz
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
    GITCLONE https://github.com/zlib-ng/zlib-ng.git zlib 1.9.9-b1
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

${MAKE}
${MAKE} install

# libpng
WGET https://downloads.sourceforge.net/project/libpng/libpng16/1.6.37/libpng-1.6.37.tar.gz
${CMAKE} \
-DCMAKE_CXX_FLAGS="${MYCFLAGS}" \
-DCMAKE_C_FLAGS="${MYCFLAGS}" \
-DCMAKE_CXX_FLAGS_RELWITHDEBINFO="${MYRWDIFLAGS}" \
-DCMAKE_C_FLAGS_RELWITHDEBINFO="${MYRWDIFLAGS}" \
-DCMAKE_BUILD_TYPE=RelWithDebInfo \
-DPNG_SHARED=OFF \
-DPNG_BUILD_ZLIB=ON \
-DZLIB_INCLUDE_DIR=${INCLUDEDIR} \
-DZLIB_LIBRARY_RELEASE=${LIBDIR}/libz.a \
-DCMAKE_INSTALL_PREFIX=${WORKDIR} \
.

${MAKE}
${MAKE} install

# libgif
WGET https://downloads.sourceforge.net/project/giflib/giflib-5.2.1.tar.gz
sed -ie "s/OFLAGS  = -O2/OFLAGS=${MYCFLAGS}/g"  Makefile
${MAKE}
${MAKE} install PREFIX=${WORKDIR}

# libjpeg
WGET http://www.ijg.org/files/jpegsrc.v9d.tar.gz
CFLAGS=$MYCFLAGS CXXFLAGS=$MYCFLAGS ./configure --prefix ${WORKDIR}

${MAKE}
${MAKE} install

# libtiff
WGET https://download.osgeo.org/libtiff/tiff-4.1.0.tar.gz
CFLAGS=$MYCFLAGS CXXFLAGS=$MYCFLAGS ./configure --disable-lzma --disable-jbig --prefix ${WORKDIR}

${MAKE}
${MAKE} install

# libIL (DevIL)
#WGET https://api.github.com/repos/spring/DevIL/tarball/d46aa9989f502b89de06801925d20e53d220c1b4
WGET https://downloads.sourceforge.net/project/openil/DevIL/1.8.0/DevIL-1.8.0.tar.gz
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

${MAKE}
${MAKE} install

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

${MAKE}
${MAKE} install

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

${MAKE}
${MAKE} install


# libunwind
#APTGETSOURCE libunwind-dev
WGET http://download.savannah.nongnu.org/releases/libunwind/libunwind-1.4.0.tar.gz
CFLAGS=$MYCFLAGS CXXFLAGS=$MYCFLAGS ./configure --enable-shared=no --enable-static=yes --prefix ${WORKDIR}

${MAKE}
${MAKE} install

# glew
WGET https://downloads.sourceforge.net/project/glew/glew/2.2.0/glew-2.2.0.tgz
${CMAKE} \
-DCMAKE_CXX_FLAGS="${MYCFLAGS}" \
-DCMAKE_C_FLAGS="${MYCFLAGS}" \
-DCMAKE_CXX_FLAGS_RELWITHDEBINFO="${MYRWDIFLAGS}" \
-DCMAKE_C_FLAGS_RELWITHDEBINFO="${MYRWDIFLAGS}" \
-DCMAKE_BUILD_TYPE=RelWithDebInfo \
-DCMAKE_INSTALL_PREFIX=${WORKDIR} \
-DOpenGL_GL_PREFERENCE=GLVND \
build/cmake

${MAKE} GLEW_PREFIX=${WORKDIR} GLEW_DEST=${WORKDIR} LIBDIR=${LIBDIR} install

# openssl
#WGET https://www.openssl.org/source/openssl-1.1.1h.tar.gz
WGET https://github.com/openssl/openssl/archive/OpenSSL_1_1_1i.tar.gz
CFLAGS=$MYCFLAGS CXXFLAGS=$MYCFLAGS ./config no-ssl3 no-comp no-shared no-dso no-weak-ssl-ciphers no-tests no-deprecated --prefix=${WORKDIR}

${MAKE}
${MAKE} install_sw

# curl
#WGET https://curl.haxx.se/download/curl-7.65.3.tar.gz
WGET https://curl.se/download/curl-7.73.0.tar.gz
CFLAGS=$MYCFLAGS CXXFLAGS=$MYCFLAGS ./configure --disable-shared --disable-manual --disable-dict --disable-file --disable-ftp --disable-ftps --disable-gopher --disable-imap --disable-imaps --disable-pop3 --disable-pop3s --disable-rtsp --disable-smb --disable-smbs --disable-smtp --disable-smtps --disable-telnet --disable-tftp --disable-unix-sockets --with-ssl=${WORKDIR} --prefix ${WORKDIR}

${MAKE}
${MAKE} install

# libogg-dev
#APTGETSOURCE libogg-dev
WGET https://github.com/xiph/ogg/releases/download/v1.3.4/libogg-1.3.4.tar.gz
CFLAGS=$MYCFLAGS CXXFLAGS=$MYCFLAGS ./configure --prefix ${WORKDIR} \
--enable-shared=no \
--enable-static=yes

$MAKE
$MAKE install

#libvorbis
WGET https://github.com/xiph/vorbis/releases/download/v1.3.7/libvorbis-1.3.7.tar.gz
CFLAGS=$MYCFLAGS CXXFLAGS=$MYCFLAGS ./configure --prefix ${WORKDIR} \
--enable-shared=no \
--enable-static=yes \
--disable-oggtest

${MAKE}
${MAKE} install

#libuuid
WGET https://downloads.sourceforge.net/project/libuuid/libuuid-1.0.3.tar.gz
CFLAGS=$MYCFLAGS CXXFLAGS=$MYCFLAGS ./configure --prefix ${WORKDIR} \
--enable-shared=no \
--enable-static=yes \
--disable-oggtest

${MAKE}
${MAKE} install

#APTGETSOURCE liblzma-dev
WGET https://downloads.sourceforge.net/project/lzmautils/xz-5.2.5.tar.gz
#if [ -f autogen.sh ]; then
#  ./autogen.sh
#fi
CFLAGS=$MYCFLAGS CXXFLAGS=$MYCFLAGS ./configure --prefix ${WORKDIR} \
--enable-shared=no \
--enable-static=yes \
--disable-xz  \
--disable-xzdec  \
--disable-scripts  \
--disable-doc \
#--disable-lzmadec 
#--disable-lzmainfo
#--disable-lzma-links

$MAKE
$MAKE install

#libminizip-dev
#APTGETSOURCE libminizip-dev
#autoreconf -i
#./configure --prefix ${WORKDIR}

#high perf version
GITCLONE https://github.com/nmoinvaz/minizip.git minizip master
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


${MAKE}
${MAKE} install

# SDL2
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

${MAKE}
${MAKE} install


# Finalize()
cd ${WORKDIR}
rm -rf ${WORKDIR}/download
rm -rf ${WORKDIR}/tmp