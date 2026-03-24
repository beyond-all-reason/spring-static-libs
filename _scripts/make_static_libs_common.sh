
set -e

if [ $# -eq 0 ]; then
	echo "Missing destination directory"
	exit 2
fi

export WORKDIR=$1
export ARCHINPUT=${2:-generic}
export CPUARCH="$(uname -m)"
export TMPDIR=${WORKDIR}/tmp
export INCLUDEDIR=${WORKDIR}/include
export LIBDIR=${WORKDIR}/lib
export MAKECMD="make -j$(nproc)"
export CMAKE="cmake"
export DLDIR=${WORKDIR}/download

if [[ $ARCHINPUT != "generic" ]]; then
    MYARCH_FLAGS="-march=$ARCHINPUT -mtune=$ARCHINPUT"
    if [[ $CPUARCH == "x86_64" ]]; then
        MYARCH_FLAGS="$MYARCH_FLAGS -mfpmath=sse"
    fi
elif [[ $CPUARCH == "x86_64" ]]; then
    MYARCH_FLAGS="-march=x86-64 -mtune=generic -msse -mno-sse3 -mno-ssse3 -mno-sse4.1 -mno-sse4.2 -mno-sse4 -mno-sse4a -mno-avx -mno-fma -mno-fma4 -mno-xop -mno-lwp -mno-avx2 -mfpmath=sse"
elif [[ $CPUARCH == "aarch64" ]]; then
    # We don't know yet if this will be enough, flags from https://github.com/beyond-all-reason/RecoilEngine/pull/2540
    MYARCH_FLAGS="-march=armv8-a+simd -ffp-contract=off"
else
    echo "Unsupported architecture $CPUARCH!"
    exit 1
fi

export MYCFLAGS="-fcommon -fPIC -DPIC -O3 -fno-omit-frame-pointer $MYARCH_FLAGS"
echo "Building with MYCFLAGS: $MYCFLAGS"

export MYRWDIFLAGS="-ggdb3 -DNDEBUG"
echo "Building with MYRWDIFLAGS: $MYRWDIFLAGS"

export UBUNTU_MAJORVER=$(sed -n 's/^DISTRIB_RELEASE=//p' /etc/lsb-release | cut -d'.' -f1)


echo WORKDIR:    $WORKDIR
echo TMPDIR:     $TMPDIR
echo INCLUDEDIR: $INCLUDEDIR
echo LIBDIR:     $LIBDIR
echo MAKECMD:    $MAKECMD
echo DLDIR:      $DLDIR


mkdir -p ${TMPDIR}
mkdir -p ${INCLUDEDIR}
mkdir -p ${LIBDIR}
mkdir -p ${DLDIR}

function EXTRACT {
  local FILENAME=${DLDIR}/$1
  if ! [ -s "$FILENAME" ]; then
    echo "Missing pre-downloaded archive: $1"
    exit 1
  fi
  local HASH
  HASH=$(sha256sum "$FILENAME" | cut -d' ' -f1)

  mkdir $TMPDIR/$HASH
  cd $TMPDIR/$HASH
  export SOURCE_DATE_EPOCH=$(date -d "$(tar -tzvf $FILENAME --full-time | awk '{print $4, $5}' | sort | tail -n 1)" +%s)
  tar xifzv $FILENAME --strip-components=1
}
