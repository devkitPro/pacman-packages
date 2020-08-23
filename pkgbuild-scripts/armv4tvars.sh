. "${BASH_SOURCE%/*}"/devkitarm.sh

PORTLIBS_PREFIX=${PORTLIBS_ROOT}/armv4t
PATH=$PORTLIBS_PREFIX/bin:$PATH

export CFLAGS="-march=armv4t -O2 -ffunction-sections -fdata-sections"
export CXXFLAGS="${CFLAGS}"
export CPPFLAGS="-I${PORTLIBS_PREFIX}/include"
export LDFLAGS="-L${PORTLIBS_PREFIX}/lib"
export LIBS=""
