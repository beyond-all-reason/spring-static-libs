
set -e

if [ $# -eq 0 ]; then
	echo "Missing destination directory"
	exit 2
fi

export WORKDIR=$1
export ARCHINPUT=$2
export TMPDIR=${WORKDIR}/tmp
export INCLUDEDIR=${WORKDIR}/include
export LIBDIR=${WORKDIR}/lib
export MAKE="make -j$(nproc)"
export CMAKE="cmake"
export DLDIR=${WORKDIR}/download

if [[ $ARCHINPUT == "" ]]; then
    ARCHINPUT="generic"
fi

if [[ $ARCHINPUT = "generic" ]]; then
    MYARCH_FLAGS="-march=nehalem -mtune=nehalem -msse -mno-sse2 -mno-sse3 -mno-ssse3 -mno-sse4.1 -mno-sse4.2 -mno-sse4 -mno-sse4a -mno-avx -mno-fma -mno-fma4 -mno-xop -mno-lwp -mno-avx2" #mtune=generic is bugged somehow and sometimes emits unwanted instructions no matter -mno-*
else
    MYARCH_FLAGS="-march=$ARCHINPUT -mtune=$ARCHINPUT"
fi

MYARCH_FLAGS="$MYARCH_FLAGS -mfpmath=sse"


export MYCFLAGS="-fcommon -fPIC -DPIC -O3 $MYARCH_FLAGS"
echo "Building with MYCFLAGS: $MYCFLAGS"

export MYRWDIFLAGS="-ggdb3 -DNDEBUG"
echo "Building with MYRWDIFLAGS: $MYRWDIFLAGS"

export UBUNTU_MAJORVER=$(sed -n 's/^DISTRIB_RELEASE=//p' /etc/lsb-release | cut -d'.' -f1)


echo WORKDIR:    $WORKDIR
echo TMPDIR:     $TMPDIR
echo INCLUDEDIR: $INCLUDEDIR
echo LIBDIR:     $LIBDIR
echo MAKE:       $MAKE
echo DLDIR:      $DLDIR


mkdir -p ${TMPDIR}
mkdir -p ${INCLUDEDIR}
mkdir -p ${LIBDIR}
mkdir -p ${DLDIR}

function WGET {
  URL=$1
  FILENAME=${DLDIR}/$(basename $1)
  if ! [ -s $FILENAME ]; then
    /usr/bin/wget $1 -O $FILENAME
  fi

  cd $(mktemp -d)
  tar xifzv $FILENAME --strip-components=1
}

function GITCLONE {
  URL=$1
  DIR=$2
  BRANCH=$3

  cd $(mktemp -d)

  git clone --recursive -b $BRANCH $URL $DIR
  cd $DIR
}

function APTGETSOURCE {
  pkg=$1
  cd $(mktemp -d)
  apt source $pkg && apt-get build-dep -y $pkg
  tmp_dir=$(pwd)
  for d in $(find ./ -maxdepth 1 -not -path "./" -type d); do
    cd $d
	break
  done
}

